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

#import "GSCXScannerOverlayWindow.h"

/**
 * The dimensions (width and height) of the frame of the view under test.
 */
static const CGFloat kTestViewFrameSize = 100.0;

@interface GSCXScannerOverlayWindowTests : XCTestCase

/**
 * The window instance under test.
 */
@property(strong, nonatomic) GSCXScannerOverlayWindow *window;

@end

@implementation GSCXScannerOverlayWindowTests

- (void)setUp {
  self.window = [[GSCXScannerOverlayWindow alloc]
      initWithFrame:CGRectMake(0.0, 0.0, kTestViewFrameSize, kTestViewFrameSize)];
  self.window.rootViewController = [[UIViewController alloc] init];
  self.window.hidden = NO;
}

- (void)testHitTestOnBackgroundViewReturnsNil {
  UIView *result =
      [self.window hitTest:CGPointMake(kTestViewFrameSize / 2.0, kTestViewFrameSize / 2.0)
                 withEvent:nil];
  XCTAssertNil(result);
}

- (void)testHitTestOutOfBoundsReturnsNil {
  UIView *result1 =
      [self.window hitTest:CGPointMake(kTestViewFrameSize * 1.5, kTestViewFrameSize * 1.5)
                 withEvent:nil];
  XCTAssertNil(result1);

  UIView *result2 = [self.window hitTest:CGPointMake(kTestViewFrameSize, kTestViewFrameSize * 1.5)
                               withEvent:nil];
  XCTAssertNil(result2);

  UIView *result3 = [self.window hitTest:CGPointMake(kTestViewFrameSize * 1.5, kTestViewFrameSize)
                               withEvent:nil];
  XCTAssertNil(result3);
}

- (void)testHitTestBackgroundWithSubviewsReturnsNil {
  NSArray<UIButton *> *buttons = [self gscxtest_addTestButtonsToView:self.window];
  self.window.settingsButton = buttons[0];

  UIView *result =
      [self.window hitTest:CGPointMake(kTestViewFrameSize / 2.0, kTestViewFrameSize / 2.0)
                 withEvent:nil];
  XCTAssertNil(result);
}

- (void)testHitTestSubviewReturnsSubview {
  NSArray<UIButton *> *buttons = [self gscxtest_addTestButtonsToView:self.window];
  self.window.settingsButton = buttons[0];

  UIView *result =
      [self.window hitTest:CGPointMake(kTestViewFrameSize * 0.15, kTestViewFrameSize * 0.15)
                 withEvent:nil];
  XCTAssertEqual(buttons[0], result);
}

- (void)testHitWrongTestSubviewReturnsNil {
  NSArray<UIButton *> *subviews = [self gscxtest_addTestButtonsToView:self.window];
  self.window.settingsButton = subviews[0];

  UIView *result =
      [self.window hitTest:CGPointMake(kTestViewFrameSize * 0.85, kTestViewFrameSize * 0.85)
                 withEvent:nil];
  XCTAssertNil(result);
}

#pragma mark - Private

/**
 * Adds two buttons to the given view, one in the top left corner and one in the bottom right
 * corner and returns an array containing those buttons.
 *
 * @param view The view to add the buttons to.
 * @return An array containing both buttons that were added.
 */
- (NSArray<UIButton *> *)gscxtest_addTestButtonsToView:(UIView *)view {
  UIButton *firstButton = [[UIButton alloc]
      initWithFrame:CGRectMake(kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0,
                               kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0)];
  UIButton *secondButton = [[UIButton alloc]
      initWithFrame:CGRectMake(kTestViewFrameSize * 0.8, kTestViewFrameSize * 0.8,
                               kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0)];
  [view addSubview:firstButton];
  [view addSubview:secondButton];

  return @[ firstButton, secondButton ];
}

@end
