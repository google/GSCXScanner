//
// Copyright 2018 Google Inc.
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

#import "GSCXScanner.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXScanner () {
  GTXToolKit *_toolkit;
}

/**
 * The checks used by @c _toolkit to check elements. Must be stored here so the toolkit can be
 * re-instantiated when checks are added or removed.
 */
@property(strong, nonatomic) NSMutableDictionary<NSString *, id<GTXChecking>> *checks;

/**
 * The excludeLists used by @c _toolkit to skip elements. Must be stored here so the toolkit can be
 * re-instantiated when excludeLists are added or removed.
 */
@property(strong, nonatomic) NSMutableSet<id<GTXExcludeListing>> *excludeLists;

@end

@implementation GSCXScanner

- (instancetype)init {
  self = [super init];
  if (self) {
    _toolkit = [GTXToolKit toolkitWithNoChecks];
    _checks = [[NSMutableDictionary alloc] init];
    _excludeLists = [[NSMutableSet alloc] init];
  }
  return self;
}

+ (instancetype)scanner {
  return [[GSCXScanner alloc] init];
}

+ (instancetype)scannerWithChecks:(NSArray<id<GTXChecking>> *)checks
                     excludeLists:(NSArray<id<GTXExcludeListing>> *)excludeLists {
  GSCXScanner *scanner = [GSCXScanner scanner];
  for (id<GTXChecking> check in checks) {
    [scanner registerCheck:check];
  }
  for (id<GTXExcludeListing> excludeList in excludeLists) {
    [scanner registerExcludeList:excludeList];
  }
  return scanner;
}

- (GTXHierarchyResultCollection *)scanRootViews:(NSArray<UIView *> *)rootViews {
  GTX_ASSERT(rootViews.count > 0, @"rootViews cannot be empty.");
  if ([self.delegate respondsToSelector:@selector(scannerWillBeginScan:)]) {
    [self.delegate scannerWillBeginScan:self];
  }
  GTXResult *gtxResult = [_toolkit resultFromCheckingAllElementsFromRootElements:rootViews];
  NSArray<NSError *> *errors = gtxResult.errorsFound;
  if (errors.count) {
    [GSCXAnalytics invokeAnalyticsEvent:GSCXAnalyticsEventErrorsFound count:errors.count];
  } else {
    [GSCXAnalytics invokeAnalyticsEvent:GSCXAnalyticsEventScanPerformed count:1];
  }
  _lastScanResult = [[GTXHierarchyResultCollection alloc] initWithErrors:gtxResult.errorsFound
                                                               rootViews:rootViews];
  if ([self.delegate respondsToSelector:@selector(scanner:didFinishScanWithResult:)]) {
    [self.delegate scanner:self didFinishScanWithResult:self.lastScanResult];
  }
  return _lastScanResult;
}

- (void)registerCheck:(id<GTXChecking>)check {
  [_toolkit registerCheck:check];
  self.checks[[check name]] = check;
}

- (void)deregisterCheck:(id<GTXChecking>)check {
  [self.checks removeObjectForKey:[check name]];
  [self gscx_reinitializeToolkit];
}

- (void)registerExcludeList:(id<GTXExcludeListing>)excludeList {
  [_toolkit registerExcludeList:excludeList];
  [self.excludeLists addObject:excludeList];
}

- (void)deregisterExcludeList:(id<GTXExcludeListing>)excludeList {
  [self.excludeLists removeObject:excludeList];
  [self gscx_reinitializeToolkit];
}

#pragma mark - Private

/**
 * Constructs a new @c GSCXToolKit instance with the current checks and excludeLists. @c _toolkit is
 * guaranteed to have all the checks and excludeLists registered when it is assigned.
 */
- (void)gscx_reinitializeToolkit {
  GTXToolKit *toolkit = [GTXToolKit toolkitWithNoChecks];
  for (NSString *name in self.checks) {
    [toolkit registerCheck:self.checks[name]];
  }
  for (id<GTXExcludeListing> excludeList in self.excludeLists) {
    [toolkit registerExcludeList:excludeList];
  }
  _toolkit = toolkit;
}

@end

NS_ASSUME_NONNULL_END
