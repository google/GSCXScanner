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

/**
 * The different states a source can be in.
 */
typedef NS_ENUM(NSUInteger, GSCXActivityStateType) {
  GSCXActivityStateUnknown,
  GSCXActivityStateFree,
  GSCXActivityStateBusy
};

@class GSCXAppActivityMonitor;
@protocol GSCXActivitySourceMonitoring;

/**
 * A callback invoked when a @c GSCXActivitySourceMonitoring instance changes state.
 *
 * @param The source's new state.
 */
typedef void (^GSCXActivitySourceStateChangedBlock)(GSCXActivityStateType newState);

/**
 * Represents a source of work or computation in an app. Can either be busy or free, where what
 * counts as busy is determined by this instance.
 */
@protocol GSCXActivitySourceMonitoring <NSObject>

/**
 * Begins monitoring the underlying source. Invokes @c onStateChanged whenever the source's state
 * changes.
 *
 * @param onStateChanged A block to be invoked when the state changes. The first parameter is the
 * monitor object. The second parameter is the new state of the source.
 */
- (void)startMonitoringWithStateChangedBlock:(GSCXActivitySourceStateChangedBlock)onStateChanged;

/**
 * Stops monitoring the underlying source. If any state changes occurred before @c stopMonitoring
 * was called, they may still invoke the block passed to @c
 * startMonitoringForMonitor:withStateChangedBlock:.
 */
- (void)stopMonitoring;

@end
