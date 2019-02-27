//
// Copyright 2018 Google Inc.
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

#import "GSCXCornerConstraints.h"

/**
 *  The offset between the the superview being snapped to and the view being snapped, in points.
 */
static const CGFloat kGSCXCornerConstraintOffset = 16.0;
/**
 *  The name of the action that rotates the view to the next corner of the screen clockwise. Spoken
 *  by VoiceOver.
 */
static NSString *const kGSCXCornerConstraintRotateClockwiseName = @"Rotate Clockwise";

@interface GSCXCornerConstraints ()

/**
 *  Array of arrays of constraints. Each underlying array represents the constraints needed to
 *  snap a view to a different corner of the screen.
 */
@property(strong, nonatomic) NSArray<NSArray<NSLayoutConstraint *> *> *constraintSets;
/**
 *  The index of @c constraintSets of the currently active constraints.
 */
@property(assign, nonatomic) NSUInteger currentConstraintsIndex;

/**
 *  Initializes a GSCXCornerConstraints object with a given view inside a given container. The view
 *  starts in the bottom leading (left in LTR languages, right in RTL languages) corner.
 *
 *  @param view The view to snap to different corners of the container.
 *  @param container The view controller whose view contains @c view. @c view must be a subview of
 *                   container's view.
 */
- (instancetype)initWithView:(UIView *)view container:(UIViewController *)container;
/**
 *  Called when performing a custom accessibility action. Moves the view to the next corner of the
 *  screen clockwise.
 *
 *  @param action The accessibility action invoking this method.
 *  @return YES.
 */
- (BOOL)_performRotateClockwiseAction:(UIAccessibilityCustomAction *)action;

@end

@implementation GSCXCornerConstraints

- (instancetype)initWithView:(UIView *)view container:(UIViewController *)container {
  self = [super init];
  if (self) {
    NSAssert(view.superview == container.view, @"view must be a subview of container.");
    NSArray<NSLayoutConstraint *> *bottomLeadingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeLeading
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *topLeadingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeLeading
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.topLayoutGuide
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *topTrailingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeTrailing
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.topLayoutGuide
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *bottomTrailingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeTrailing
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset]
    ];
    self.constraintSets = @[
      bottomLeadingConstraints, topLeadingConstraints, topTrailingConstraints,
      bottomTrailingConstraints
    ];
    [NSLayoutConstraint activateConstraints:bottomLeadingConstraints];
  }
  return self;
}

+ (instancetype)constraintsWithView:(UIView *)view container:(UIViewController *)container {
  return [[GSCXCornerConstraints alloc] initWithView:view container:container];
}

- (void)rotateClockwise {
  [NSLayoutConstraint deactivateConstraints:self.constraintSets[self.currentConstraintsIndex]];
  self.currentConstraintsIndex = (self.currentConstraintsIndex + 1) % self.constraintSets.count;
  [NSLayoutConstraint activateConstraints:self.constraintSets[self.currentConstraintsIndex]];
}

- (NSArray<UIAccessibilityCustomAction *> *)rotateAccessibilityActions {
  return @[ [[UIAccessibilityCustomAction alloc]
      initWithName:kGSCXCornerConstraintRotateClockwiseName
            target:self
          selector:@selector(_performRotateClockwiseAction:)] ];
}

- (BOOL)_performRotateClockwiseAction:(UIAccessibilityCustomAction *)action {
  [self rotateClockwise];
  return YES;
}

@end
