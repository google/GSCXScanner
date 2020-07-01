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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * GSCXResultsWindowCoordinating is an abstraction around presenting and dismissing the results
 * window. The scanner UI can present view controllers that completely obscure the application UI
 * without modifying the behavior of hitTest:withEvent:, which is fragile. The results window can
 * be dismissed to pass control back to the application. It is the responsibility of the presenting
 * view controller or the presented view controller to dismiss the results window. The
 * GSCXResultsWindowCoordinating instance cannot dismiss it automatically.
 */
@protocol GSCXResultsWindowCoordinating <NSObject>

/**
 * Makes the results window visible and key and presents @c viewController on the
 * result window’s root view controller.
 */
- (void)presentViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(nullable void (^)(void))completionBlock;

/**
 * Dismisses the view controller presented in the results window, then hides the results window and
 * makes the previous window key.
 */
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(nullable void (^)(void))completion;

/**
 * Removes the results window from the screen.
 */
- (void)dismissResultsWindow;

/**
 * @return An array of windows to scan for accessibility issues. Contains all windows in the app
 * except for windows which have already been scanned and presented in a results window. Windows
 * which have already been scanned cannot be returned again, because otherwise they would be scanned
 * again, even if they are behind the current results window. This causes duplicate issues that
 * don't clearly correspond to on screen elements.
 */
- (NSArray<UIWindow *> *)windowsToScan;

/**
 * @return The number of windows currently presented by this coordinator.
 */
- (NSUInteger)presentedWindowCount;

@end

NS_ASSUME_NONNULL_END
