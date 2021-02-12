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

#import "GSCXContinuousScannerListViewController.h"

#import "GSCXContinuousScannerGalleryViewController.h"
#import "GSCXScannerIssueExpandableTableViewCell.h"
#import "GSCXScannerIssueExpandableTableViewDelegate.h"
#import "GSCXScannerIssueExpandableTableViewHeader.h"
#import "UIViewController+GSCXAppearance.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXContinuousScannerListTableViewAccessibilityIdentifier =
    @"kGSCXContinuousScannerListTableViewAccessibilityIdentifier";

@interface GSCXContinuousScannerListViewController ()

/**
 * Displays the data in @c sections in @c tableView.
 */
@property(strong, nonatomic) GSCXScannerIssueExpandableTableViewDelegate *tableViewDelegate;

/**
 * Displays the list of issues.
 */
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GSCXContinuousScannerListViewController

- (instancetype)initWithSections:(NSArray<GSCXScannerIssueTableViewSection *> *)sections {
  self = [super
      initWithNibName:@"GSCXContinuousScannerListViewController"
               bundle:[NSBundle bundleForClass:[GSCXContinuousScannerListViewController class]]];
  if (self) {
    __weak __typeof__(self) weakSelf = self;
    _tableViewDelegate = [[GSCXScannerIssueExpandableTableViewDelegate alloc]
        initWithSections:sections
          selectionBlock:^(GTXHierarchyResultCollection *result, NSInteger issueIndex) {
            [weakSelf gscx_presentGalleryViewWithResult:result issueIndex:issueIndex];
          }];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  self.tableView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  self.tableView.dataSource = self.tableViewDelegate;
  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.accessibilityIdentifier =
      kGSCXContinuousScannerListTableViewAccessibilityIdentifier;
  [self.tableViewDelegate registerClassesForReuseOnTableView:self.tableView];
  [self gscx_setColorsOfTableViewDelegateForCurrentAppearance];
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self gscx_setColorsOfTableViewDelegateForCurrentAppearance];
}

#pragma mark - Private

/**
 * Presents the gallery view displaying the scan associated with @c result, focusing on the issue at
 * @c issueIndex.
 *
 * @param result The scan result to display in the gallery view.
 * @param issueIndex The index of the issue in @c result to focus in the gallery view.
 */
- (void)gscx_presentGalleryViewWithResult:(GTXHierarchyResultCollection *)result
                               issueIndex:(NSInteger)issueIndex {
  GSCXContinuousScannerGalleryViewController *galleryView =
      [[GSCXContinuousScannerGalleryViewController alloc]
          initWithNibName:@"GSCXContinuousScannerGalleryViewController"
                   bundle:[NSBundle
                              bundleForClass:[GSCXContinuousScannerGalleryViewController class]]
                   result:result];
  [galleryView focusIssueAtIndex:issueIndex animated:NO];
  [self.navigationController pushViewController:galleryView animated:YES];
}

/**
 * Sets the background and text colors of the cells and headers of @c tableView.
 */
- (void)gscx_setColorsOfTableViewDelegateForCurrentAppearance {
  UIColor *backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  UIColor *textColor = [self gscx_textColorForCurrentAppearance];
  [self.tableViewDelegate setTextColor:textColor
                       backgroundColor:backgroundColor
                           onTableView:self.tableView];
}

@end

NS_ASSUME_NONNULL_END
