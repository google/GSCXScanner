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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Manages the position of a view in a window overlaid on an application. The view must be
 * moveable, since anywhere the view is on screen may obscure the application UI. Actions to move
 * the view are exposed to accessibility features.
 */
@interface GSCXOverlayViewArranger : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXOverlayViewArranger object with a given view inside a given container. The
 * view starts in the bottom leading (left in LTR languages, right in RTL languages) corner.
 *
 * @param view The view to snap to different corners of the container.
 * @param container The view controller whose view contains @c view. @c view must be a subview of
 * container's view.
 * @return An initialized @c GSCXOverlayViewArranger object.
 */
- (instancetype)initWithView:(UIView *)view
                   container:(UIViewController *)container NS_DESIGNATED_INITIALIZER;

/**
 * Snaps the view to the next corner of the screen in the clockwise direction.
 */
- (void)rotateClockwise;

/**
 * Returns an array of custom actions used to invoke rotation actions from VoiceOver.
 */
- (NSArray<UIAccessibilityCustomAction *> *)rotateAccessibilityActions;

/**
 * Moves the underlying view to follow the gesture. Does not allow the user to drag the view beyond
 * the safe area.
 *
 * @param gestureRecognizer The gesture recognizer associated with this drag.
 */
- (void)handleDragForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

@end

NS_ASSUME_NONNULL_END
