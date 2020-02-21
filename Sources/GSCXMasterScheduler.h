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

#import "GSCXAppActivityMonitor.h"
#import "GSCXContinuousScannerScheduling.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Wraps a @c GSCXContinuousScannerScheduling instance and uses it to determine when scans should
 * occur. Only allows scans to occur if the application is free.
 */
@interface GSCXMasterScheduler : NSObject <GSCXContinuousScannerScheduling>

/**
 * Initializes a @c GSCXMasterScheduler instance with the given app activity
 * sources and wrapped scheduler.
 *
 * @param sources The app activity sources determining if the application is free or busy. Must be
 * non-empty.
 * @param schedulers The wrapped schedulers determining when scans should occur. Must be non-empty.
 * @return An initialized @c GSCXMasterScheduler instance.
 */
- (instancetype)initWithActivitySources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
                             schedulers:(NSArray<id<GSCXContinuousScannerScheduling>> *)schedulers;

/**
 * Constructs a @c GSCXMasterScheduler instance with the given app activity
 * sources and wrapped scheduler.
 *
 * @param sources The app activity sources determining if the application is free or busy.
 * @param scheduler The wrapped scheduler determining when scans should occur.
 * @return A @c GSCXMasterScheduler instance.
 */
+ (instancetype)schedulerWithActivitySources:(NSArray<id<GSCXActivitySourceMonitoring>> *)sources
                                  schedulers:
                                      (NSArray<id<GSCXContinuousScannerScheduling>> *)schedulers;

@end

NS_ASSUME_NONNULL_END
