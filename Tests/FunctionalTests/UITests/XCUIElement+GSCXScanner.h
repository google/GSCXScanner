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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface XCUIElement (GSCXScanner)

/**
 * Determines if the element is visible, where visible is defined as the element's frame
 * intersects with the screen.
 *
 * @param screenBounds The screen's bounds.
 */
- (BOOL)gscx_isVisible:(CGRect)screenBounds;

/**
 * Determines if the element is visible, using the main application window's frame as a proxy for
 * the screen's frame.
 *
 * @param app The XCUIApplication object corresponding to the test host.
 */
- (BOOL)gscx_isVisibleWithProxyFrameFromApp:(XCUIApplication *)app;

@end
