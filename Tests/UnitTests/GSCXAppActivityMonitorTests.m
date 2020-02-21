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

#import <XCTest/XCTest.h>

#import "GSCXActivitySourceMonitoring.h"
#import "GSCXAppActivityMonitor.h"
#import "GSCXTestActivitySource.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXAppActivityMonitor (ExposedForTesting)

+ (GSCXActivityStateType)gscx_stateByCombiningState:(GSCXActivityStateType)firstState
                                          withState:(GSCXActivityStateType)secondState;

@end

@interface GSCXAppActivityMonitorTests : XCTestCase

/**
 * The last state returned by the monitor. Defaults to @c GSCXActivityStateUnknown.
 */
@property(assign, nonatomic) GSCXActivityStateType state;

/**
 * The callback passed to the @c GSCXAppActivityMonitor instance on initialization. Sets @c state to
 * the new state.
 */
@property(copy, nonatomic) GSCXAppActivityMonitorStateChangedBlock monitorStateChangedBlock;

@end

@implementation GSCXAppActivityMonitorTests

- (void)setUp {
  self.state = GSCXActivityStateFree;
  __weak __typeof__(self) weakSelf = self;
  self.monitorStateChangedBlock = ^(GSCXActivityStateType state) {
    weakSelf.state = state;
  };
}

- (void)testStateByCombiningStateFreeFree {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateFree
                                               withState:GSCXActivityStateFree];
  XCTAssertEqual(result, GSCXActivityStateFree);
}

- (void)testStateByCombiningStateFreeBusy {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateFree
                                               withState:GSCXActivityStateBusy];
  XCTAssertEqual(result, GSCXActivityStateBusy);
}

- (void)testStateByCombiningStateFreeUnknown {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateFree
                                               withState:GSCXActivityStateUnknown];
  XCTAssertEqual(result, GSCXActivityStateUnknown);
}

- (void)testStateByCombiningStateBusyFree {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateBusy
                                               withState:GSCXActivityStateFree];
  XCTAssertEqual(result, GSCXActivityStateBusy);
}

- (void)testStateByCombiningStateBusyBusy {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateBusy
                                               withState:GSCXActivityStateBusy];
  XCTAssertEqual(result, GSCXActivityStateBusy);
}

- (void)testStateByCombiningStateBusyUnknown {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateBusy
                                               withState:GSCXActivityStateUnknown];
  XCTAssertEqual(result, GSCXActivityStateBusy);
}

- (void)testStateByCombiningStateUnknownFree {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateUnknown
                                               withState:GSCXActivityStateFree];
  XCTAssertEqual(result, GSCXActivityStateUnknown);
}

- (void)testStateByCombiningStateUnknownBusy {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateUnknown
                                               withState:GSCXActivityStateBusy];
  XCTAssertEqual(result, GSCXActivityStateBusy);
}

- (void)testStateByCombiningStateUnknownUnknown {
  GSCXActivityStateType result =
      [GSCXAppActivityMonitor gscx_stateByCombiningState:GSCXActivityStateUnknown
                                               withState:GSCXActivityStateUnknown];
  XCTAssertEqual(result, GSCXActivityStateUnknown);
}

- (void)testCallbacksAreNotInvokedWhenNotMonitoring {
  GSCXTestActivitySource *source = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source.state = GSCXActivityStateUnknown;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  // Using monitor in a statement silences the unused variable warning.
  monitor = nil;
}

- (void)testCallbacksAreInvokedWhenMonitoring {
  GSCXTestActivitySource *source = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source.state = GSCXActivityStateUnknown;
  XCTAssertEqual(self.state, GSCXActivityStateUnknown);
}

- (void)testCallbacksAreNotInvokedAfterStopMonitoring {
  GSCXTestActivitySource *source = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source.state = GSCXActivityStateUnknown;
  XCTAssertEqual(self.state, GSCXActivityStateUnknown);
  [monitor stopMonitoring];
  source.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateUnknown);
}

- (void)testCallbacksAreInvokedWhenMonitoringBusy {
  GSCXTestActivitySource *source = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
}

- (void)testCallbacksAreInvokedWhenMonitoringMultipleFree {
  GSCXTestActivitySource *source1 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source2 = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source1, source2 ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source1.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source2.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
}

- (void)testCallbacksAreInvokedWhenMonitoringSomeFreeSomeBusy {
  GSCXTestActivitySource *source1 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source2 = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source1, source2 ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source1.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source2.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
}

- (void)testCallbacksAreInvokedWhenMonitoringMultipleBusyThenFree {
  GSCXTestActivitySource *source1 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source2 = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source1, source2 ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source1.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
  source2.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
  source1.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
  source2.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
}

- (void)testCallbacksAreInvokedWhenMonitoringMultipleFreeThenUnknown {
  GSCXTestActivitySource *source1 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source2 = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source1, source2 ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source1.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source2.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source2.state = GSCXActivityStateUnknown;
  XCTAssertEqual(self.state, GSCXActivityStateUnknown);
}

- (void)testCallbacksAreInvokedWhenMonitoringSomeFreeSomeBusyThenUnknown {
  GSCXTestActivitySource *source1 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source2 = [GSCXTestActivitySource testSource];
  GSCXTestActivitySource *source3 = [GSCXTestActivitySource testSource];
  GSCXAppActivityMonitor *monitor =
      [[GSCXAppActivityMonitor alloc] initWithSources:@[ source1, source2, source3 ]
                                    stateChangedBlock:self.monitorStateChangedBlock];
  [monitor startMonitoring];
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source1.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateFree);
  source2.state = GSCXActivityStateBusy;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
  source3.state = GSCXActivityStateFree;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
  source1.state = GSCXActivityStateUnknown;
  XCTAssertEqual(self.state, GSCXActivityStateBusy);
}

@end

NS_ASSUME_NONNULL_END
