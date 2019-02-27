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

#import "GSCXHitForwardingWindow.h"
#import "GSCXInstaller.h"
#import "GSCXScanner.h"
#import "GSCXTestTagCheck.h"
#import "GSCXTestViewController.h"
#import "GSCXUITestViewController.h"

NSString *const kWindowOverlayTypeKey = @"overlayType";
NSString *const kWindowOverlayTypeTransparent = @"transparent";
NSString *const kWindowOverlayTypeOpaque = @"opaque";
NSString *const kMainWindowAccessibilityId = @"kMainWindowAccessibilityId";
NSString *const kGSCXTestTagCheckName1 = @"kGSCXTestTagCheckName1";
const NSInteger kGSCXTestTagCheckTag1 = 127;
NSString *const kGSCXTestTagCheckName2 = @"kGSCXTestTagCheckName2";
const NSInteger kGSCXTestTagCheckTag2 = 126;
NSString *const kGSCXTestTagCheckName3 = @"kGSCXTestTagCheckName3";
const NSInteger kGSCXTestTagCheckTag3 = 125;
NSString *const kGSCXTestTagCheckName4 = @"kGSCXTestTagCheckName4";
const NSInteger kGSCXTestTagCheckTag4 = kGSCXTestTagCheckTag1;

@implementation GSCXTestAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSString *overlayType =
      [[[NSProcessInfo processInfo] environment] objectForKey:kWindowOverlayTypeKey];
  if (overlayType == nil) {
    overlayType = kWindowOverlayTypeTransparent;
  }
  NSParameterAssert([self _isValidOverlayType:overlayType]);

  [self _installApplicationWindow:overlayType];
  if ([overlayType isEqualToString:kWindowOverlayTypeTransparent]) {
    [self _installTransparentOverlay];
  } else if ([overlayType isEqualToString:kWindowOverlayTypeOpaque]) {
    [self _installOpaqueOverlay];
  }

  return YES;
}

#pragma mark - Private

/**
 *  Determines if the "overlayType" environment variable is set correctly.
 *
 *  @param overlayType The "overlayType" environment variable accessed from NSProcessInfo.
 *  @return YES if overlayType is "transparent" or "opaque", NO if it is another string or nil.
 */
- (BOOL)_isValidOverlayType:(NSString *)overlayType {
  return overlayType != nil && ([overlayType isEqualToString:kWindowOverlayTypeTransparent] ||
                                [overlayType isEqualToString:kWindowOverlayTypeOpaque]);
}

/**
 *  Sets @c window to the main application window and makes it visible.
 *
 *  @param overlayType The overlay type being displayed over the main application window. If
 *  @c overlayType is @c gWindowOverlayTypeTransparent, then the main application window's root view
 *  controller is a navigation controller with a GSCXTestViewController. If @c overlayType is
 *  @c gWindowOverlayTypeOpaque, then the navigation controller's first view controller is a
 *  GSCXUITestsViewController.
 */
- (void)_installApplicationWindow:(NSString *)overlayType {
  NSParameterAssert([self _isValidOverlayType:overlayType]);

  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  self.window = [[UIWindow alloc] initWithFrame:screenBounds];
  UIViewController *rootViewController = nil;
  if ([overlayType isEqualToString:kWindowOverlayTypeTransparent]) {
    rootViewController = [[GSCXTestViewController alloc] initWithNibName:@"GSCXTestViewController"
                                                                  bundle:nil];
  } else if ([overlayType isEqualToString:kWindowOverlayTypeOpaque]) {
    rootViewController =
        [[GSCXUITestViewController alloc] initWithNibName:@"GSCXUITestViewController" bundle:nil];
  }
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:rootViewController];
  self.window.rootViewController = navigationController;
  self.window.rootViewController.view.backgroundColor = [UIColor redColor];
  self.window.accessibilityIdentifier = kMainWindowAccessibilityId;
  [self.window makeKeyAndVisible];
}

/**
 *  Sets @c overlayWindow to a UIWindow instance that forwards hit events to the underlying window.
 */
- (void)_installTransparentOverlay {
  NSArray<id<GTXChecking>> *checks = @[
    [GSCXTestTagCheck checkWithName:kGSCXTestTagCheckName1 tag:kGSCXTestTagCheckTag1],
    [GSCXTestTagCheck checkWithName:kGSCXTestTagCheckName2 tag:kGSCXTestTagCheckTag2],
    [GSCXTestTagCheck checkWithName:kGSCXTestTagCheckName3 tag:kGSCXTestTagCheckTag3],
    [GSCXTestTagCheck checkWithName:kGSCXTestTagCheckName4 tag:kGSCXTestTagCheckTag4],
  ];
  self.overlayWindow = [GSCXInstaller installScannerOverWindow:self.window
                                                        checks:checks
                                                    blacklists:@[]
                                                      delegate:nil];
}

/**
 *  Sets @c overlayWindow to a UIWindow instance that does not forward hit events to the underlying
 * window.
 */
- (void)_installOpaqueOverlay {
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  UIWindow *overlayWindow = [[UIWindow alloc] initWithFrame:screenBounds];
  overlayWindow.rootViewController = [[UIViewController alloc] init];
  overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
  overlayWindow.hidden = NO;
  self.overlayWindow = overlayWindow;
}

@end
