//
// Copyright 2019 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GSCXRingViewArranger.h"

#import "GSCXScannerIssue.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXRingViewArranger ()

/**
 * The coordinate space of the original UI elements associated with the issues in @c result.
 */
@property(assign, nonatomic) CGRect originalCoordinates;

/**
 * The coordinate space of the superview to which the ring views are added.
 */
@property(assign, nonatomic) CGRect newCoordinates;

@end

@implementation GSCXRingViewArranger

- (instancetype)initWithResult:(GSCXScannerResult *)result {
  self = [super init];
  if (self) {
    _result = result;
  }
  return self;
}

- (void)addRingViewsToSuperview:(UIView *)superview fromCoordinates:(CGRect)originalCoordinates {
  self.originalCoordinates = originalCoordinates;
  self.newCoordinates = superview.bounds;
  _ringViews = [self gscx_ringViewsForOriginalCoordinates:originalCoordinates
                                           newCoordinates:superview.bounds];
  for (GSCXRingView *ringView in self.ringViews) {
    [superview addSubview:ringView];
  }
}

- (void)removeRingViewsFromSuperview {
  for (GSCXRingView *ringView in self.ringViews) {
    [ringView removeFromSuperview];
  }
}

- (void)addAccessibilityAttributesToRingViews {
  NSUInteger index = 0;
  for (GSCXRingView *ringView in self.ringViews) {
    NSString *accessibilityLabel = self.result.issues[index].accessibilityLabel;
    NSUInteger count = self.result.issues[index].underlyingIssueCount;
    NSString *pluralModifier = (count == 1) ? @"" : @"s";
    if (accessibilityLabel == nil) {
      ringView.accessibilityLabel =
          [NSString stringWithFormat:@"%lu issue%@ for element with no accessibility label",
                                     (unsigned long)count, pluralModifier];
    } else {
      ringView.accessibilityLabel =
          [NSString stringWithFormat:@"%lu issue%@ for element with accessibility label %@",
                                     (unsigned long)count, pluralModifier, accessibilityLabel];
    }
    ringView.accessibilityIdentifier =
        [GSCXRingViewArranger accessibilityIdentifierForRingViewAtIndex:index];
    index++;
  }
}

- (GSCXScannerResult *)resultWithIssuesAtPoint:(CGPoint)point {
  NSMutableArray<GSCXScannerIssue *> *issues = [NSMutableArray array];
  for (NSUInteger i = 0; i < [self.ringViews count]; i++) {
    if (CGRectContainsPoint(self.ringViews[i].frame, point)) {
      [issues addObject:self.result.issues[i]];
    }
  }
  return [[GSCXScannerResult alloc] initWithIssues:issues screenshot:self.result.screenshot];
}

- (UIImage *)imageByAddingRingViewsToSuperview:(UIView *)superview
                               fromCoordinates:(CGRect)originalCoordinates {
  [self addRingViewsToSuperview:superview fromCoordinates:originalCoordinates];
  UIGraphicsBeginImageContextWithOptions(superview.bounds.size, YES, 0.0);
  [superview drawViewHierarchyInRect:superview.bounds afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [self removeRingViewsFromSuperview];
  return image;
}

+ (NSString *)accessibilityIdentifierForRingViewAtIndex:(NSUInteger)index {
  return [NSString
      stringWithFormat:@"GSCXRingViewArranger_Ring_%lu", (unsigned long)index];
}

#pragma mark - Private

/**
 * Constructs a ring view for each issue in @c result by transforming the issue's frame from
 * @c originalCoordinates to @c newCoordinates.
 *
 * @param originalCoordinates The coordinate space the UI elements were in at the time of the scan.
 * @param newCoordinates The coordinate space to which the ring views will be added.
 * @return An array of @c GSCXRingView instances highlighting the views associated with the issues
 * in @c result.
 */
- (NSArray<GSCXRingView *> *)gscx_ringViewsForOriginalCoordinates:(CGRect)originalCoordinates
                                                   newCoordinates:(CGRect)newCoordinates {
  NSMutableArray<GSCXRingView *> *ringViews =
      [NSMutableArray arrayWithCapacity:[self.result.issues count]];
  for (GSCXScannerIssue *issue in self.result.issues) {
    CGRect ringFrame = [self gscx_convertRect:issue.frame
                              fromCoordinates:originalCoordinates
                                toCoordinates:newCoordinates];
    GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:ringFrame];
    [ringViews addObject:ringView];
  }
  return [ringViews copy];
}

/**
 * Calculates the horizontal and vertical scale factors to transform points in
 * @c originalCoordinates to @c newCoordinates.
 *
 * @param originalCoordinates The coordinate space the UI elements were in at the time of the scan.
 * @param newCoordinates The coordinate space to which the ring views will be added.
 * @return A @c CGPoint instance whose @c x value is the horizontal scale factor and @c y value is
 * the vertical scale factor.
 */
- (CGPoint)gscx_scaleFactorForOriginalCoordinates:(CGRect)originalCoordinates
                                   newCoordinates:(CGRect)newCoordinates {
  return CGPointMake(CGRectGetWidth(newCoordinates) / CGRectGetWidth(originalCoordinates),
                     CGRectGetHeight(newCoordinates) / CGRectGetHeight(originalCoordinates));
}

/**
 * Converts @c point from the coordinate space @c originalCoordinates to the coordinate space
 * @c newCoordinates.
 *
 * @param point The point to convert, in the coordinate space @c originalCoordinates.
 * @param originalCoordinates The coordinate space containing @c point.
 * @param newCoordinates The coordinate space in which to transform @c point.
 * @return @c point in the coordinate space @c newCoordinates.
 */
- (CGPoint)gscx_convertPoint:(CGPoint)point
             fromCoordinates:(CGRect)originalCoordinates
               toCoordinates:(CGRect)newCoordinates {
  CGPoint scaleFactor = [self gscx_scaleFactorForOriginalCoordinates:originalCoordinates
                                                      newCoordinates:newCoordinates];
  CGFloat x = (point.x - originalCoordinates.origin.x) * scaleFactor.x + newCoordinates.origin.x;
  CGFloat y = (point.y - originalCoordinates.origin.y) * scaleFactor.y + newCoordinates.origin.y;
  return CGPointMake(x, y);
}

/**
 * Converts @c rect from the coordinate space @c originalCoordinates to the coordinate space
 * @c newCoordinates.
 *
 * @param rect The rectangle to convert, in the coordinate space @c originalCoordinates.
 * @param originalCoordinates The coordinate space containing @c rect.
 * @param newCoordinates The coordinate space in which to transform @c rect.
 * @return @c rect in the coordinate space @c newCoordinates.
 */
- (CGRect)gscx_convertRect:(CGRect)rect
           fromCoordinates:(CGRect)originalCoordinates
             toCoordinates:(CGRect)newCoordinates {
  CGPoint scaleFactor = [self gscx_scaleFactorForOriginalCoordinates:originalCoordinates
                                                      newCoordinates:newCoordinates];
  CGPoint origin = [self gscx_convertPoint:rect.origin
                           fromCoordinates:originalCoordinates
                             toCoordinates:newCoordinates];
  return CGRectMake(origin.x, origin.y, rect.size.width * scaleFactor.x,
                    rect.size.height * scaleFactor.y);
}

@end

NS_ASSUME_NONNULL_END
