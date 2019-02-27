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

#import "GSCXTestViewController.h"
#import "GSCXUITestViewController.h"
#import "GSCXUITestCase.h"
#import "XCUIElement+GSCXScanner.h"

/**
 *  Tests that GSCXHitForwardingWindow properly forwards hits to underlying window.
 */
@interface GSCXTransparentWindowTests : GSCXUITestCase
@end

@implementation GSCXTransparentWindowTests

- (void)setUp {
  [super setUp];

  [self assertOnPage:[GSCXTestViewController class]];
  NSString *cellIdentifier = [GSCXTestViewController
      accessibilityIdentifierOfCellForPage:[GSCXUITestViewController class]];
  // The behaviors under test occur on a separate view controller, so the cell corresponding to that
  // view controller must be tapped to open that page.
  [self tapCellWithIdentifier:cellIdentifier];
}

- (void)testCanTapOnTableViewCellToNavigateToNewPage {
  [self assertOnPage:[GSCXUITestViewController class]];
}

- (void)testTransparentWindowAllowsTypingIntoTextFields {
  XCUIElement *textField = [[self.app.textFields
      matchingIdentifier:kUITestsPageTextFieldAccessibilityIdentifier] element];
  XCTAssertEqualObjects([textField value], @"");
  [textField tap];
  [textField typeText:@"Test Text"];
  XCTAssertEqualObjects([textField value], @"Test Text");
}

- (void)testTransparentWindowAllowsDraggingSlider {
  XCUIElement *slider =
      [[self.app.sliders matchingIdentifier:kUITestsPageSliderAccessibilityIdentifier] element];
  XCTAssertEqualObjects([slider value], @"50%");
  XCUICoordinate *startCoordinate = [slider coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
  XCUICoordinate *endCoordinate = [slider coordinateWithNormalizedOffset:CGVectorMake(1.0, 0.5)];
  [startCoordinate pressForDuration:0.0 thenDragToCoordinate:endCoordinate];
  XCTAssertEqualObjects([slider value], @"100%");
}

- (void)testTransparentWindowAllowsPressingButton {
  XCUIElement *button =
      [[self.app.buttons matchingIdentifier:kUITestsPageButtonAccessibilityIdentifier] element];
  XCTAssertEqualObjects([button label], kUITestsDefaultControlState);
  [button tap];
  XCTAssertEqualObjects([button label], kUITestsPageButtonPressedTitle);
}

- (void)testTransparentWindowAllowsSwipingInAllDirections {
  XCUIElement *label =
      [[self.app.staticTexts matchingIdentifier:kUITestsSwipeLabelAccessibilityIdentifier] element];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);

  [label swipeRight];
  XCTAssertEqualObjects([label label], kUITestsSwipeLabelRightValue);

  [label swipeLeft];
  XCTAssertEqualObjects([label label], kUITestsSwipeLabelLeftValue);

  [label swipeUp];
  XCTAssertEqualObjects([label label], kUITestsSwipeLabelUpValue);

  [label swipeDown];
  XCTAssertEqualObjects([label label], kUITestsSwipeLabelDownValue);

  [label tap];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);
}

- (void)testTransparentWindowAllowsPinching {
  XCUIElement *label =
      [[self.app.staticTexts matchingIdentifier:kUITestsPinchLabelAccessibilityIdentifier] element];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);
  [self.app pinchWithScale:2.0 velocity:64.0];
  XCTAssertEqualObjects([label label], kUITestsPinchLabelPinchedValue);
}

@end
