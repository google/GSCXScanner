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

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerPeriodicScheduler ()

/**
 * The number of seconds between scheduled scans.
 */
@property(assign, nonatomic) NSTimeInterval interval;

/**
 * A callback to invoke when a scan is scheduled to occur.
 */
@property(copy, nonatomic) GSCXContinuousScannerSchedulingBlock scanCallback;

/**
 * The timer repeatedly scheduling scans. @c nil if scans are not being scheduled.
 */
@property(strong, nonatomic, nullable) NSTimer *timer;

@end

@implementation GSCXContinuousScannerPeriodicScheduler

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval {
  self = [super init];
  if (self) {
    _interval = interval;
  }
  return self;
}

+ (instancetype)schedulerWithTimeInterval:(NSTimeInterval)interval {
  return [[GSCXContinuousScannerPeriodicScheduler alloc] initWithTimeInterval:interval];
}

#pragma mark - GSCXContinuousScannerScheduling

- (void)startSchedulingWithCallback:(GSCXContinuousScannerSchedulingBlock)callback {
  GTX_ASSERT(![self isScheduling], @"Cannot start scheduling while already scheduling.");
  self.scanCallback = callback;
  __weak __typeof__(self) weakSelf = self;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                               repeats:YES
                                                 block:^(NSTimer *timer) {
                                                   [weakSelf gscx_scanShouldOccur];
                                                 }];
}

- (void)stopScheduling {
  GTX_ASSERT([self isScheduling], @"Cannot stop scheduling while not scheduling.");
  [self.timer invalidate];
  self.timer = nil;
}

- (BOOL)isScheduling {
  return self.timer != nil;
}

#pragma mark - Private

/**
 * Invokes @c scanCallback to schedule a scan.
 */
- (void)gscx_scanShouldOccur {
  self.scanCallback(self);
}

@end

NS_ASSUME_NONNULL_END
