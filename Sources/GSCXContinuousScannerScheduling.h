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

NS_ASSUME_NONNULL_BEGIN

@protocol GSCXContinuousScannerScheduling;

/**
 * A block called when a @c GSCXContinuousScannerScheduling instance schedules a scan.
 *
 * @param scheduler The @c GSCXContinuousScannerScheduling instance scheduling the scan.
 * @return @c YES if a scan occurred, or @c NO otherwise.
 */
typedef BOOL (^GSCXContinuousScannerSchedulingBlock)(id<GSCXContinuousScannerScheduling> scheduler);

/**
 * An object that can be scheduled to perform a scan.
 */
@protocol GSCXContinuousScannerScheduling <NSObject>

/**
 * Starts scheduling scans. Crashes if this instance is already scheduling scans.
 *
 * @param callback A callback invoked when this instance determines that a scan should occur.
 */
- (void)startSchedulingWithCallback:(GSCXContinuousScannerSchedulingBlock)callback;

/**
 * Stops scheduling scans. Crashes if this instance is not scheduling scans.
 */
- (void)stopScheduling;

/**
 * @return @c YES if this instance is scheduling scans, @c NO otherwise.
 */
- (BOOL)isScheduling;

@end

NS_ASSUME_NONNULL_END
