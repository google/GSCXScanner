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

NS_ASSUME_NONNULL_BEGIN

/**
 * Encapsulates information on a @c GTXElementResultCollection instance. This object's owner is
 * responsible for constraining @c containerView and @c stackView to the desired sizes.
 */
@interface GSCXContinuousScannerGalleryDetailViewData : NSObject

/**
 * Contains @c stackView. If @c stackView's size is less than @c containerView's, scrolling is
 * disabled. Otherwise, vertical scrolling is enabled.
 */
@property(strong, nonatomic) UIScrollView *containerView;

/**
 * Contains descriptions for all issues related to a @c GSCXScannerIssue instance. Add text to
 * @c stackView using @c addIssueWithTitle:
 */
@property(strong, nonatomic) UIStackView *stackView;

/**
 * The background color of the scroll view.
 */
@property(strong, nonatomic) UIColor *backgroundColor;

/**
 * The text color of the labels.
 */
@property(strong, nonatomic) UIColor *textColor;

/**
 * Adds @c title and @c contents to the bottom of @c stackView.
 */
- (void)addCheckWithTitle:(NSString *)title contents:(NSString *)contents;

/**
 * Updates the content size of @c containerView based on @c stackView. The owner is responsible for
 * calling this method.
 */
- (void)didLayoutSubviews;

@end

NS_ASSUME_NONNULL_END
