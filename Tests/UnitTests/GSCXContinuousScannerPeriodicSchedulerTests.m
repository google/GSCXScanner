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

#import "GSCXContinuousScannerPeriodicScheduler.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerPeriodicSchedulerTests : XCTestCase

/**
 * The number of times the scheduling callback has been called in this test.
 */
@property(assign, nonatomic) NSUInteger scheduledCount;

@end

@implementation GSCXContinuousScannerPeriodicSchedulerTests

- (void)setUp {
  [super setUp];
  self.scheduledCount = 0;
}

/**
 * Creates a scheduling callback that increments @c scheduledCount each time it is called. For each
 * time it is expected to be called, an @c XCTestExpectation object is created so tests can wait for
 * the timer to terminate by calling `waitForExpectationsWithTimeout`.
 *
 * @param numberOfCalls The number of times the returned callback is expected to be called. An
 * @c XCTestExpectation object is created for each expected call.
 * @return A callback that increments @c scheduledCount and fulfills the corresponding
 * @c XCTestExpectation each time it is called.
 */
- (GSCXContinuousScannerSchedulingBlock)schedulingBlockExpectingNumberOfCalls:
    (NSUInteger)numberOfCalls {
  NSMutableArray<XCTestExpectation *> *expectations = [NSMutableArray array];
  for (NSUInteger i = 0; i < numberOfCalls; i++) {
    NSString *description = [NSString stringWithFormat:@"Scheduled scan %lu", (unsigned long)i];
    [expectations addObject:[self expectationWithDescription:description]];
  }
  __weak __typeof(self) weakSelf = self;
  return ^(id<GSCXContinuousScannerScheduling> scheduler) {
    __typeof__(self) strongSelf = weakSelf;
    strongSelf.scheduledCount++;
    if (strongSelf.scheduledCount - 1 < expectations.count) {
      [expectations[strongSelf.scheduledCount - 1] fulfill];
    }
    return YES;
  };
}

- (void)testScanIsScheduledOnceWhenStarted {
  GSCXContinuousScannerPeriodicScheduler *scheduler =
      [GSCXContinuousScannerPeriodicScheduler schedulerWithTimeInterval:0.2];
  [scheduler startSchedulingWithCallback:[self schedulingBlockExpectingNumberOfCalls:1]];
  [self waitForExpectationsWithTimeout:0.3
                               handler:^(NSError *error) {
                                 XCTAssertEqual(self.scheduledCount, 1);
                               }];
}

- (void)testScanIsScheduledManyWhenStarted {
  GSCXContinuousScannerPeriodicScheduler *scheduler =
      [GSCXContinuousScannerPeriodicScheduler schedulerWithTimeInterval:0.2];
  [scheduler startSchedulingWithCallback:[self schedulingBlockExpectingNumberOfCalls:2]];
  [self waitForExpectationsWithTimeout:0.5
                               handler:^(NSError *error) {
                                 XCTAssertEqual(self.scheduledCount, 2);
                               }];
}

- (void)testScanIsNotScheduledWhenSchedulingIsStopped {
  GSCXContinuousScannerPeriodicScheduler *scheduler =
      [GSCXContinuousScannerPeriodicScheduler schedulerWithTimeInterval:0.2];
  [scheduler startSchedulingWithCallback:[self schedulingBlockExpectingNumberOfCalls:1]];
  [NSTimer scheduledTimerWithTimeInterval:0.3
                                  repeats:NO
                                    block:^(NSTimer *timer) {
                                      [scheduler stopScheduling];
                                    }];
  [self waitForExpectationsWithTimeout:0.5
                               handler:^(NSError *error) {
                                 XCTAssertEqual(self.scheduledCount, 1);
                               }];
}

- (void)testScanResumesSchedulingWhenStoppedAndStarted {
  GSCXContinuousScannerPeriodicScheduler *scheduler =
      [GSCXContinuousScannerPeriodicScheduler schedulerWithTimeInterval:0.2];
  GSCXContinuousScannerSchedulingBlock block = [self schedulingBlockExpectingNumberOfCalls:2];
  [scheduler startSchedulingWithCallback:block];
  [NSTimer scheduledTimerWithTimeInterval:0.3
                                  repeats:NO
                                    block:^(NSTimer *timer) {
                                      [scheduler stopScheduling];
                                    }];
  [NSTimer scheduledTimerWithTimeInterval:0.5
                                  repeats:NO
                                    block:^(NSTimer *timer) {
                                      [scheduler startSchedulingWithCallback:block];
                                    }];
  [self waitForExpectationsWithTimeout:0.8
                               handler:^(NSError *error) {
                                 XCTAssertEqual(self.scheduledCount, 2);
                               }];
}
@end

NS_ASSUME_NONNULL_END
