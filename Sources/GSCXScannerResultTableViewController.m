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

#import "GSCXScannerResultTableViewController.h"

#import "GSCXScannerResultDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Reuse identifier for GSCXScannerResultTableViewController's table view cells.
 */
static NSString *const kGSCXScannerResultCellReuseIdentifier =
    @"kGSCXScannerResultCellReuseIdentifier";

@implementation GSCXScannerResultTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kGSCXScannerResultCellReuseIdentifier];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSParameterAssert(section == 0);
  return (NSInteger)self.scanResult.issueCount;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kGSCXScannerResultCellReuseIdentifier
                                      forIndexPath:indexPath];
  cell.textLabel.text = [self.scanResult gtxCheckNameAtIndex:(NSUInteger)indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  GSCXScannerResultDetailViewController *detailController =
      [[GSCXScannerResultDetailViewController alloc]
          initWithNibName:@"GSCXScannerResultDetailViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerResultDetailViewController class]]];
  [detailController setScanResult:self.scanResult issueIndex:(NSUInteger)indexPath.row];
  [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - GSCXWindowOverlayViewController

- (BOOL)isTransparentOverlay {
  return NO;
}

@end

NS_ASSUME_NONNULL_END
