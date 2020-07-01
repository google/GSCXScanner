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

#import "GSCXContinuousScanner.h"

#import "GSCXScanner.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScanner ()

/**
 * Scans view hierarchies for accessibility issues.
 */
@property(strong, nonatomic) GSCXScanner *scanner;

/**
 * Is notified about scan lifecycle events and determines which view hierarchies to scan.
 */
@property(weak, nonatomic) id<GSCXContinuousScannerDelegate> delegate;

/**
 * Schedules scans when the application is likely to need them.
 */
@property(strong, nonatomic) id<GSCXContinuousScannerScheduling> scheduler;

@end

@implementation GSCXContinuousScanner

- (instancetype)initWithScanner:(GSCXScanner *)scanner
                       delegate:(__weak id<GSCXContinuousScannerDelegate>)delegate
                      scheduler:(id<GSCXContinuousScannerScheduling>)scheduler {
  self = [super init];
  if (self) {
    _scanner = scanner;
    _delegate = delegate;
    _scheduler = scheduler;
    _scanResults = [NSArray array];
  }
  return self;
}

+ (instancetype)scannerWithScanner:(GSCXScanner *)scanner
                          delegate:(__weak id<GSCXContinuousScannerDelegate>)delegate
                         scheduler:(id<GSCXContinuousScannerScheduling>)scheduler {
  return [[GSCXContinuousScanner alloc] initWithScanner:scanner
                                               delegate:delegate
                                              scheduler:scheduler];
}

- (void)startScanning {
  GTX_ASSERT(![self isScanning], @"Cannot start scanning while already scanning.");
  if ([self.delegate respondsToSelector:@selector(continuousScannerWillStart:)]) {
    [self.delegate continuousScannerWillStart:self];
  }
  _scanResults = @[];
  __weak __typeof__(self) weakSelf = self;
  [self.scheduler startSchedulingWithCallback:^(id<GSCXContinuousScannerScheduling> scheduler) {
    return [weakSelf gscx_performScan];
  }];
}

- (void)stopScanning {
  GTX_ASSERT([self isScanning], @"Cannot stop scanning while not scanning.");
  [self.scheduler stopScheduling];
}

- (BOOL)isScanning {
  return [self.scheduler isScheduling];
}

- (NSUInteger)issueCount {
  NSUInteger count = 0;
  for (GSCXScannerResult *result in self.scanResults) {
    count += result.issueCount;
  }
  return count;
}

- (NSArray<GSCXScannerIssue *> *)uniqueIssues {
  NSMutableArray<GSCXScannerIssue *> *issues = [NSMutableArray array];
  for (GSCXScannerResult *result in self.scanResults) {
    [issues addObjectsFromArray:result.issues];
  }
  return [GSCXScannerIssue arrayByDedupingArray:issues];
}

- (NSArray<GSCXScannerResult *> *)uniqueScanResults {
  return [GSCXScannerResult resultsArrayByDedupingResultsArray:self.scanResults];
}

#pragma mark - Private

/**
 * Performs a scan for accessibility issues. Notifies the delegate that a scan occurred.
 *
 * @return @c YES if a scan occurred, @c NO otherwise. Currently, a scan always occurs, so @c YES is
 * always returned.
 */
- (BOOL)gscx_performScan {
  GSCXScannerResult *result = [self.scanner scanRootViews:[self.delegate rootViewsToScan]];
  _scanResults = [_scanResults arrayByAddingObject:result];
  if ([self.delegate respondsToSelector:@selector(continuousScanner:didPerformScanWithResult:)]) {
    [self.delegate continuousScanner:self didPerformScanWithResult:result];
  }
  return YES;
}

@end

NS_ASSUME_NONNULL_END
