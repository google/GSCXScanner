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

#import "GSCXMasterScheduler.h"

#import <XCTest/XCTest.h>

#import "GSCXAppActivityMonitor.h"
#import "third_party/objective_c/GSCXScanner/Tests/Common/GSCXManualScheduler.h"
#import "GSCXTestActivitySource.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXMasterSchedulerTests : XCTestCase

/**
 * Determines if the applciation is busy or free. Set @c dummySource.state to determine if the
 * scheduler is allowed to schedule scans.
 */
@property(strong, nonatomic) GSCXTestActivitySource *dummySource;

/**
 * The number of times a scan has been scheduled, invoking @c scheduleCallback.
 */
@property(assign, nonatomic) NSInteger scheduledScanCount;

/**
 * A callback passed to a @c GSCXMasterScheduler instance. Increments @c scheduleCallback.
 */
@property(copy, nonatomic) GSCXContinuousScannerSchedulingBlock scheduleCallback;

@end

@implementation GSCXMasterSchedulerTests

- (void)setUp {
  self.dummySource = [GSCXTestActivitySource testSource];
  self.scheduledScanCount = 0;
  __weak __typeof__(self) weakSelf = self;
  self.scheduleCallback = ^BOOL(id<GSCXContinuousScannerScheduling> scheduler) {
    weakSelf.scheduledScanCount++;
    return YES;
  };
}

- (void)testInitThrowsExceptionWithZeroSources {
  GSCXManualScheduler *dummyScheduler = [[GSCXManualScheduler alloc] init];
  XCTAssertThrows([GSCXMasterScheduler schedulerWithActivitySources:@[]
                                                         schedulers:@[ dummyScheduler ]]);
}

- (void)testInitThrowsExceptionWithZeroSchedulers {
  XCTAssertThrows([GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                                         schedulers:@[]]);
}

- (void)testInitThrowsExceptionWithZeroSourcesAndSchedulers {
  XCTAssertThrows([GSCXMasterScheduler schedulerWithActivitySources:@[] schedulers:@[]]);
}

- (void)testScanDoesNotOccurWhenNotScheduling {
  GSCXManualScheduler *dummyScheduler = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler ]];
  [dummyScheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  // Assign to nil to silence unused variable warnings.
  masterScheduler = nil;
}

- (void)testScanOccursWhenSchedulingOneSchedulerFree {
  GSCXManualScheduler *dummyScheduler = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  [dummyScheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 1);
}

- (void)testScanDoesNotOccurWhenSchedulingOneSchedulerBusy {
  GSCXManualScheduler *dummyScheduler = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  self.dummySource.state = GSCXActivityStateBusy;
  [dummyScheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
}

- (void)testScanOccursWhenSchedulingOneSchedulerBusyThenFree {
  GSCXManualScheduler *dummyScheduler = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  self.dummySource.state = GSCXActivityStateBusy;
  [dummyScheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  self.dummySource.state = GSCXActivityStateFree;
  XCTAssertEqual(self.scheduledScanCount, 1);
  [dummyScheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 2);
}

- (void)testScanDoesNotOccurWhenNotSchedulingManySchedulers {
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  // Assign to nil to silence unused variable warnings.
  masterScheduler = nil;
}

- (void)testScanOccursWhenSchedulingManySchedulersFree {
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 1);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 2);
}

- (void)testScanOccursWhenSchedulingManySchedulersBusy {
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  self.dummySource.state = GSCXActivityStateBusy;
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
}

- (void)testScanOccursWhenSchedulingManySchedulersBusyThenFree {
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  self.dummySource.state = GSCXActivityStateBusy;
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  self.dummySource.state = GSCXActivityStateFree;
  XCTAssertEqual(self.scheduledScanCount, 1);
}

- (void)testScanOccursWhenSchedulingManySchedulersManySourcesFree {
  GSCXTestActivitySource *dummySource2 = [GSCXTestActivitySource testSource];
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource, dummySource2 ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 1);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 2);
}

- (void)testScanOccursWhenSchedulingManySchedulersManySourcesSomeBusySomeFree {
  GSCXTestActivitySource *dummySource2 = [GSCXTestActivitySource testSource];
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource, dummySource2 ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  dummySource2.state = GSCXActivityStateBusy;
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
}

- (void)testScanOccursWhenSchedulingManySchedulersManySourcesBusyThenFree {
  GSCXTestActivitySource *dummySource2 = [GSCXTestActivitySource testSource];
  GSCXManualScheduler *dummyScheduler1 = [[GSCXManualScheduler alloc] init];
  GSCXManualScheduler *dummyScheduler2 = [[GSCXManualScheduler alloc] init];
  GSCXMasterScheduler *masterScheduler =
      [GSCXMasterScheduler schedulerWithActivitySources:@[ self.dummySource, dummySource2 ]
                                             schedulers:@[ dummyScheduler1, dummyScheduler2 ]];
  [masterScheduler startSchedulingWithCallback:self.scheduleCallback];
  self.dummySource.state = GSCXActivityStateBusy;
  dummySource2.state = GSCXActivityStateBusy;
  [dummyScheduler1 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  [dummyScheduler2 triggerScheduleScanEvent];
  XCTAssertEqual(self.scheduledScanCount, 0);
  dummySource2.state = GSCXActivityStateFree;
  XCTAssertEqual(self.scheduledScanCount, 0);
  self.dummySource.state = GSCXActivityStateFree;
  XCTAssertEqual(self.scheduledScanCount, 1);
}

@end

NS_ASSUME_NONNULL_END
