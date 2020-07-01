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
 * Displays a screenshot associated with a scan result. If selected, displays a view highlighting
 * the screenshot.
 */
@interface GSCXScannerResultCarouselCollectionViewCell : UICollectionViewCell

/**
 * Displays a screenshot of the screen when the scan occurred.
 */
@property(strong, nonatomic, readonly) UIImageView *screenshot;

/**
 * A view displayed over the screenshot when this cell is selected.
 */
@property(strong, nonatomic, nullable) UIView *selectionHighlight;

@end

NS_ASSUME_NONNULL_END
