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
 * A stubbed scheduler that can manually trigger scheduling events.
 */
@interface GSCXManualScheduler : NSObject <GSCXContinuousScannerScheduling>

/**
 * Invoked when scheduling events occur while @c isScheduling is @c YES.
 */
@property(strong, nonatomic) GSCXContinuousScannerSchedulingBlock callback;

/**
 * @c YES if this instance is scheduling scans, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isScheduling) BOOL scheduling;

/**
 * Represents a scheduling event. For example, this might be the user interface changing or a timer
 * firing in a real implementation. If @c isScheduling is @c YES, this invokes @c callback.
 * Otherwise, does nothing.
 */
- (void)triggerScheduleScanEvent;

@end

NS_ASSUME_NONNULL_END
