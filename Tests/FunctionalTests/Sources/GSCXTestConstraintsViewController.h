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

#import <UIKit/UIKit.h>

#import "GSCXTestPage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Accessibility identifier for the test constraints view controller's @c mainView.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestConstraintsMainViewAccessibilityIdentifier;

/**
 * Accessibility identifier for the test constraints view controller's @c entirelyCoveringView.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestConstraintsEntirelyCoveringViewAccessibilityIdentifier;

/**
 * Accessibility identifier for the test constraints view controller's @c centeredView.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestConstraintsCenteredViewAccessibilityIdentifier;

/**
 * Accessibility identifier for the test constraints view controller's @c aspectRatioView.
 */
FOUNDATION_EXTERN NSString *const kGSCXTestConstraintsAspectRatioViewAccessibilityIdentifier;

/**
 * Contains elements arranged using the @c NSLayoutConstraint+GSCXUtilities category so their
 * behavior can be tested.
 */
@interface GSCXTestConstraintsViewController : UIViewController <GSCXTestPage>

/**
 * The frame in the top left corner acting as the anchor for all other views.
 */
@property(strong, nonatomic) UIView *mainView;

/**
 * A subview of @c mainView which completely covers it.
 */
@property(strong, nonatomic) UIView *entirelyCoveringView;

/**
 * A sibling view of @c mainView which is centered on @c mainView but has padding on the edges.
 */
@property(strong, nonatomic) UIView *centeredView;

/**
 * A sibling view of @c mainView which is beneath @c mainView, has the same width, but a fixed
 * aspect ratio.
 */
@property(strong, nonatomic) UIView *aspectRatioView;

@end

NS_ASSUME_NONNULL_END
