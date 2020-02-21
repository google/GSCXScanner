//
// Copyright 2019 Google Inc.
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

#import "third_party/objective_c/EarlGreyV2/AppFramework/Action/GREYActionBlock.h"
#import "third_party/objective_c/EarlGreyV2/AppFramework/Event/GREYSyntheticEvents.h"
#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXAppActivityMonitor.h"
#import "GSCXTouchActivitySource.h"
#import "GSCXTestAppDelegate.h"

@interface GSCXTouchActivitySourceTests : GSCXScannerTestCase
@end

@implementation GSCXTouchActivitySourceTests

- (void)testStateDoesNotChangeWhenNotMonitoring {
  GSCXTouchActivitySource *touchSource =
      [GREY_REMOTE_CLASS_IN_APP(GSCXTouchActivitySource) touchSource];
  NSMutableArray<NSNumber *> *states = [NSMutableArray array];
  [touchSource startMonitoringWithStateChangedBlock:^(GSCXActivityStateType newState) {
    [states addObject:@(newState)];
  }];
  [touchSource stopMonitoring];
  [self gscxtest_performTouchOnApp];
  [self gscxtest_assertStateArray:states equalsArray:@[]];
}

- (void)testStateChangesWhenMonitoring {
  GSCXTouchActivitySource *touchSource =
      [GREY_REMOTE_CLASS_IN_APP(GSCXTouchActivitySource) touchSource];
  NSMutableArray<NSNumber *> *states = [NSMutableArray array];
  [touchSource startMonitoringWithStateChangedBlock:^(GSCXActivityStateType newState) {
    [states addObject:@(newState)];
  }];
  [self gscxtest_performTouchOnApp];
  [self gscxtest_assertStateArray:states
                      equalsArray:@[ @(GSCXActivityStateBusy), @(GSCXActivityStateFree) ]];
}

- (void)testStateChangesWhenMonitoringStopsAfterStopMonitoring {
  GSCXTouchActivitySource *touchSource =
      [GREY_REMOTE_CLASS_IN_APP(GSCXTouchActivitySource) touchSource];
  NSMutableArray<NSNumber *> *states = [NSMutableArray array];
  [touchSource startMonitoringWithStateChangedBlock:^(GSCXActivityStateType newState) {
    [states addObject:@(newState)];
  }];
  UIWindow *window =
      [(GSCXTestAppDelegate *)[[GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication] delegate]
          window];
  // Manually instantiating synthetic touch events is the only way to not block the test. Not
  // blocking the test is required because the test needs to make the touch source stop monitoring
  // during the touch. Additionally, this removes the need to wait for the touch to elapse. It can
  // begin and end synchronously.
  GREYSyntheticEvents *touchEvents = [[GREYSyntheticEvents alloc] init];
  [touchEvents beginTouchAtPoint:CGPointZero relativeToWindow:window immediateDelivery:YES];
  [touchSource stopMonitoring];
  [touchEvents endTouch];
  [self gscxtest_assertStateArray:states equalsArray:@[ @(GSCXActivityStateBusy) ]];
}

- (void)testStateChangesWhenMonitoringRestartsMonitoring {
  GSCXTouchActivitySource *touchSource =
      [GREY_REMOTE_CLASS_IN_APP(GSCXTouchActivitySource) touchSource];
  NSMutableArray<NSNumber *> *states = [NSMutableArray array];
  GSCXActivitySourceStateChangedBlock callback = ^(GSCXActivityStateType newState) {
    [states addObject:@(newState)];
  };
  [touchSource startMonitoringWithStateChangedBlock:callback];
  [self gscxtest_performTouchOnApp];
  [touchSource stopMonitoring];
  [self gscxtest_performTouchOnApp];
  [touchSource startMonitoringWithStateChangedBlock:callback];
  [self gscxtest_performTouchOnApp];
  [self gscxtest_assertStateArray:states
                      equalsArray:@[
                        @(GSCXActivityStateBusy), @(GSCXActivityStateFree),
                        @(GSCXActivityStateBusy), @(GSCXActivityStateFree)
                      ]];
}

#pragma mark - Private

/**
 * Asserts that two arrays of @c NSNumber instances representing GSCXActivityStateType values have
 * equal values.
 */
- (void)gscxtest_assertStateArray:(NSArray<NSNumber *> *)actual
                      equalsArray:(NSArray<NSNumber *> *)expected {
  XCTAssertEqualObjects(actual, expected);
}

/**
 * Performs a touch on the application's key window.
 */
- (void)gscxtest_performTouchOnApp {
  [[EarlGrey selectElementWithMatcher:grey_keyWindow()] performAction:grey_longPress()];
}

/**
 * Performs a touch on the application's key window for a given duration.
 *
 * @param duration The number of seconds the touch should last.
 */
- (void)gscxtest_performTouchOnAppWithDuration:(CFTimeInterval)duration {
  [[EarlGrey selectElementWithMatcher:grey_keyWindow()]
      performAction:grey_longPressWithDuration(duration)];
}

@end
