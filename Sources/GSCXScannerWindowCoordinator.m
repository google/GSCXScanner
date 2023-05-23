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

#import "GSCXScannerWindowCoordinator.h"

#import <Foundation/Foundation.h>

#import "UIView+GSCXAppearance.h"
#import "UIWindow+GSCXScannerAdditions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An offset applied to scanner windows' @c windowLevel so they always appear above application
 * windows but below system alerts.
 */
const CGFloat kGSCXScannerWindowLevelOffset = 2.0f;

@interface GSCXScannerWindowCoordinator () {
  /**
   * @c YES if multiple results windows can be presented at once, @c NO otherwise. Defaults to @c
   * NO.
   */
  BOOL _isMultiWindowPresentation;

  /**
   * The stack of results windows. The last element of @c _resultsWindows contains the currently
   * presented window. If @c _resultsWindows is empty, then no results windows are being displayed.
   */
  NSMutableArray<UIWindow *> *_resultsWindows;

  /**
   * The window that was key before presenting the first results window. When the first results
   * window is dismissed, this window is made the key again.
   */
  UIWindow *__weak _previousKeyWindow;
}

/**
 * @return The most recently presented results window, or @c nil if no results window is being
 * presented.
 */
- (nullable UIWindow *)gscx_topWindow;

/**
 * Removes the most recently presented results window from the stack. It is the responsibility of
 * the caller to remove it from the screen.
 *
 * @return The most recently presented results window, or @c nil if no results window has been
 * presented.
 */
- (nullable UIWindow *)gscx_popTopWindow;

/**
 * @return The current key window in the current scene.
 */
- (UIWindow *)gscx_findKeyWindow;

/**
 * @return A plain window and view controller. The window is presented on screen and made key.
 */
- (UIWindow *)gscx_presentResultsWindow;

@end

@implementation GSCXScannerWindowCoordinator

- (instancetype)initWithMultiWindowPresentation:(BOOL)isMultiWindowPresentation {
  if (self = [super init]) {
    _isMultiWindowPresentation = isMultiWindowPresentation;
    _resultsWindows = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(gscx_updateUserInterfaceStyleForOverlayWindows)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
  }
  return self;
}

+ (instancetype)coordinator {
  return [[GSCXScannerWindowCoordinator alloc] initWithMultiWindowPresentation:NO];
}

+ (instancetype)coordinatorWithMultiWindowPresentation:(BOOL)isMultiWindowPresentation {
  return [[GSCXScannerWindowCoordinator alloc]
      initWithMultiWindowPresentation:isMultiWindowPresentation];
}

- (void)presentViewController:(nonnull UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(nullable void (^)(void))completionBlock {
  UIWindow *topWindow = [self gscx_presentResultsWindow];
  [topWindow.rootViewController presentViewController:viewController
                                             animated:animated
                                           completion:completionBlock];
}

- (void)dismissViewControllerAnimated:(BOOL)animated
                           completion:(nullable void (^)(void))completion {
  UIWindow *topWindow = [self gscx_topWindow];
  __weak __typeof__(self) weakSelf = self;
  [topWindow.rootViewController dismissViewControllerAnimated:animated
                                                   completion:^{
                                                     [weakSelf dismissResultsWindow];
                                                     if (completion) {
                                                       completion();
                                                     }
                                                   }];
}

- (void)dismissResultsWindow {
  [self gscx_popTopWindow];
  if ([self gscx_topWindow]) {
    [[self gscx_topWindow] makeKeyAndVisible];
  } else {
    [_previousKeyWindow makeKeyWindow];
  }
}

+ (UIWindowLevel)windowLevel {
  // Use a slightly lower value so system windows with UIWindowLevelAlert appear above the scanner
  // windows.
  return UIWindowLevelAlert - kGSCXScannerWindowLevelOffset;
}

- (NSArray<UIWindow *> *)windowsToScan {
  // If a results window exists, that means all other windows have already been scanned, so only the
  // most recent results window needs to be scanned. If no results window exists, no windows have
  // been scanned, so all the windows should be returned.
  if ([self gscx_topWindow]) {
    return @[ [self gscx_topWindow] ];
  }
  return [[UIApplication sharedApplication] windows];
}

- (NSUInteger)presentedWindowCount {
  return _resultsWindows.count;
}

#pragma mark - Private

- (nullable UIWindow *)gscx_topWindow {
  return [_resultsWindows lastObject];
}

- (nullable UIWindow *)gscx_popTopWindow {
  UIWindow *topWindow = [self gscx_topWindow];
  if (topWindow) {
    topWindow.hidden = YES;
    [_resultsWindows removeLastObject];
  }
  return topWindow;
}

- (UIWindow *)gscx_findKeyWindow {
  NSArray<__kindof UIWindow *> *windows = [UIApplication sharedApplication].windows;
  for (UIWindow *window in windows) {
    if (window.isKeyWindow) {
      return window;
    }
  }
  NSLog(@"An application must have a key window, but the key window was not found.");
  return nil;
}

- (UIWindow *)gscx_presentResultsWindow {
  _previousKeyWindow = [self gscx_findKeyWindow];
  UIWindow *resultsWindow = [UIWindow gscx_fullScreenWindow];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  // Some view controllers (such as alerts) do not cover the entire screen. In that case, the
  // underlying window must remain visible.
  rootViewController.view.backgroundColor = [UIColor clearColor];
  resultsWindow.rootViewController = rootViewController;
  [resultsWindow gscx_setOverrideUserInterfaceStyleForCurrentApperance];
  resultsWindow.windowLevel = [GSCXScannerWindowCoordinator windowLevel];
  if (_isMultiWindowPresentation) {
    // Decreasing the window level presents the results window behind the overlay window, allowing
    // the user to tap the perform scan button again, presenting another results window.
    resultsWindow.windowLevel--;
  }
  // On iOS 13 (and potentially earlier versions), the scanner menu button is accessible via
  // VoiceOver even though it is completely covered by results windows. Treating the results windows
  // as modal prevents this. However, in multi window presentation mode, the menu button appears
  // over the results window. In this case, it should still be accessible, so
  // accessibilityViewIsModal should be NO.
  resultsWindow.accessibilityViewIsModal = !_isMultiWindowPresentation;
  [resultsWindow makeKeyAndVisible];
  [_resultsWindows addObject:resultsWindow];
  return resultsWindow;
}

/**
 * Updates the user interface style for all overlay windows for the user's current settings. Called
 * when the application enters the foreground.
 */
- (void)gscx_updateUserInterfaceStyleForOverlayWindows {
  for (UIWindow *window in _resultsWindows) {
    [window gscx_setOverrideUserInterfaceStyleForCurrentApperance];
  }
}

@end

NS_ASSUME_NONNULL_END
