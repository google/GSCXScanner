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

#import "GSCXColoredView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A cell in the grid view.
 */
@interface GSCXContinuousScannerGridCell : UICollectionViewCell

/**
 * Displays a screenshot of the screen when the scan occurred.
 */
@property(strong, nonatomic, readonly) UIImageView *screenshot;

/**
 * Displays how many issues the scan represented by this cell contains.
 */
@property(strong, nonatomic, readonly) UILabel *badge;

/**
 * The background of the badge. Setting the badge's background color directly causes the mask to be
 * set incorrectly when Autolayout changes its frame. Using a separate view resolves this.
 */
@property(strong, nonatomic, readonly) GSCXColoredView *badgeBackground;

/**
 * Constrains @c screenshot to have the correct aspect ratio. It is the responsibility of the
 * collection view's data source to set this.
 */
@property(strong, nonatomic) NSLayoutConstraint *aspectRatioConstraint;

@end

NS_ASSUME_NONNULL_END
