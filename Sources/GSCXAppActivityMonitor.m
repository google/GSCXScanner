//
// Copyright 2019 Google LLC.
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

#import "GSCXAppActivityMonitor.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXAppActivityMonitor ()

/**
 * The sources being monitored.
 */
@property(strong, nonatomic) NSArray<id<GSCXActivitySourceMonitoring>> *sources;

/**
 * A callback invoked when the monitor's state changes.
 */
@property(copy, nonatomic) GSCXAppActivityMonitorStateChangedBlock stateChangedBlock;

/**
 * @c YES if the scanner is monitoring its sources, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isMonitoring) BOOL monitoring;

/**
 * The current state of the activity monitor.
 */
@property(assign, nonatomic) GSCXActivityStateType state;

/**
 * A map of sources to their states. The key is the source object (compared via memory address), and
 * the value is the last known state, represented by an @c NSNumber object.
 */
@property(strong, nonatomic) NSMapTable<id<GSCXActivitySourceMonitoring>, NSNumber *> *sourceStates;

@end

@implementation GSCXAppActivityMonitor

- (instancetype)initWithSources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
              stateChangedBlock:(GSCXAppActivityMonitorStateChangedBlock)stateChangedBlock {
  self = [super init];
  if (self) {
    GTX_ASSERT([sources count] > 0, @"Sources must not be empty.");
    _sources = sources;
    _stateChangedBlock = stateChangedBlock;
    _sourceStates = [NSMapTable strongToStrongObjectsMapTable];
    for (id<GSCXActivitySourceMonitoring> source in sources) {
      // It is assumed sources default to free. Directly after enabling continuous scanning is
      // arguably the best time to perform a scan, so setting all states to free ensures the
      // activity monitor allows scans to take place.
      [_sourceStates setObject:@(GSCXActivityStateFree) forKey:source];
    }
    _state = GSCXActivityStateFree;
    _monitoring = NO;
  }
  return self;
}

/**
 * Start monitoring all the sources of app activity.
 */
- (void)startMonitoring {
  __weak __typeof__(self) weakSelf = self;
  for (__weak id<GSCXActivitySourceMonitoring> source in self.sources) {
    [source startMonitoringWithStateChangedBlock:^(GSCXActivityStateType newState) {
      __typeof__(self) strongSelf = weakSelf;
      [strongSelf.sourceStates setObject:@(newState) forKey:source];
      [strongSelf gscx_stateChanged];
    }];
  }
  self.monitoring = YES;
}

/**
 * Stops monitoring all the sources. The state changed callback will not be invoked until monitoring
 * is restarted.
 */
- (void)stopMonitoring {
  self.monitoring = NO;
  for (id<GSCXActivitySourceMonitoring> source in self.sources) {
    [source stopMonitoring];
  }
}

#pragma mark - Private

/**
 * Combines @c firstState and @c secondState into a single state. If either state is unknown, the
 * result is unknown. If either state is busy, the result is busy. Otherwise, the result is free.
 *
 * @param firstState The first state to combine.
 * @param secondState The second state to combine.
 * @return The state representing the combination of both parameters.
 */
+ (GSCXActivityStateType)gscx_stateByCombiningState:(GSCXActivityStateType)firstState
                                          withState:(GSCXActivityStateType)secondState {
  // Unknown should override free, but it should not override busy.
  if (firstState == GSCXActivityStateBusy || secondState == GSCXActivityStateBusy) {
    return GSCXActivityStateBusy;
  } else if (firstState == GSCXActivityStateUnknown || secondState == GSCXActivityStateUnknown) {
    return GSCXActivityStateUnknown;
  } else {
    return GSCXActivityStateFree;
  }
}

/**
 * @return The combined state of all the monitor's sources.
 */
- (GSCXActivityStateType)gscx_aggregateState {
  GSCXActivityStateType state = GSCXActivityStateFree;
  for (id<GSCXActivitySourceMonitoring> source in self.sources) {
    GSCXActivityStateType currentState =
        (GSCXActivityStateType)[[self.sourceStates objectForKey:source] unsignedIntegerValue];
    state = [GSCXAppActivityMonitor gscx_stateByCombiningState:state withState:currentState];
  }
  return state;
}

/**
 * Called when any of the sources change state. Determines the new aggregate state and invokes the
 * state changed callback.
 */
- (void)gscx_stateChanged {
  GSCXActivityStateType state = [self gscx_aggregateState];
  if (self.isMonitoring && state != self.state) {
    self.stateChangedBlock(state);
  }
  self.state = state;
}

@end

NS_ASSUME_NONNULL_END
