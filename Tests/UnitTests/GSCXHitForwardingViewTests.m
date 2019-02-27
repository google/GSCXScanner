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

#import "GSCXHitForwardingViewTests.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GSCXHitForwardingView.h"

/**
 *  The dimensions (width and height) of the frame of the view under test.
 */
static const CGFloat kTestViewFrameSize = 100.0;

@implementation GSCXHitForwardingViewTests

+ (UIView *)viewWithFrame:(CGRect)frame {
  return [[GSCXHitForwardingView alloc] initWithFrame:frame];
}

- (void)setUp {
  self.view =
      [[self class] viewWithFrame:CGRectMake(0.0, 0.0, kTestViewFrameSize, kTestViewFrameSize)];
}

- (void)testHitTestOnBackgroundViewReturnsNil {
  UIView *result =
      [self.view hitTest:CGPointMake(kTestViewFrameSize / 2.0, kTestViewFrameSize / 2.0)
               withEvent:nil];
  XCTAssertNil(result);
}

- (void)testHitTestOutOfBoundsReturnsNil {
  UIView *result1 =
      [self.view hitTest:CGPointMake(kTestViewFrameSize * 1.5, kTestViewFrameSize * 1.5)
               withEvent:nil];
  XCTAssertNil(result1);

  UIView *result2 =
      [self.view hitTest:CGPointMake(kTestViewFrameSize, kTestViewFrameSize * 1.5) withEvent:nil];
  XCTAssertNil(result2);

  UIView *result3 =
      [self.view hitTest:CGPointMake(kTestViewFrameSize * 1.5, kTestViewFrameSize) withEvent:nil];
  XCTAssertNil(result3);
}

- (void)testHitTestBackgroundWithSubviewsReturnsNil {
  [self _addTestSubviewsToView:self.view];

  UIView *result =
      [self.view hitTest:CGPointMake(kTestViewFrameSize / 2.0, kTestViewFrameSize / 2.0)
               withEvent:nil];
  XCTAssertNil(result);
}

- (void)testHitTestSubviewReturnsSubview {
  NSArray<UIView *> *subviews = [self _addTestSubviewsToView:self.view];

  UIView *result =
      [self.view hitTest:CGPointMake(kTestViewFrameSize * 0.15, kTestViewFrameSize * 0.15)
               withEvent:nil];
  XCTAssertEqual(subviews[0], result);
}

#pragma mark - Private

/**
 *  Adds two subviews to the given view, one in the top left corner and one in the bottom right
 *  corner and returns an array containing those subviews.
 *
 *  @param view The view to add the subviews to.
 *  @return An array containing both subviews that were added.
 */
- (NSArray<UIView *> *)_addTestSubviewsToView:(UIView *)view {
  UIView *firstSubview = [[UIView alloc]
      initWithFrame:CGRectMake(kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0,
                               kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0)];
  UIView *secondSubview = [[UIView alloc]
      initWithFrame:CGRectMake(kTestViewFrameSize * 0.8, kTestViewFrameSize * 0.8,
                               kTestViewFrameSize / 10.0, kTestViewFrameSize / 10.0)];
  [view addSubview:firstSubview];
  [view addSubview:secondSubview];

  return @[ firstSubview, secondSubview ];
}

@end
