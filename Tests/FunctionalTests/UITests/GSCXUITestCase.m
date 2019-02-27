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

#import "GSCXUITestCase.h"

#import "GSCXTestAppDelegate.h"
#import "GSCXTestViewController.h"
#import "XCUIElement+GSCXScanner.h"

@implementation GSCXUITestCase

- (void)setUp {
  [super setUp];
  self.app = [[XCUIApplication alloc] init];
  NSString *overlayType = [self isApplicationOverlayTransparent] ? kWindowOverlayTypeTransparent
                                                                 : kWindowOverlayTypeOpaque;
  self.app.launchEnvironment = @{kWindowOverlayTypeKey : overlayType};
  [self.app launch];
}

- (void)tearDown {
  [self.app terminate];

  [super tearDown];
}

- (void)tapCellWithIdentifier:(NSString *)accessibilityIdentifier {
  [self tableViewMatchingIdentifier:kMainTableViewAccessibilityId
                   dragUntilVisible:accessibilityIdentifier];
  XCUIElementQuery *tableQuery = [self.app.tables matchingIdentifier:kMainTableViewAccessibilityId];
  XCUIElement *cell = [[tableQuery.cells matchingIdentifier:accessibilityIdentifier] element];
  XCUICoordinate *coordinate = [cell coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
  [coordinate tap];
}

- (BOOL)isApplicationOverlayTransparent {
  return YES;
}

- (void)tableViewMatchingIdentifier:(NSString *)tableViewIdentifier
                   dragUntilVisible:(NSString *)cellIdentifier {
  XCUIElementQuery *tableQuery = [self.app.tables matchingIdentifier:tableViewIdentifier];
  XCUIElement *table = [tableQuery element];
  XCUIElement *cell = [[tableQuery.cells matchingIdentifier:cellIdentifier] element];
  XCUICoordinate *startCoordinate = [table coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.75)];
  XCUICoordinate *endCoordinate = [table coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.25)];
  while (![cell gscx_isVisibleWithProxyFrameFromApp:self.app]) {
    [startCoordinate pressForDuration:0.0 thenDragToCoordinate:endCoordinate];
  }
}

- (BOOL)assertOnPage:(Class<GSCXTestPage>)pageClass {
  return [[[self.app.navigationBars matchingIdentifier:[pageClass pageName]] element] isHittable];
}

@end
