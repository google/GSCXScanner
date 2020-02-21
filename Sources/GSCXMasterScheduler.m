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

#import <Foundation/Foundation.h>

#import "GSCXMasterScheduler.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXMasterScheduler ()

/**
 * Notifies this instance whether the application is busy or free.
 */
@property(strong, nonatomic) GSCXAppActivityMonitor *monitor;

/**
 * Schedules scans to occur. Whenever any of the schedulers schedules a scan, this instance
 * schedules a scan.
 */
@property(strong, nonatomic) NSArray<id<GSCXContinuousScannerScheduling>> *schedulers;

/**
 * The activity state of the application.
 */
@property(assign, nonatomic) GSCXActivityStateType activityState;

/**
 * Invoked when a scan is scheduled to occur. Is not invoked if the app is busy.
 */
@property(copy, nonatomic) GSCXContinuousScannerSchedulingBlock callback;

/**
 * @c YES if this instance is currently scheduling scans, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isScheduling) BOOL scheduling;

/**
 * @c YES if a scan was scheduled to occur but didn't because the application was busy, @c NO
 * otherwise.
 */
@property(assign, nonatomic, getter=doesNeedScan) BOOL needsScan;

@end

@implementation GSCXMasterScheduler

- (instancetype)initWithActivitySources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
                             schedulers:(NSArray<id<GSCXContinuousScannerScheduling>> *)schedulers {
  self = [super init];
  if (self) {
    _activityState = GSCXActivityStateFree;
    GTX_ASSERT([schedulers count] > 0, @"Schedulers cannot be empty.");
    _schedulers = schedulers;
    __weak __typeof__(self) weakSelf = self;
    _monitor = [[GSCXAppActivityMonitor alloc] initWithSources:sources
                                             stateChangedBlock:^(GSCXActivityStateType newState) {
                                               [weakSelf gscx_activityStateChanged:newState];
                                             }];
  }
  return self;
}

+ (instancetype)schedulerWithActivitySources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
                                  schedulers:
                                      (NSArray<id<GSCXContinuousScannerScheduling>> *)schedulers {
  return [[GSCXMasterScheduler alloc] initWithActivitySources:sources schedulers:schedulers];
}

#pragma mark - GSCXContinuousScannerScheduling

- (void)startSchedulingWithCallback:(GSCXContinuousScannerSchedulingBlock)callback {
  GTX_ASSERT(!self.isScheduling, @"Cannot start scheduling while already scheduling.");
  self.callback = callback;
  [self.monitor startMonitoring];
  __weak __typeof__(self) weakSelf = self;
  for (id<GSCXContinuousScannerScheduling> scheduler in self.schedulers) {
    [scheduler startSchedulingWithCallback:^BOOL(id<GSCXContinuousScannerScheduling> scheduler) {
      return [weakSelf gscx_postCallbackIfFree];
    }];
  }
  self.scheduling = YES;
}

- (void)stopScheduling {
  GTX_ASSERT(self.isScheduling, @"Cannot stop scheduling while not scheduling.");
  [self.monitor stopMonitoring];
  for (id<GSCXContinuousScannerScheduling> scheduler in self.schedulers) {
    [scheduler stopScheduling];
  }
  self.scheduling = NO;
}

#pragma mark - Private

/**
 * Updates @c activityState and schedules a scan if needed.
 *
 * @param newState The new activity state.
 */
- (void)gscx_activityStateChanged:(GSCXActivityStateType)newState {
  self.activityState = newState;
  if (self.activityState == GSCXActivityStateFree && self.doesNeedScan) {
    [self gscx_postCallback];
  }
}

/**
 * Invokes @c callback if the application is free. If the application is busy, does nothing.
 *
 * @return @c YES if a scan occurred, @c NO otherwise.
 */
- (BOOL)gscx_postCallbackIfFree {
  if (self.activityState == GSCXActivityStateFree) {
    return [self gscx_postCallback];
  } else {
    self.needsScan = YES;
    return NO;
  }
}

/**
 * Invokes @c callback and sets @c needsScan to @c NO to mark this instance as no longer needing a
 * scan.
 *
 * @return @c YES if the callback performs a scan, @c NO otherwise.
 */
- (BOOL)gscx_postCallback {
  self.needsScan = NO;
  return self.callback(self);
}

@end

NS_ASSUME_NONNULL_END
