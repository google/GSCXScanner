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
 * The blacklists used by @c _toolkit to skip elements. Must be stored here so the toolkit can be
 * re-instantiated when blacklists are added or removed.
 */
@property(strong, nonatomic) NSMutableSet<id<GTXBlacklisting>> *blacklists;

/**
 * Iterates over an array of NSError objects received from GTXToolKit calls and constructs
 * GSCXScannerIssue instances from them. Returns a GSCXScannerResult containing an array of
 * GSCXScannerIssue objects. rootView is the view the scan was initiated on.
 */
- (NSArray<GSCXScannerIssue *> *)gscx_scannerIssuesFromErrors:(NSArray<NSError *> *)errors;

/**
 * Constructs a GSCXScannerIssue object from an NSError object.
 */
- (GSCXScannerIssue *)gscx_scannerIssueFromError:(NSError *)error;

/**
 * Creates a snapshot view by overlaying snapshots of each view. If snapshotAfterScreenUpdates:
 * returns nil for any view, that view is not included in the screenshot.
 *
 * @param rootViews The views to overlay snapshots of.
 * @return A UIView containing overlaid snapshots of all views for which
 * snapshotAfterScreenUpdates: did not return nil, or nil if no views generated a snapshot.
 */
- (UIView *_Nullable)gscx_snapshotOfRootViews:(NSArray<UIView *> *)rootViews;

@end

@implementation GSCXScanner

- (instancetype)init {
  self = [super init];
  if (self) {
    _toolkit = [GTXToolKit toolkitWithNoChecks];
    _checks = [[NSMutableDictionary alloc] init];
    _blacklists = [[NSMutableSet alloc] init];
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
  GTXResult *gtxResult = [_toolkit resultFromCheckingAllElementsFromRootElements:rootViews];
  NSArray<NSError *> *errors = gtxResult.errorsFound;
  if (errors.count) {
    [GSCXAnalytics invokeAnalyticsEvent:GSCXAnalyticsEventErrorsFound count:errors.count];
  } else {
    [GSCXAnalytics invokeAnalyticsEvent:GSCXAnalyticsEventScanPerformed count:1];
  }
  NSArray<GSCXScannerIssue *> *issues = [self gscx_scannerIssuesFromErrors:errors];
  UIView *_Nullable snapshot = [self gscx_snapshotOfRootViews:rootViews];
  _lastScanResult = [[GSCXScannerResult alloc] initWithIssues:issues screenshot:snapshot];
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

- (void)registerBlacklist:(id<GTXBlacklisting>)blacklist {
  [_toolkit registerBlacklist:blacklist];
  [self.blacklists addObject:blacklist];
}

- (void)deregisterBlacklist:(id<GTXBlacklisting>)blacklist {
  [self.blacklists removeObject:blacklist];
  [self gscx_reinitializeToolkit];
}

#pragma mark - Private

/**
 * Constructs a new @c GSCXToolKit instance with the current checks and blacklists. @c _toolkit is
 * guaranteed to have all the checks and blacklists registered when it is assigned.
 */
- (void)gscx_reinitializeToolkit {
  GTXToolKit *toolkit = [GTXToolKit toolkitWithNoChecks];
  for (NSString *name in self.checks) {
    [toolkit registerCheck:self.checks[name]];
  }
  for (id<GTXBlacklisting> blacklist in self.blacklists) {
    [toolkit registerBlacklist:blacklist];
  }
  _toolkit = toolkit;
}

- (NSArray<GSCXScannerIssue *> *)gscx_scannerIssuesFromErrors:(NSArray<NSError *> *)errors {
  NSMutableArray<GSCXScannerIssue *> *issues = [[NSMutableArray alloc] init];
  for (NSError *error in errors) {
    [issues addObject:[self gscx_scannerIssueFromError:error]];
  }
  return issues;
}

- (GSCXScannerIssue *)gscx_scannerIssueFromError:(NSError *)error {
  NSArray<NSError *> *underlyingErrors = [error.userInfo objectForKey:kGTXErrorUnderlyingErrorsKey];
  GTX_ASSERT(underlyingErrors, @"underlyingErrors cannot be nil.");
  NSMutableArray<NSString *> *gtxCheckNames = [[NSMutableArray alloc] init];
  NSMutableArray<NSString *> *gtxCheckDescriptions = [[NSMutableArray alloc] init];
  for (NSError *underlyingError in underlyingErrors) {
    NSDictionary *userInfo = underlyingError.userInfo;
    NSString *checkName = [userInfo objectForKey:kGTXErrorCheckNameKey];
    NSString *checkDescription = [userInfo objectForKey:NSLocalizedDescriptionKey];
    GTX_ASSERT(userInfo, @"userInfo cannot be nil.");
    GTX_ASSERT(checkName, @"checkName cannot be nil.");
    GTX_ASSERT(checkDescription, @"checkDescription cannot be nil.");
    [gtxCheckNames addObject:checkName];
    [gtxCheckDescriptions addObject:checkDescription];
  }
  UIView *element = [error.userInfo objectForKey:kGTXErrorFailingElementKey];
  GTX_ASSERT(element, @"element cannot be nil.");
  NSString *elementDescription = [NSString stringWithFormat:@"%@ %p", element.class, element];
  return [GSCXScannerIssue issueWithCheckNames:gtxCheckNames
                             checkDescriptions:gtxCheckDescriptions
                                elementAddress:(NSUInteger)element
                                  elementClass:[element class]
                           frameInScreenBounds:element.accessibilityFrame
                            accessibilityLabel:element.accessibilityLabel
                       accessibilityIdentifier:element.accessibilityIdentifier
                            elementDescription:elementDescription];
}

- (UIView *_Nullable)gscx_snapshotOfRootViews:(NSArray<UIView *> *)rootViews {
  UIView *_Nullable snapshot = nil;
  for (UIView *view in rootViews) {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    // Passing YES to afterScreenUpdates resets VoiceOver focus to the first element in the
    // accessibility hierarchy. Passing NO does not cause this. This is likely a bug in
    // drawViewHierarchyInRect. A radar has been filed.
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (snapshot == nil) {
      snapshot = imageView;
    } else {
      [snapshot addSubview:imageView];
    }
  }
  return snapshot;
}

@end

NS_ASSUME_NONNULL_END
