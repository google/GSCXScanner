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

#import "GSCXInstaller.h"

#import "GSCXScanner.h"
#import "GSCXHitForwardingWindow.h"
#import "GSCXScannerOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXInstaller

+ (UIWindow *)installScannerOverWindow:(UIWindow *)applicationWindow
                                checks:(NSArray<id<GTXChecking>> *)checks
                            blacklists:(NSArray<id<GTXBlacklisting>> *)blacklists
                              delegate:(nullable id<GSCXScannerDelegate>)delegate {
  BOOL setupSuccessful = [GTXTestEnvironment setupEnvironmentWithError:nil];
  CGRect frame = [[UIScreen mainScreen] bounds];
  GSCXHitForwardingWindow *overlayWindow = [[GSCXHitForwardingWindow alloc] initWithFrame:frame];
  GSCXScannerOverlayViewController *viewController = [[GSCXScannerOverlayViewController alloc]
           initWithNibName:@"GSCXScannerOverlayViewController"
                    bundle:[NSBundle bundleForClass:[GSCXScannerOverlayViewController class]]
      accessibilityEnabled:setupSuccessful || UIAccessibilityIsVoiceOverRunning()];
  viewController.windowOverlayPair =
      [[GSCXWindowOverlayPair alloc] initWithOverlayWindow:overlayWindow
                                         applicationWindow:applicationWindow];
  viewController.scanner = [GSCXScanner scannerWithChecks:checks blacklists:blacklists];
  viewController.scanner.delegate = delegate;
  overlayWindow.rootViewController = viewController;
  overlayWindow.hidden = NO;
  return overlayWindow;
}

+ (UIWindow *)installScanner {
  NSArray<id<GTXChecking>> *checks = [GTXChecksCollection allGTXChecks];
  return [GSCXInstaller installScannerOverWindow:[[UIApplication sharedApplication] keyWindow]
                                          checks:checks
                                      blacklists:@[]
                                        delegate:nil];
}

@end

NS_ASSUME_NONNULL_END
