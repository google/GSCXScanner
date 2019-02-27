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

#import "GSCXScannerTestCase.h"

#import <XCTest/XCTest.h>

#import "GSCXScanner.h"
#import "GSCXTestViewController.h"
#import "third_party/objective_c/EarlGrey/EarlGrey/EarlGrey.h"

@implementation GSCXScannerTestCase

// Cleans up after each test case is run. Navigates to the original app screen so other test cases
// start from a valid state.
- (void)tearDown {
  UIWindow *delegateWindow = [UIApplication sharedApplication].delegate.window;
  UINavigationController *navController;
  if ([delegateWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
    navController = (UINavigationController *)delegateWindow.rootViewController;
  } else {
    navController = delegateWindow.rootViewController.navigationController;
  }
  [navController popToRootViewControllerAnimated:YES];
  [[GREYConfiguration sharedInstance] reset];

  [super tearDown];
}

- (void)openPage:(Class<GSCXTestPage>)pageClass {
  NSString *accessibilityId =
      [GSCXTestViewController accessibilityIdentifierOfCellForPage:pageClass];
  // Attempt to open the named view. The views are listed as a rows of a UITableView and tapping it
  // opens the view.
  NSError *error;
  id<GREYMatcher> cellMatcher = grey_accessibilityID(accessibilityId);
  [[EarlGrey selectElementWithMatcher:cellMatcher] performAction:grey_tap() error:&error];
  if (!error) {
    return;
  }
  // The view is probably not visible, scroll to top of the table view and go searching for it.
  [[EarlGrey selectElementWithMatcher:grey_kindOfClass([UITableView class])]
      performAction:grey_scrollToContentEdge(kGREYContentEdgeTop)];
  // Scroll to the cell we need and tap it.
  [[[EarlGrey selectElementWithMatcher:grey_allOf(cellMatcher, grey_interactable(), nil)]
         usingSearchAction:grey_scrollInDirection(kGREYDirectionDown, 200)
      onElementWithMatcher:grey_kindOfClass([UITableView class])] performAction:grey_tap()];
}

@end
