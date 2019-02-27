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

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScanner () {
  GTXToolKit *_toolkit;
}

/**
 *  Iterates over an array of NSError objects received from GTXToolKit calls and constructs
 *  GSCXScannerIssue instances from them. Returns a GSCXScannerResult containing an array of
 *  GSCXScannerIssue objects. rootView is the view the scan was initiated on.
 */
- (NSArray<GSCXScannerIssue *> *)_scannerIssuesFromErrors:(NSArray<NSError *> *)errors;
/**
 *  Constructs a GSCXScannerIssue object from an NSError object.
 */
- (GSCXScannerIssue *)_scannerIssueFromError:(NSError *)error;
/**
 *  Creates a snapshot view by overlaying snapshots of each view. If snapshotAfterScreenUpdates:
 *  returns nil for any view, that view is not included in the screenshot.
 *
 *  @param rootViews The views to overlay snapshots of.
 *  @return A UIView containing overlaid snapshots of all views for which
 *  snapshotAfterScreenUpdates: did not return nil, or nil if no views generated a snapshot.
 */
- (UIView *_Nullable)_snapshotOfRootViews:(NSArray<UIView *> *)rootViews;

@end

@implementation GSCXScanner

- (instancetype)init {
  self = [super init];
  if (self) {
    _toolkit = [[GTXToolKit alloc] init];
  }
  return self;
}

+ (instancetype)scanner {
  return [[GSCXScanner alloc] init];
}

+ (instancetype)scannerWithChecks:(NSArray<id<GTXChecking>> *)checks
                       blacklists:(NSArray<id<GTXBlacklisting>> *)blacklists {
  GSCXScanner *scanner = [GSCXScanner scanner];
  for (id<GTXChecking> check in checks) {
    [scanner registerCheck:check];
  }
  for (id<GTXBlacklisting> blacklist in blacklists) {
    [scanner registerBlacklist:blacklist];
  }
  return scanner;
}

- (GSCXScannerResult *)scanRootViews:(NSArray<UIView *> *)rootViews {
  if ([self.delegate respondsToSelector:@selector(scannerWillBeginScan:)]) {
    [self.delegate scannerWillBeginScan:self];
  }
  NSError *error = nil;
  BOOL passesChecks = [_toolkit checkAllElementsFromRootElements:rootViews error:&error];
  NSArray<NSError *> *errors = nil;
  if (passesChecks) {
    errors = @[];
  } else {
    NSAssert(error, @"Error must be provided by GTXToolKit.");
    errors = [error.userInfo objectForKey:kGTXErrorUnderlyingErrorsKey];
  }
  NSArray<GSCXScannerIssue *> *issues = [self _scannerIssuesFromErrors:errors];
  UIView *_Nullable snapshot = [self _snapshotOfRootViews:rootViews];
  _lastScanResult = [[GSCXScannerResult alloc] initWithIssues:issues screenshot:snapshot];
  if ([self.delegate respondsToSelector:@selector(scanner:didFinishScanWithResult:)]) {
    [self.delegate scanner:self didFinishScanWithResult:self.lastScanResult];
  }
  return _lastScanResult;
}

- (void)registerCheck:(id<GTXChecking>)check {
  [_toolkit registerCheck:check];
}

- (void)registerBlacklist:(id<GTXBlacklisting>)blacklist {
  [_toolkit registerBlacklist:blacklist];
}

#pragma mark - Private

- (NSArray<GSCXScannerIssue *> *)_scannerIssuesFromErrors:(NSArray<NSError *> *)errors {
  NSMutableArray<GSCXScannerIssue *> *issues = [[NSMutableArray alloc] init];
  for (NSError *error in errors) {
    [issues addObject:[self _scannerIssueFromError:error]];
  }
  return issues;
}

- (GSCXScannerIssue *)_scannerIssueFromError:(NSError *)error {
  NSArray<NSError *> *underlyingErrors = [error.userInfo objectForKey:kGTXErrorUnderlyingErrorsKey];
  NSAssert(underlyingErrors, @"underlyingErrors cannot be nil.");
  NSMutableArray<NSString *> *gtxCheckNames = [[NSMutableArray alloc] init];
  NSMutableArray<NSString *> *gtxCheckDescriptions = [[NSMutableArray alloc] init];
  for (NSError *underlyingError in underlyingErrors) {
    NSDictionary *userInfo = underlyingError.userInfo;
    NSString *checkName = [userInfo objectForKey:kGTXErrorCheckNameKey];
    NSString *checkDescription = [userInfo objectForKey:NSLocalizedDescriptionKey];
    NSAssert(userInfo, @"userInfo cannot be nil.");
    NSAssert(checkName, @"checkName cannot be nil.");
    NSAssert(checkDescription, @"checkDescription cannot be nil.");
    [gtxCheckNames addObject:checkName];
    [gtxCheckDescriptions addObject:checkDescription];
  }
  UIView *element = [error.userInfo objectForKey:kGTXErrorFailingElementKey];
  NSAssert(element, @"element cannot be nil.");
  return [GSCXScannerIssue issueWithCheckNames:gtxCheckNames
                             checkDescriptions:gtxCheckDescriptions
                           frameInScreenBounds:element.accessibilityFrame
                            accessibilityLabel:element.accessibilityLabel];
}

- (UIView *_Nullable)_snapshotOfRootViews:(NSArray<UIView *> *)rootViews {
  UIView *_Nullable snapshot = nil;
  for (UIView *view in rootViews) {
    UIView *_Nullable image = [view snapshotViewAfterScreenUpdates:NO];
    if (snapshot == nil) {
      snapshot = image;
    } else {
      [snapshot addSubview:image];
    }
  }
  return snapshot;
}

@end

NS_ASSUME_NONNULL_END
