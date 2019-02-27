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

#import "GSCXTestViewController.h"

#import "GSCXTestScannerViewController.h"
#import "GSCXTestUIAccessibilityElementViewController.h"
#import "GSCXUITestViewController.h"

NSString *const kMainTableViewAccessibilityId = @"kMainTableViewAccessibilityId";
/**
 *  The cell reuse identifier for the table view.
 */
static NSString *const kGSCXTestTableViewReuseIdentifier = @"kGSCXTestTableViewReuseIdentifier";

@interface GSCXTestViewController ()

@property(strong, nonatomic) NSArray<Class<GSCXTestPage>> *controllerClasses;

@end

@implementation GSCXTestViewController

- (void)viewDidLoad {
  self.title = [GSCXTestViewController pageName];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.accessibilityIdentifier = kMainTableViewAccessibilityId;
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:kGSCXTestTableViewReuseIdentifier];
  self.controllerClasses =
      @ [[GSCXUITestViewController class], [GSCXTestScannerViewController class],
         [GSCXTestUIAccessibilityElementViewController class]];
}

+ (NSString *)accessibilityIdentifierOfCellForPage:(Class<GSCXTestPage>)pageClass {
  return [NSString stringWithFormat:@"%@_%@", [self pageName], [pageClass pageName]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSAssert(section == 0, @"GSCXTestViewController should not have multiple sections.");
  return (NSInteger)[self.controllerClasses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:kGSCXTestTableViewReuseIdentifier
                                      forIndexPath:indexPath];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  Class<GSCXTestPage> controllerClass = self.controllerClasses[(NSUInteger)indexPath.row];
  cell.textLabel.text = [controllerClass pageName];
  cell.accessibilityIdentifier =
      [GSCXTestViewController accessibilityIdentifierOfCellForPage:controllerClass];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Class viewControllerClass = self.controllerClasses[(NSUInteger)indexPath.row];
  UIViewController *viewController =
      [[viewControllerClass alloc] initWithNibName:NSStringFromClass(viewControllerClass)
                                            bundle:nil];
  [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - GSCXTestPage

+ (NSString *)pageName {
  return @"mainTestPage";
}

@end
