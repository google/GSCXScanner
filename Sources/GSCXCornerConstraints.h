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
 *  Encapsulates functionality to snap a view to screen corners using Autolayout constraints.
 */
@interface GSCXCornerConstraints : NSObject

- (instancetype)init NS_UNAVAILABLE;
/**
 *  Constructs a GSCXCornerConstraints object with a given view inside a given container. The view
 *  starts in the bottom leading (left in LTR languages, right in RTL languages) corner.
 *
 *  @param view The view to snap to different corners of the container.
 *  @param container The view controller whose view contains @c view. @c view must be a subview of
 *                   container's view.
 */
+ (instancetype)constraintsWithView:(UIView *)view container:(UIViewController *)container;

/**
 *  Snaps the view to the next corner of the screen in the clockwise direction.
 */
- (void)rotateClockwise;

/**
 *  Returns an array of custom actions used to invoke rotation actions from VoiceOver.
 */
- (NSArray<UIAccessibilityCustomAction *> *)rotateAccessibilityActions;

@end

NS_ASSUME_NONNULL_END
