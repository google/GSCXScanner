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

#import "GSCXRingView.h"
#import "GSCXScannerResult.h"
#import "GSCXSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the share report button.
 */
FOUNDATION_EXTERN NSString *const kGSCXShareReportButtonAccessibilityIdentifier;

/**
 * Presents a screenshot of a scanned view hiearchy. Overlays rings over elements with
 * accessibility issues so users can see which elements have issues. Users can tap on issues to see
 * a detail view containing issue name, description, and resolution. This view controller is
 * considered opaque.
 */
@interface GSCXScannerScreenshotViewController : UIViewController

/**
 * The result of scanning a view hierarchy. It is the responsibility of the owner of this view
 * controller to set this property before viewDidLoad is called.
 */
@property(strong, nonatomic) GSCXScannerResult *scanResult;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * Initializes this object by loading from a xib file from a given bundle. The user provides
 * whether accessibility is enabled or not.
 *
 * @param nibName The name of the xib file to load from (without the ".xib" extension).
 * @param bundle The bundle the xib file is located in, or nil if it's in the main bundle.
 * @param scanResult The result of a scan.
 * @param sharingDelegate Controls how the report of the results is shared.
 * @return An initialized @c GSCXContinuousScannerResultViewController object.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                     scanResult:(GSCXScannerResult *)scanResult
                sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate;

@end

NS_ASSUME_NONNULL_END
