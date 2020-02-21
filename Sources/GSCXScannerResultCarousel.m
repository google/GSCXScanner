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

#import "GSCXScannerResultCarousel.h"

#import "GSCXRingView.h"
#import "GSCXScannerResultCarouselCollectionViewCell.h"
#import "GSCXScannerResultCarouselView.h"
#import "NSLayoutConstraint+GSCXUtilities.h"
#import <GTXiLib/GTXiLib.h>
/**
 * The reuse identifier for cells in a @c GSCXScannerResultCarousel view.
 */
static NSString *const kGSCXScannerResultCarouselReuseIdentifier =
    @"kGSCXScannerResultCarouselReuseIdentifier";

/**
 * The spacing on the leading and trailing sides of carousel cells.
 */
static const CGFloat kHorizontalSpacing = 10.0;

/**
 * The spacing above and beneath carousel cells.
 */
static const CGFloat kVerticalSpacing = 10.0;

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerResultCarousel () <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 * Copies of the screenshots for each scan result. Copies are needed to avoid mutating the original
 * screenshot.
 */
@property(strong, nonatomic) NSArray<UIView *> *resultScreenshots;

/**
 * Configures the display of the carousel.
 */
@property(strong, nonatomic) UICollectionViewFlowLayout *layout;

/**
 * The scan results to be displayed.
 */
@property(strong, nonatomic, readonly) NSArray<GSCXScannerResult *> *results;

/**
 * The index of the currently selected scan. Defaults to 0.
 */
@property(assign, nonatomic, readonly) NSUInteger selectedIndex;

/**
 * Invoked when the user selects a new scan result.
 */
@property(copy, nonatomic) GSCXScannerResultCarouselBlock selectionBlock;

@end

@implementation GSCXScannerResultCarousel

- (instancetype)initWithResults:(NSArray<GSCXScannerResult *> *)results
                 selectionBlock:(GSCXScannerResultCarouselBlock)selectionBlock {
  self = [super init];
  if (self != nil) {
    _results = results;
    _selectionBlock = selectionBlock;
    NSMutableArray<UIView *> *resultScreenshots =
        [NSMutableArray arrayWithCapacity:[results count]];
    for (GSCXScannerResult *result in results) {
      UIView *screenshot = [result.screenshot snapshotViewAfterScreenUpdates:YES];
      screenshot.translatesAutoresizingMaskIntoConstraints = NO;
      [resultScreenshots addObject:screenshot];
    }
    _resultScreenshots = resultScreenshots;
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.minimumInteritemSpacing = kHorizontalSpacing;
    _carouselView = [[GSCXScannerResultCarouselView alloc] initWithFrame:CGRectZero
                                                    collectionViewLayout:_layout];
    _carouselView.backgroundColor = [UIColor clearColor];
    _carouselView.contentInset = UIEdgeInsetsMake(0.0, kHorizontalSpacing, 0.0, kHorizontalSpacing);
    _carouselView.translatesAutoresizingMaskIntoConstraints = NO;
    _carouselView.delegate = self;
    _carouselView.dataSource = self;
    _carouselView.allowsSelection = YES;
    _carouselView.isAccessibilityElement = YES;
    _carouselView.accessibilityValue = @"Scan 1";
    _carouselView.accessibilityLabel =
        [NSString stringWithFormat:@"%lu issues", _results[0].issueCount];
    [_carouselView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                animated:NO
                          scrollPosition:UICollectionViewScrollPositionNone];
    [_carouselView registerClass:[GSCXScannerResultCarouselCollectionViewCell class]
        forCellWithReuseIdentifier:kGSCXScannerResultCarouselReuseIdentifier];
  }
  return self;
}

- (void)focusResultAtIndex:(NSUInteger)index animated:(BOOL)animated {
  _selectedIndex = index;
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
  [self.carouselView selectItemAtIndexPath:indexPath
                                  animated:animated
                            scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  __kindof UICollectionViewCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:kGSCXScannerResultCarouselReuseIdentifier
                                forIndexPath:indexPath];
  cell.isAccessibilityElement = NO;
  if ([cell isKindOfClass:[GSCXScannerResultCarouselCollectionViewCell class]]) {
    GSCXScannerResultCarouselCollectionViewCell *carouselCell =
        (GSCXScannerResultCarouselCollectionViewCell *)cell;
    [self gscx_removeSelectionHighlightFromCell:carouselCell];
    // If the user swipes the carousel back and forth rapidly, it is possible for the screenshot
    // to disappear. This occurs when a cell that just left the screen contained the screenshot
    // that is being added to this cell. The screenshot will be added as a subview to that cell,
    // which automatically removes it from this one. However, the screenshot property is not set to
    // nil, because the cell cannot access the screenshot's current cell. Thus, when this cell is
    // reused, it removes the screenshot from the superview, which is no longer this cell. This
    // removes it from its new, correct cell, disappearing the screenshot. Only removing screenshots
    // that are still in the current cell solves this.
    if (carouselCell.screenshot.superview == carouselCell.contentView) {
      [carouselCell.screenshot removeFromSuperview];
    }
    carouselCell.screenshot = self.resultScreenshots[indexPath.row];
    [carouselCell.contentView addSubview:carouselCell.screenshot];
    [NSLayoutConstraint gscx_constraintsToFillSuperviewWithView:carouselCell.screenshot
                                                      activated:YES];
    if ((NSUInteger)indexPath.row == self.selectedIndex) {
      [self gscx_addSelectionHighlightToCell:carouselCell];
    }
  }
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  UIView *screenshot = self.results[indexPath.row].screenshot;
  CGFloat height = collectionView.frame.size.height - 2.0 * kVerticalSpacing;
  if (screenshot == nil) {
    return CGSizeMake(height, height);
  }
  CGFloat aspectRatio = screenshot.frame.size.width / screenshot.frame.size.height;
  return CGSizeMake(aspectRatio * height, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.results.count;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self gscx_removeSelectionHighlightFromCurrentlySelectedCellInCollectionView:collectionView];
  _selectedIndex = (NSUInteger)indexPath.row;
  [self gscx_setAccessibilityOfCarouselForResultAtIndex:self.selectedIndex];
  self.selectionBlock(self.selectedIndex, self.results[self.selectedIndex]);
  UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
  if (cell == nil || ![cell isKindOfClass:[GSCXScannerResultCarouselCollectionViewCell class]]) {
    return;
  }
  GSCXScannerResultCarouselCollectionViewCell *carouselCell =
      (GSCXScannerResultCarouselCollectionViewCell *)cell;
  [self gscx_addSelectionHighlightToCell:carouselCell];
}

#pragma mark - Private

- (void)gscx_setAccessibilityOfCarouselForResultAtIndex:(NSUInteger)index {
  GTX_ASSERT(index < self.results.count, @"index must be within bounds");
  self.carouselView.accessibilityLabel =
      [NSString stringWithFormat:@"%lu issues", self.results[index].issueCount];
  self.carouselView.accessibilityValue = [NSString stringWithFormat:@"Scan %lu\n", index + 1];
}

/**
 * Removes the selection highlight from the currently selected scan result, if it is visible.
 *
 * @param collectionView The collection view containing the selected cell to remove the highlight
 * of.
 */
- (void)gscx_removeSelectionHighlightFromCurrentlySelectedCellInCollectionView:
    (UICollectionView *)collectionView {
  NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:(NSInteger)self.selectedIndex
                                                       inSection:0];
  UICollectionViewCell *previouslySelectedCell =
      [collectionView cellForItemAtIndexPath:previousIndexPath];
  if (previouslySelectedCell != nil &&
      [previouslySelectedCell isKindOfClass:[GSCXScannerResultCarouselCollectionViewCell class]]) {
    GSCXScannerResultCarouselCollectionViewCell *previousCarouselCell =
        (GSCXScannerResultCarouselCollectionViewCell *)previouslySelectedCell;
    [self gscx_removeSelectionHighlightFromCell:previousCarouselCell];
  }
}

/**
 * Removes the selection highlight from @c cell. If the cell is not highlighted, does nothing.
 *
 * @param cell The cell to remove the highlight from.
 */
- (void)gscx_removeSelectionHighlightFromCell:(GSCXScannerResultCarouselCollectionViewCell *)cell {
  [cell.selectionHighlight removeFromSuperview];
  cell.selectionHighlight = nil;
}

/**
 * Adds a highlight to @c cell to mark it as selected. If the cell is already highlighted, does
 * nothing.
 *
 * @param cell The cell to highlight.
 */
- (void)gscx_addSelectionHighlightToCell:(GSCXScannerResultCarouselCollectionViewCell *)cell {
  if (cell.selectionHighlight != nil) {
    return;
  }
  GSCXRingView *selectionHighlight = [GSCXRingView ringViewAroundFocusRect:cell.contentView.bounds];
  selectionHighlight.isAccessibilityElement = NO;
  cell.selectionHighlight = selectionHighlight;
  [cell.contentView addSubview:selectionHighlight];
}

@end

NS_ASSUME_NONNULL_END
