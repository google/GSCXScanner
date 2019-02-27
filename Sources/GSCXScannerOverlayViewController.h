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

#import "GSCXWindowOverlayViewController.h"

#import <UIKit/UIKit.h>

#import "GSCXScanner.h"
#import "GSCXWindowOverlayPair.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The text of the button dismissing the alert shown when a scan finds no accessibility issues.
 */
FOUNDATION_EXTERN NSString *const kGSCXNoIssuesDismissButtonText;
/**
 *  The accessibility identifier of the button that performs a scan.
 */
FOUNDATION_EXTERN NSString *const kGSCXPerformScanAccessibilityIdentifier;

/**
 *  Contains the UI for manually triggering a scan on an application.
 */
@interface GSCXScannerOverlayViewController : GSCXWindowOverlayViewController

/**
 *  The scanner used to check the application for issues. It is the responsibility of this object's
 *  owner to set this before it is used.
 */
@property(strong, nonatomic, nullable) GSCXScanner *scanner;
/**
 *  Displays the number of accessibility issues discovered by the last scan.
 *  Tapping on this button displays the table view of all accessibility issues.
 */
@property(weak, nonatomic, nullable) IBOutlet UIButton *performScanButton;

- (instancetype)initWithNibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)bundle NS_UNAVAILABLE;
/**
 *  Initializes this object by loading from a xib file from a given bundle. The user provides
 *  whether accessibility is enabled or not.
 *
 *  @param nibName The name of the xib file to load from (without the ".xib" extension).
 *  @param bundle The bundle the xib file is located in, or nil if it's in the main bundle.
 *  @param accessibilityEnabled YES if accessibility is enabled, NO otherwise.
 *  @return An initialized GSCXScannerOverlayViewController object.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)bundle
           accessibilityEnabled:(BOOL)accessibilityEnabled NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
