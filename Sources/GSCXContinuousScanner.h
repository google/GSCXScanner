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

#import "GSCXContinuousScannerDelegate.h"
#import "GSCXContinuousScannerScheduling.h"
#import "GSCXScanner.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Manages scanning the application for accessibility issues in the background without user
 * interactions. The scheduler determines when the application needs to be scanned (such as if the
 * user interface has likely changed since the last scan).
 */
@interface GSCXContinuousScanner : NSObject

/**
 * The results of scans, from first occurring (least recent) to last occuring (most recent).
 */
@property(strong, nonatomic, readonly) NSArray<GSCXScannerResult *> *scanResults;

/**
 * Initializes a @c GSCXContinuousScanner instance.
 *
 * @param scanner The @c GSCXScanner instance to use to scan the view hierarchy.
 * @param delegate The delegate to provide information about scans. This object is notified about
 * scan lifecycles.
 * @param scheduler The scheduler used to determine when this instance should perform scans.
 * @return An initialized @c GSCXContinuousScanner instance.
 */
- (instancetype)initWithScanner:(GSCXScanner *)scanner
                       delegate:(__weak id<GSCXContinuousScannerDelegate>)delegate
                      scheduler:(id<GSCXContinuousScannerScheduling>)scheduler;

/**
 * Constructs a @c GSCXContinuousScanner instance.
 *
 * @param scanner The @c GSCXScanner instance to use to scan the view hierarchy.
 * @param delegate The delegate to provide information about scans. This object is notified about
 * scan lifecycles.
 * @param scheduler The scheduler used to determine when this instance should perform scans.
 * @return A constructed @c GSCXContinuousScanner instance.
 */
+ (instancetype)scannerWithScanner:(GSCXScanner *)scanner
                          delegate:(__weak id<GSCXContinuousScannerDelegate>)delegate
                         scheduler:(id<GSCXContinuousScannerScheduling>)scheduler;

/**
 * Begins a continuous scan. Any previous continuous scan results are cleared. Crashes with an
 * assertion if a continuous scan is already in progress.
 */
- (void)startScanning;

/**
 * Stops a continuous scan. Crashes with an assertion if a continuous scan is not currently in
 * progress.
 */
- (void)stopScanning;

/**
 * @return @c YES if this instance is currently performing scans, @c NO otherwise.
 */
- (BOOL)isScanning;

/**
 * @return The total number of individual accessibility issues found across all elements in all
 * scans.
 */
- (NSUInteger)issueCount;

/**
 * @return All unique issues found across all scans.
 */
- (NSArray<GSCXScannerIssue *> *)uniqueIssues;

/**
 * @return All scan results with duplicate issues removed. If a result only contained duplicate
 * issues, it is removed from the returned array.
 */
- (NSArray<GSCXScannerResult *> *)uniqueScanResults;

@end

NS_ASSUME_NONNULL_END
