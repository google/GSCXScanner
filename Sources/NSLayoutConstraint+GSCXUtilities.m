//
// Copyright 2020 Google Inc.
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

#import "NSLayoutConstraint+GSCXUtilities.h"
#import "UIView+NSLayoutConstraint.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@implementation NSLayoutConstraint (GSCXUtilities)

+ (NSArray<NSLayoutConstraint *> *)
    gscx_constraintsWithHorizontalFormat:(nullable NSString *)horizontalFormat
                          verticalFormat:(nullable NSString *)verticalFormat
                                 options:(NSLayoutFormatOptions)options
                                 metrics:(nullable NSDictionary<NSString *, NSNumber *> *)metrics
                                   views:(nullable NSDictionary<NSString *, id> *)views
                               activated:(BOOL)activated {
  GTX_ASSERT(horizontalFormat != nil || verticalFormat != nil,
             @"horizontalFormat and verticalFormat cannot both be nil");
  NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
  if (horizontalFormat != nil) {
    [constraints
        addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalFormat
                                                                    options:options
                                                                    metrics:metrics
                                                                      views:views]];
  }
  if (verticalFormat != nil) {
    if (![verticalFormat hasPrefix:@"V:"]) {
      // Add "V:" so autolayout treats the constraints as vertical.
      verticalFormat = [@"V:" stringByAppendingString:verticalFormat];
    }
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat
                                                                             options:options
                                                                             metrics:metrics
                                                                               views:views]];
  }
  if (activated) {
    [NSLayoutConstraint activateConstraints:constraints];
  }
  return constraints;
}

+ (NSArray<NSLayoutConstraint *> *)gscx_constraintsToFillSuperviewWithView:(UIView *)view
                                                                 activated:(BOOL)activated {
  return [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"|[view]|"
                                                   verticalFormat:@"|[view]|"
                                                          options:0
                                                          metrics:nil
                                                            views:@{@"view" : view}
                                                        activated:activated];
}

+ (NSLayoutConstraint *)gscx_constraintWithView:(UIView *)view
                                    aspectRatio:(CGFloat)aspectRatio
                                      activated:(BOOL)activated {
  GTX_ASSERT(aspectRatio > 0.0, @"Aspect ratio must be positive.");
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:aspectRatio
                                                                 constant:0.0];
  constraint.active = activated;
  return constraint;
}

+ (NSLayoutConstraint *)gscx_constraintToCurrentAspectRatioWithView:(UIView *)view
                                                          activated:(BOOL)activated {
  GTX_ASSERT(view.frame.size.height > 0.0, @"view's height cannot be 0");
  CGFloat aspectRatio = view.frame.size.width / view.frame.size.height;
  return [NSLayoutConstraint gscx_constraintWithView:view
                                         aspectRatio:aspectRatio
                                           activated:activated];
}

+ (NSArray<NSLayoutConstraint *> *)gscx_constraintsCenteringView:(UIView *)view1
                                                        withView:(UIView *)view2
                                                    horizontally:(BOOL)horizontally
                                                      vertically:(BOOL)vertically
                                                       activated:(BOOL)activated {
  GTX_ASSERT(horizontally || vertically, @"horizontally and vertically cannot both be NO");
  NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];
  if (horizontally) {
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view1
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:view2
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
  }
  if (vertically) {
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view1
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:view2
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
  }
  if (activated) {
    [NSLayoutConstraint activateConstraints:constraints];
  }
  return constraints;
}

+ (NSArray<NSLayoutConstraint *> *)gscx_constrainAnchorsOfView:(UIView *)view
                                         equalToSafeAreaOfView:(UIView *)safeAreaView
                                                       leading:(BOOL)constrainLeading
                                                      trailing:(BOOL)constrainTrailing
                                                           top:(BOOL)constrainTop
                                                        bottom:(BOOL)constrainBottom
                                                      constant:(CGFloat)constant
                                                     activated:(BOOL)activated {
  GTX_ASSERT(constrainLeading || constrainTrailing || constrainTop || constrainBottom,
             @"One of the anchors must be YES");
  NSMutableArray<NSLayoutConstraint *> *constraints = [[NSMutableArray alloc] init];
  const BOOL constraintFlags[4] = {constrainLeading, constrainTrailing, constrainTop,
                                   constrainBottom};
  const NSLayoutAttribute constraintAttributes[4] = {NSLayoutAttributeLeading,
                                                     NSLayoutAttributeTrailing,
                                                     NSLayoutAttributeTop, NSLayoutAttributeBottom};
  // Because the order of items in constraintWithItem doesn't change, the leading and top constants
  // must be negative and the trailing and bottom constants must be positive.
  const CGFloat constantSigns[4] = {-1.0, 1.0, -1.0, 1.0};
  for (NSInteger i = 0; i < 4; i++) {
    if (constraintFlags[i]) {
      [constraints
          addObject:[NSLayoutConstraint constraintWithItem:safeAreaView.gscx_safeAreaLayoutGuide
                                                 attribute:constraintAttributes[i]
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:view
                                                 attribute:constraintAttributes[i]
                                                multiplier:1.0
                                                  constant:constant * constantSigns[i]]];
    }
  }
  if (activated) {
    [NSLayoutConstraint activateConstraints:constraints];
  }
  return constraints;
}

@end

NS_ASSUME_NONNULL_END
