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

NS_ASSUME_NONNULL_BEGIN

/**
 * Invoked when a @c GSCXScannerResultCarousel changes selection.
 *
 * @param index The index of the newly selected element.
 * @param result The result displayed at the new index.
 */
typedef void (^GSCXScannerResultCarouselBlock)(NSUInteger index, GSCXScannerResult *result);

/**
 * A scrollable list of screenshots associated with scan results. Users may select results. This
 * object's owner can listen for changes to display information on the selection.
 */
@interface GSCXScannerResultCarousel : NSObject

/**
 * A carousel of scan screenshots.
 */
@property(strong, nonatomic) UICollectionView *carouselView;

/**
 * Initializes a @c GSCXScannerResultCarousel with the given results to display and selection
 * callback.
 *
 * @param result The results to display.
 * @param selectionBlock A callback invoked when the selected result changes.
 * @return An initialized @c GSCXScannerResultCarousel instance.
 */
- (instancetype)initWithResults:(NSArray<GSCXScannerResult *> *)results
                 selectionBlock:(GSCXScannerResultCarouselBlock)selectionBlock;

/**
 * Changes the selected scan result to the result at @c index. Does not invoke @c selectionBlock.
 * The caller is responsible for updating any state.
 *
 * @param index The index of the scan result to select.
 * @param animated @c YES if the transition should be animated, @c NO otherwise.
 */
- (void)focusResultAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
