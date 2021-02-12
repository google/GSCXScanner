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

#import "GSCXOverlayViewArranger.h"

#import "UIView+NSLayoutConstraint.h"
#import <GTXiLib/GTXiLib.h>
/**
 * The offset between the the superview being snapped to and the view being snapped, in points.
 */
static const CGFloat kGSCXCornerConstraintOffset = 16.0;

/**
 * The name of the action that rotates the view to the next corner of the screen clockwise. Spoken
 * by VoiceOver.
 */
static NSString *const kGSCXCornerConstraintRotateClockwiseName = @"Rotate Clockwise";

@interface GSCXOverlayViewArranger ()

/**
 * The view to arrange the position of.
 */
@property(strong, nonatomic) UIView *overlayView;

/**
 * Array of arrays of constraints. Each underlying array represents the constraints needed to
 * snap a view to a different corner of the screen. The first constraint set snaps to the bottom
 * left, and each successive constraint set snaps to the next corner, clockwise.
 */
@property(copy, nonatomic) NSArray<NSArray<NSLayoutConstraint *> *> *constraintSets;

/**
 * The index in @c constraintSets of the currently active constraints.
 */
@property(assign, nonatomic) NSUInteger currentConstraintsIndex;

/**
 * The difference between the initial point of a gesture and the center of the settings button. This
 * value is subtracted from the current gesture's position to get the new center of the settings
 * button. This is necessary because otherwise the button's center will snap to the gesture's
 * location at the beginning of the gesture (because the user might not press directly at the
 * center).
 */
@property(assign, nonatomic) CGPoint settingsDragInitialOffset;

@end

@implementation GSCXOverlayViewArranger

/**
 * Initializes a @c GSCXOverlayViewArranger object with a given view inside a given container. The
 * view starts in the bottom leading (left in LTR languages, right in RTL languages) corner.
 *
 * @param view The view to snap to different corners of the container.
 * @param container The view controller whose view contains @c view. @c view must be a subview of
 * container's view.
 */
- (instancetype)initWithView:(UIView *)view container:(UIViewController *)container {
  self = [super init];
  if (self) {
    GTX_ASSERT(view.superview == container.view, @"view must be a subview of container.");
    _overlayView = view;
    NSArray<NSLayoutConstraint *> *bottomLeadingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeLeading
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *topLeadingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeLeading
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *topTrailingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeTrailing
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:kGSCXCornerConstraintOffset]
    ];
    NSArray<NSLayoutConstraint *> *bottomTrailingConstraints = @[
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeTrailing
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset],
      [NSLayoutConstraint constraintWithItem:view
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:container.view.gscx_safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:-kGSCXCornerConstraintOffset]
    ];
    _constraintSets = @[
      bottomLeadingConstraints, topLeadingConstraints, topTrailingConstraints,
      bottomTrailingConstraints
    ];
    [NSLayoutConstraint activateConstraints:bottomLeadingConstraints];
  }
  return self;
}

- (void)rotateClockwise {
  [NSLayoutConstraint deactivateConstraints:_constraintSets[_currentConstraintsIndex]];
  _currentConstraintsIndex = (_currentConstraintsIndex + 1) % _constraintSets.count;
  [NSLayoutConstraint activateConstraints:_constraintSets[_currentConstraintsIndex]];
}

- (NSArray<UIAccessibilityCustomAction *> *)rotateAccessibilityActions {
  return @[ [[UIAccessibilityCustomAction alloc]
      initWithName:kGSCXCornerConstraintRotateClockwiseName
            target:self
          selector:@selector(gscx_performRotateClockwiseAction:)] ];
}

- (void)handleDragForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
  NSParameterAssert([gestureRecognizer isKindOfClass:[UIGestureRecognizer class]]);
  CGPoint location = [gestureRecognizer locationInView:self.overlayView.superview];
  switch (gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan:
      self.settingsDragInitialOffset = CGPointMake(location.x - self.overlayView.center.x,
                                                   location.y - self.overlayView.center.y);
      break;
    default:
      self.overlayView.center = [self gscx_centerOfOverlayViewForGestureLocation:location];
      break;
  }
}

#pragma mark - Private

/**
 * Called when performing a custom accessibility action. Moves the view to the next corner of the
 * screen clockwise.
 *
 * @param action The accessibility action invoking this method.
 * @return YES.
 */
- (BOOL)gscx_performRotateClockwiseAction:(UIAccessibilityCustomAction *)action {
  [self rotateClockwise];
  return YES;
}

/**
 * Calculates the center of @c overlayView based on the initial and current location of the gesture
 * recognizer, constrained to the safe area of @c overlayView.superview.
 *
 * @param location The current location of the drag gesture recognizer in @c ovverlayView's
 * superview.
 * @return The center of @c overlayView so it is at the same spot as the gesture location without
 * going outside the safe area.
 */
- (CGPoint)gscx_centerOfOverlayViewForGestureLocation:(CGPoint)location {
  CGRect safeArea = [self gscx_safeAreaForOverlayView];
  CGFloat x = MIN(MAX(location.x - self.settingsDragInitialOffset.x, CGRectGetMinX(safeArea)),
                  CGRectGetMaxX(safeArea));
  CGFloat y = MIN(MAX(location.y - self.settingsDragInitialOffset.y, CGRectGetMinY(safeArea)),
                  CGRectGetMaxY(safeArea));
  return CGPointMake(x, y);
}

/**
 * @return The rect in which @c overlayView's center is allowed to be in to stay within the screen
 * and safe area.
 */
- (CGRect)gscx_safeAreaForOverlayView {
  CGRect superviewBounds = self.overlayView.superview.bounds;
  UIEdgeInsets safeAreaInsets = [self.overlayView.superview gscx_safeAreaInsets];
  CGFloat halfWidth = CGRectGetWidth(self.overlayView.frame) / 2.0;
  CGFloat halfHeight = CGRectGetHeight(self.overlayView.frame) / 2.0;
  UIEdgeInsets viewInsets = UIEdgeInsetsMake(halfHeight, halfWidth, halfHeight, halfWidth);
  return UIEdgeInsetsInsetRect(UIEdgeInsetsInsetRect(superviewBounds, safeAreaInsets), viewInsets);
}

@end
