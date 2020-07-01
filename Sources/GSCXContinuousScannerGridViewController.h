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

#import "GSCXScannerResult.h"
#import "GSCXScannerResultCarousel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Displays a grid of screenshots representing scan results. Users can tap on the screenshots to
 * display detailed information.
 */
@interface GSCXContinuousScannerGridViewController
    : UICollectionViewController <UINavigationControllerDelegate>

/**
 * Initializes this instance by loading from the default xib with the given results.
 *
 * @param results The results to display.
 * @param selectionBlock Invoked when the user selects a scan result in the grid.
 * @return An initialized @c GSCXContinuousScannerGridViewController instance.
 */
- (instancetype)initWithResults:(NSArray<GSCXScannerResult *> *)results
                 selectionBlock:(GSCXScannerResultCarouselBlock)selectionBlock;

/**
 * Returns the accessibility identifier for the grid cell at @c index.
 *
 * @param index The index of the cell to determine the accessibility identifier for.
 * @return The accessibility identifier uniquely identifying the cell.
 */
+ (NSString *)accessibilityIdentifierForCellAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
