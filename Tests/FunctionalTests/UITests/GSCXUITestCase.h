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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GSCXTestPage.h"

/**
 *  Base class for UI tests. Encapsulates functionality to navigate to the
 *  correct page on set up and terminate the app on tear down.
 */
@interface GSCXUITestCase : XCTestCase

/**
 *  The application corresponding to the host app.
 */
@property(strong, nonatomic) XCUIApplication *app;

/**
 *  Determines if the overlay window of the host app is transparent (forwards
 *  hits) or opaque (does not forward hits).
 *
 *  @return YES if the overlay window is transparent, NO otherwise. Defaults to
 *  YES.
 */
- (BOOL)isApplicationOverlayTransparent;

/**
 *  Taps the cell with the given accessibility identifier in the main table view. Scrolls the table
 *  view down until the cell is visible before tapping. If no cell exists in the main table view
 *  with the given accessibility identifier, then the test fails and no scrolling is performed.
 *
 *  @param accessibilityIdentifier The accessibility identifier of the cell to be tapped.
 */
- (void)tapCellWithIdentifier:(NSString *)accessibilityIdentifier;

/**
 *  Scrolls the table view with the given accessibility identifier down so the cell with the given
 *  accessibility identifier is visible. If the cell does not exist in the table, then the test
 *  fails.
 *
 *  @param tableViewIdentifier The accessibility identifier of the table view to scroll.
 *  @param cellIdentifier The accessibility identifier of the cell to scroll to.
 */
- (void)tableViewMatchingIdentifier:(NSString *)tableViewIdentifier
                   dragUntilVisible:(NSString *)cellIdentifier;

/**
 *  Asserts that the view controller corresponding to the given page is visible. If not, the test
 *  fails.
 *
 *  @param pageClass The class corresponding to GSCXPage representing a page of the app.
 */
- (BOOL)assertOnPage:(Class<GSCXTestPage>)pageClass;

@end
