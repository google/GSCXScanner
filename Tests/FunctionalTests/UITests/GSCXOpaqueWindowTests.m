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

/**
 * Tests that pure UIWindow does not forward hits to underlying windows, so users cannot interact
 * with the original application.
 */
@interface GSCXOpaqueWindowTests : GSCXUITestCase
@end

@implementation GSCXOpaqueWindowTests

- (void)testApplicationStartsOnUITestsPage {
  [self assertOnPage:[GSCXUITestViewController class]];
}

- (void)testCannotTypeTextInTextField {
  XCUIElement *textField = [[self.app.textFields
      matchingIdentifier:kUITestsPageTextFieldAccessibilityIdentifier] element];
  XCTAssertEqualObjects([textField value], @"");
  [textField tap];
  // -[XCUIElement typeText:] fails the test if no object is the first responder (which is
  // impossible because taps aren't forwarded), so checking if the keyboard exists is the only
  // possible test.
  XCTAssertFalse([[self.app.keyboards firstMatch] exists]);
}

- (void)testOpaqueWindowDoesNotAllowTappingButton {
  XCUIElement *button =
      [[self.app.buttons matchingIdentifier:kUITestsPageButtonAccessibilityIdentifier] element];
  XCTAssertEqualObjects([button label], kUITestsDefaultControlState);
  [button tap];
  XCTAssertEqualObjects([button label], kUITestsDefaultControlState);
}

- (void)testOpaqueWindowDoesNotAllowSwipingInAnyDirection {
  XCUIElement *label =
      [[self.app.staticTexts matchingIdentifier:kUITestsSwipeLabelAccessibilityIdentifier] element];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);

  [label swipeRight];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);

  [label swipeLeft];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);

  [label swipeUp];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);

  [label swipeDown];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);
}

- (void)testOpaqueWindowDoesNotAllowPinching {
  XCUIElement *label =
      [[self.app.staticTexts matchingIdentifier:kUITestsPinchLabelAccessibilityIdentifier] element];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);
  [self.app pinchWithScale:2.0 velocity:64.0];
  XCTAssertEqualObjects([label label], kUITestsDefaultControlState);
}

#pragma mark - GSCXUITestCase

- (BOOL)isApplicationOverlayTransparent {
  return NO;
}

@end
