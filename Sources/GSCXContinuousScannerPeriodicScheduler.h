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

#import "GSCXContinuousScannerScheduling.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A @c GSCXContinuousScannerPeriodicScheduler instance that schedules scans on some fixed interval.
 */
@interface GSCXContinuousScannerPeriodicScheduler : NSObject <GSCXContinuousScannerScheduling>

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes this instance with the given time interval.
 *
 * @param interval The number of seconds between scans.
 * @return An initialized @c GSCXContinuousScannerPeriodicScheduler instance.
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval;

/**
 * Constructs a @c GSCXContinuousScannerPeriodicScheduler instance with the given time interval.
 *
 * @param interval The number of seconds between scans.
 * @return A @c GSCXContinuousScannerPeriodicScheduler instance.
 */
+ (instancetype)schedulerWithTimeInterval:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
