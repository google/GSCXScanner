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

#import "GSCXContinuousScannerGridViewController.h"

#import "GSCXContinuousScannerGridCell.h"
#import "GSCXContinuousScannerScreenshotViewController.h"
#import "NSLayoutConstraint+GSCXUtilities.h"
#import "UIViewController+GSCXAppearance.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * Reuse identifier for cells in @c GSCXContinuousScannerGridViewController.
 */
static NSString *const kGSCXContinuousScannerGridCellReuseIdentifier =
    @"kGSCXContinuousScannerGridCellReuseIdentifier";

/**
 * The spacing on the leading and trailing sides between collection view cells.
 */
static const CGFloat kGridViewHorizontalSpacing = 15.0;

/**
 * The spacing on the top and bottom sides between collection view cells.
 */
static const CGFloat kGridViewVerticalSpacing = 10.0;

/**
 * The width of grid cell badges.
 */
static const CGFloat kGridCellBadgeWidth = 40.0;

/**
 * The height of grid cell badges.
 */
static const CGFloat kGridCellBadgeHeight = 32.0;

/**
 * The corner radius of the top left corner of grid cell badges.
 */
static const CGFloat kGridCellBadgeCornerRadius = 10.0;

/**
 * The number of cells per row in the grid view when the first screenshot is in portrait and the
 * device is in portrait.
 */
static const NSInteger kGSCXContinuousScannerGridCellsPerRowPortraitScreenshotInPortrait = 3;

/**
 * The number of cells per row in the grid view when the first screenshot is in portrait and the
 * device is in landscape.
 */
static const NSInteger kGSCXContinuousScannerGridCellsPerRowPortraitScreenshotInLandscape = 6;

/**
 * The number of cells per row in the grid view when the first screenshot is in landscape and the
 * device is in portrait.
 */
static const NSInteger kGSCXContinuousScannerGridCellsPerRowLandscapeScreenshotInPortrait = 2;

/**
 * The number of cells per row in the grid view when the first screenshot is in landscape and the
 * device is in landscape.
 */
static const NSInteger kGSCXContinuousScannerGridCellsPerRowLandscapeScreenshotInLandscape = 3;

@interface GSCXContinuousScannerGridViewController ()

/**
 * The results to display.
 */
@property(strong, nonatomic) NSArray<GSCXScannerResult *> *results;

/**
 * Invoked when the user selects an scan result in the grid.
 */
@property(copy, nonatomic) GSCXScannerResultCarouselBlock selectionBlock;

/**
 * The number of screenshots to display per row. This number assumes no device orientation changes
 * have occurred. If changes have occurred, the number of elements in each row may be different, and
 * it may be different row from row.
 */
@property(assign, nonatomic) NSInteger elementsPerRow;

@end

@implementation GSCXContinuousScannerGridViewController

- (instancetype)initWithResults:(NSArray<GSCXScannerResult *> *)results
                 selectionBlock:(GSCXScannerResultCarouselBlock)selectionBlock {
  NSString *nibName = @"GSCXContinuousScannerGridViewController";
  NSBundle *bundle = [NSBundle bundleForClass:[GSCXContinuousScannerGridCell class]];
  self = [super initWithNibName:nibName bundle:bundle];
  if (self != nil) {
    _results = results;
    _selectionBlock = selectionBlock;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self gscx_setElementsPerRowForScreenSize:self.view.frame.size];
  self.collectionView.contentInset =
      UIEdgeInsetsMake(kGridViewVerticalSpacing, kGridViewHorizontalSpacing,
                       kGridViewVerticalSpacing, kGridViewHorizontalSpacing);
  GTX_ASSERT([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]],
             @"collectionViewLayout must be UICollectionViewFlowLayout");
  UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
  layout.itemSize = CGSizeMake(100, 100);
  if (@available(iOS 11.0, *)) {
    layout.sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromSafeArea;
  }
  [self.collectionView registerClass:[GSCXContinuousScannerGridCell class]
          forCellWithReuseIdentifier:kGSCXContinuousScannerGridCellReuseIdentifier];
  self.collectionView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [self gscx_setElementsPerRowForScreenSize:size];
  [self.collectionView reloadData];
}

+ (NSString *)accessibilityIdentifierForCellAtIndex:(NSUInteger)index {
  return [NSString
      stringWithFormat:@"GSCXContinuousScannerGridViewController_Cell_%lu", (unsigned long)index];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return (NSInteger)self.results.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GSCXContinuousScannerGridCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:kGSCXContinuousScannerGridCellReuseIdentifier
                                forIndexPath:indexPath];
  GTX_ASSERT([cell isKindOfClass:[GSCXContinuousScannerGridCell class]],
             @"Cell %@ must be an instance of GSCXContinuousScannerGridCell", cell);
  cell.accessibilityIdentifier = [GSCXContinuousScannerGridViewController
      accessibilityIdentifierForCellAtIndex:(NSUInteger)indexPath.item];
  cell.screenshot.image = self.results[indexPath.item].screenshot;
  [self gscx_constructBadgeForCell:cell];
  cell.badge.text =
      [NSString stringWithFormat:@"%ld", (long)self.results[indexPath.item].issueCount];
  NSUInteger issueCount = self.results[indexPath.item].issueCount;
  cell.badgeBackground.fillColor =
      issueCount > 0 ? [GSCXContinuousScannerGridViewController gscx_someIssuesBadgeColor]
                     : [GSCXContinuousScannerGridViewController gscx_noIssuesBadgeColor];
  NSString *pluralModifier = issueCount == 1 ? @"" : @"s";
  cell.isAccessibilityElement = YES;
  cell.accessibilityLabel = [NSString
      stringWithFormat:@"Scan with %lu issue%@", (unsigned long)issueCount, pluralModifier];
  if (cell.aspectRatioConstraint != nil) {
    [cell.screenshot removeConstraint:cell.aspectRatioConstraint];
  }
  CGFloat aspectRatio = cell.screenshot.image.size.width / cell.screenshot.image.size.height;
  cell.aspectRatioConstraint = [NSLayoutConstraint gscx_constraintWithView:cell.screenshot
                                                               aspectRatio:aspectRatio
                                                                 activated:YES];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  // All cells should have the same size, based on the first screenshot's orientation. The cell's
  // aspect ratio constraint ensures the screenshot has the correct size, regardless of orientation.
  UIImage *screenshot = self.results[0].screenshot;
  CGRect bounds = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset);
  if (@available(iOS 11.0, *)) {
    bounds = UIEdgeInsetsInsetRect(bounds, collectionView.safeAreaInsets);
  }
  CGFloat width = [self gscx_sizeOfCellWithContainerSize:bounds.size.width
                                                 spacing:kGridViewHorizontalSpacing];
  CGFloat aspectRatio = screenshot.size.width / screenshot.size.height;
  return CGSizeMake(width, width / aspectRatio);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  self.selectionBlock((NSUInteger)indexPath.item, self.results[indexPath.item]);
}

#pragma mark - UINavigationControllerDelegate

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:
    (UINavigationController *)navigationController {
  return 0;
}

#pragma mark - Private

/**
 * Sets @c elementsPerRow based on the size of the first scan result's screenshot and the given
 * screen size.
 *
 * @param screenSize The size of the screen to calculate the number of elements per row for.
 */
- (void)gscx_setElementsPerRowForScreenSize:(CGSize)screenSize {
  BOOL isScreenPortrait = screenSize.width < screenSize.height;
  BOOL isFirstResultPortrait =
      self.results[0].screenshot.size.width < self.results[0].screenshot.size.height;
  if (isFirstResultPortrait && isScreenPortrait) {
    self.elementsPerRow = kGSCXContinuousScannerGridCellsPerRowPortraitScreenshotInPortrait;
  } else if (isFirstResultPortrait && !isScreenPortrait) {
    self.elementsPerRow = kGSCXContinuousScannerGridCellsPerRowPortraitScreenshotInLandscape;
  } else if (!isFirstResultPortrait && isScreenPortrait) {
    self.elementsPerRow = kGSCXContinuousScannerGridCellsPerRowLandscapeScreenshotInPortrait;
  } else {
    // Screen and screenshot both landscape.
    self.elementsPerRow = kGSCXContinuousScannerGridCellsPerRowLandscapeScreenshotInLandscape;
  }
}

/**
 * Initializes the @c badge property of @c cell. Only needs to be called once per cell.
 *
 * @param cell The cell to initialize the badge of.
 */
- (void)gscx_constructBadgeForCell:(GSCXContinuousScannerGridCell *)cell {
  cell.badge.textAlignment = NSTextAlignmentCenter;
  cell.badge.textColor = [UIColor whiteColor];
  [cell.contentView addSubview:cell.badge];
  NSDictionary<NSString *, id> *views = @{@"badge" : cell.badge};
  NSDictionary<NSString *, NSNumber *> *metrics =
      @{@"width" : @(kGridCellBadgeWidth), @"height" : @(kGridCellBadgeHeight)};
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[badge(>=width)]|"
                                            verticalFormat:@"[badge(>=height)]|"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  cell.badgeBackground.cornerRadius = kGridCellBadgeCornerRadius;
  cell.badgeBackground.corners = UIRectCornerTopLeft;
}

/**
 * Calculates the size of a cell in one dimension based on the corresponding dimension of its
 * container view and a constant spacing between other cells.
 *
 * @param size Either the width or height of the cell's container view.
 * @param spacing The distance between cells and other cells and cells and the edge of the
 * container.
 * @return The size of the cell in one dimension to fit @c self.elementsPerRow cells with @c spacing
 * between cells in @c size points. If @c size is the container's width, this is the cell's width.
 * If @c size is the container's height, this is the cell's height.
 */
- (CGFloat)gscx_sizeOfCellWithContainerSize:(CGFloat)size spacing:(CGFloat)spacing {
  // For N cells, there are N + 1 blank spaces (one before each cell, and one after the last cell
  // before the superview's edge).
  return floor((size - (self.elementsPerRow + 1) * spacing) / self.elementsPerRow);
}

/**
 * The color of a grid cell's badge when the corresponding scan result contains no issues.
 */
+ (UIColor *)gscx_noIssuesBadgeColor {
  return [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
}

/**
 * The color of a grid cell's badge when the corresponding scan result contains at least one issue.
 */
+ (UIColor *)gscx_someIssuesBadgeColor {
  return [UIColor blueColor];
}

@end

NS_ASSUME_NONNULL_END
