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

#import <Foundation/Foundation.h>

#import "GSCXActivitySourceMonitoring.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A callback invoked when a @c GSCXAppActivityMonitor instance changes state. The parameter is the
 * new state of the monitor.
 */
typedef void (^GSCXAppActivityMonitorStateChangedBlock)(GSCXActivityStateType newState);

/**
 * Monitors sources of app activity and aggregates the states into a single busy or free state for
 * the entire app.
 */
@interface GSCXAppActivityMonitor : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes a @c GSCXAppActivityMonitor instance with the given sources and callback.
 *
 * @param sources An array of sources to monitor. Must not be empty.
 * @param stateChangedBlock A callback invoked whenever the monitor's state changes. This callback
 * is only invoked after @c startMonitoring has been called. This callback is not invoked after @c
 * stopMonitoring has been called.
 */
- (instancetype)initWithSources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
              stateChangedBlock:(GSCXAppActivityMonitorStateChangedBlock)stateChangedBlock
    NS_DESIGNATED_INITIALIZER;

/**
 * Start monitoring all the sources of app activity.
 */
- (void)startMonitoring;

/**
 * Stops monitoring all the sources. The state changed callback will not be invoked until monitoring
 * is restarted.
 */
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
