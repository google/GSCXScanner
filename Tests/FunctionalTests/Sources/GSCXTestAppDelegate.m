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

#import "GSCXTestAppDelegate.h"

#import "GSCXContinuousScannerPeriodicScheduler.h"
#import "GSCXInstaller.h"
#import "GSCXInstallerOptions+Internal.h"
#import "GSCXScanner.h"
#import "GSCXScannerWindowCoordinator.h"
#import "third_party/objective_c/GSCXScanner/Tests/Common/GSCXManualScheduler.h"
#import "GSCXTestCheck.h"
#import "GSCXTestCheckNames.h"
#import "GSCXTestEnvironmentVariables.h"
#import "GSCXTestSharingDelegate.h"
#import "GSCXTestViewController.h"
#import "GSCXUITestViewController.h"
#import <GTXiLib/GTXiLib.h>
NSString *const kMainWindowAccessibilityId = @"kMainWindowAccessibilityId";

@interface GSCXTestAppDelegate ()

/**
 * The scheduler used to manually trigger scan events when not in periodic scheduling mode. If in
 * periodic scheduling mode, this property is @c nil.
 */
@property(strong, nonatomic, nullable) GSCXManualScheduler *manualScheduler;

@end

@implementation GSCXTestAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  BOOL isMultiWindowPresentation = [self gscxtest_resultsWindowPresentationType];
  NSString *overlayType = [self gscxtest_windowOverlayType];
  NSNumber *schedulingInterval = [self gscxtest_continuousScanTimeInterval];
  BOOL useTestSharingDelegate = [self gscxtest_useTestSharingDelegate];
  BOOL useCanonicalGTXChecks = [self gscxtest_useCanonicalGTXChecks];

  [self gscxtest_installApplicationWindow:overlayType];
  if ([overlayType isEqualToString:kEnvWindowOverlayTypeTransparent]) {
    [self gscxtest_installTransparentOverlay:isMultiWindowPresentation
                          schedulingInterval:schedulingInterval
                      useTestSharingDelegate:useTestSharingDelegate
                       useCanonicalGTXChecks:useCanonicalGTXChecks];
  } else if ([overlayType isEqualToString:kEnvWindowOverlayTypeOpaque]) {
    [self gscxtest_installOpaqueOverlay];
  }

  return YES;
}

#pragma mark - Private

- (BOOL)gscxtest_resultsWindowPresentationType {
  NSString *resultsWindowPresentationType =
      [[[NSProcessInfo processInfo] environment] objectForKey:kEnvResultsWindowPresentationTypeKey];
  if (resultsWindowPresentationType == nil) {
    resultsWindowPresentationType = kEnvResultsWindowPresentationTypeSingle;
  }
  NSParameterAssert(
      [self gscxtest_isValidResultsWindowPresentationType:resultsWindowPresentationType]);
  BOOL isMultiWindowPresentation = NO;
  if ([resultsWindowPresentationType isEqualToString:kEnvResultsWindowPresentationTypeMultiple]) {
    isMultiWindowPresentation = YES;
  }
  return isMultiWindowPresentation;
}

- (NSString *)gscxtest_windowOverlayType {
  NSString *overlayType =
      [[[NSProcessInfo processInfo] environment] objectForKey:kEnvWindowOverlayTypeKey];
  if (overlayType == nil) {
    overlayType = kEnvWindowOverlayTypeTransparent;
  }
  NSParameterAssert([self gscxtest_isValidOverlayType:overlayType]);
  return overlayType;
}

- (NSNumber *)gscxtest_continuousScanTimeInterval {
  NSString *timeInterval =
      [[[NSProcessInfo processInfo] environment] objectForKey:kEnvContinuousScannerTimeIntervalKey];
  if (timeInterval) {
    return @([timeInterval doubleValue]);
  } else {
    return nil;
  }
}

/**
 * @return @c YES if the @c kUseTestSharingDelegateKey environment variable exists and has a truthy
 * value, @c NO otherwise.
 */
- (BOOL)gscxtest_useTestSharingDelegate {
  return [[[[NSProcessInfo processInfo] environment] objectForKey:kEnvUseTestSharingDelegateKey]
      boolValue];
}

/**
 * Determines if the "overlayType" environment variable is set correctly.
 *
 * @param overlayType The "overlayType" environment variable accessed from NSProcessInfo.
 * @return YES if overlayType is "transparent" or "opaque", NO if it is another string or nil.
 */
- (BOOL)gscxtest_isValidOverlayType:(NSString *)overlayType {
  return overlayType != nil && ([overlayType isEqualToString:kEnvWindowOverlayTypeTransparent] ||
                                [overlayType isEqualToString:kEnvWindowOverlayTypeOpaque]);
}

/**
 * Determines if the "resultsWindowPresentationType" environment variable is set correctly.
 *
 * @param resultsWindowPresentationType The "resultsWindowPresentationType" environment variable
 * accessed from NSProcessInfo.
 * @return YES if resultsWindowPresentationType is "single" or "multiple", NO if it is another
 * string or nil.
 */
- (BOOL)gscxtest_isValidResultsWindowPresentationType:(NSString *)resultsWindowPresentationType {
  return resultsWindowPresentationType != nil &&
         ([resultsWindowPresentationType isEqualToString:kEnvResultsWindowPresentationTypeSingle] ||
          [resultsWindowPresentationType
              isEqualToString:kEnvResultsWindowPresentationTypeMultiple]);
}

/**
 * @return @c YES if the @c kUseCanonicalGTXChecks environment variable exists and has a truthy
 * value, @c NO otherwise.
 */
- (BOOL)gscxtest_useCanonicalGTXChecks {
  return [[[[NSProcessInfo processInfo] environment] objectForKey:kEnvUseCanonicalGTXChecksKey]
      boolValue];
}

/**
 * Sets @c window to the main application window and makes it visible.
 *
 * @param overlayType The overlay type being displayed over the main application window. If
 * @c overlayType is @c gWindowOverlayTypeTransparent, then the main application window's root view
 * controller is a navigation controller with a GSCXTestViewController. If @c overlayType is
 * @c gWindowOverlayTypeOpaque, then the navigation controller's first view controller is a
 * GSCXUITestsViewController.
 */
- (void)gscxtest_installApplicationWindow:(NSString *)overlayType {
  NSParameterAssert([self gscxtest_isValidOverlayType:overlayType]);

  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  self.window = [[UIWindow alloc] initWithFrame:screenBounds];
  UIViewController *rootViewController = nil;
  if ([overlayType isEqualToString:kEnvWindowOverlayTypeTransparent]) {
    rootViewController = [[GSCXTestViewController alloc] initWithNibName:@"GSCXTestViewController"
                                                                  bundle:nil];
  } else if ([overlayType isEqualToString:kEnvWindowOverlayTypeOpaque]) {
    rootViewController =
        [[GSCXUITestViewController alloc] initWithNibName:@"GSCXUITestViewController" bundle:nil];
  }
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:rootViewController];
  self.window.rootViewController = navigationController;
  self.window.accessibilityIdentifier = kMainWindowAccessibilityId;
  [self.window makeKeyAndVisible];
}

/**
 * Sets @c overlayWindow to a UIWindow instance that forwards hit events to the underlying window.
 */
- (void)gscxtest_installTransparentOverlay:(BOOL)isMultiWindowPresentation
                        schedulingInterval:(NSNumber *)schedulingInterval
                    useTestSharingDelegate:(BOOL)useTestSharingDelegate
                     useCanonicalGTXChecks:(BOOL)useCanonicalGTXChecks {
  NSArray<id<GTXChecking>> *checks = @[
    [GSCXTestCheck checkWithName:kGSCXTestCheckName1 tag:kGSCXTestCheckTag1],
    [GSCXTestCheck checkWithName:kGSCXTestCheckName2 tag:kGSCXTestCheckTag2],
    [GSCXTestCheck checkWithName:kGSCXTestCheckName3 tag:kGSCXTestCheckTag3],
    [GSCXTestCheck checkWithName:kGSCXTestCheckName4 tag:kGSCXTestCheckTag4],
    [GSCXTestCheck UTF8CheckWithName:kGSCXTestUTF8CheckName5 tag:kGSCXTestUTF8CheckTag5],
  ];
  if (useCanonicalGTXChecks) {
    checks = [checks arrayByAddingObjectsFromArray:[GTXChecksCollection
                                                       allGTXChecksForVersion:GTXVersionLatest]];
  }
  NSArray<id<GSCXContinuousScannerScheduling>> *schedulers = nil;
  if (schedulingInterval) {
    NSTimeInterval timeInterval = [schedulingInterval doubleValue];
    schedulers =
        @[ [GSCXContinuousScannerPeriodicScheduler schedulerWithTimeInterval:timeInterval] ];
  } else {
    self.manualScheduler = [[GSCXManualScheduler alloc] init];
    schedulers = @[ self.manualScheduler ];
  }
  GSCXInstallerOptions *options = [[GSCXInstallerOptions alloc] init];
  options.checks = checks;
  options.schedulers = schedulers;
  options.multiWindowPresentation = isMultiWindowPresentation;
  options.sharingDelegate = useTestSharingDelegate ? [[GSCXTestSharingDelegate alloc] init] : nil;
  self.overlayWindow = [GSCXInstaller installScannerWithOptions:options];
}

/**
 * Sets @c overlayWindow to a UIWindow instance that does not forward hit events to the underlying
 * window.
 */
- (void)gscxtest_installOpaqueOverlay {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  UIWindow *overlayWindow = [[UIWindow alloc] initWithFrame:screenBounds];
  overlayWindow.rootViewController = [[UIViewController alloc] init];
  overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
  overlayWindow.hidden = NO;
  self.overlayWindow = overlayWindow;
}

- (void)triggerScheduleScanEvent {
  GTX_ASSERT(self.manualScheduler,
             @"Cannot simulate schedule scan event in periodic scheduling mode.");
  [self.manualScheduler triggerScheduleScanEvent];
}

@end
