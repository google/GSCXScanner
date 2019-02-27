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

#import "GSCXScanner.h"
#import "GSCXScannerResult.h"
#import "GSCXWindowOverlayPair.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The text of the bar button item that dismisses the screenshot controller and returns to the
 *  main application.
 */
FOUNDATION_EXTERN NSString *const kGSCXWindowOverlayDismissButtonText;

/**
 *  Represents view controllers that are presented in the scanner's overlay window. Subclasses can
 *  mark themselves as transparent or opaque to control how events and inputs propagate to the
 *  original application window. If a subclass is loaded from a nib, the nib's view is required
 *  to be an instance of GSCXHitForwardingView.
 *
 *  Because the results overlays remove the scan overlay from the screen, there is no way to
 *  manually trigger a scan on overlay view controllers (except for the scan overlay, which scans
 *  itself). Instead, all opaque overlays automatically scan themselves in viewDidAppear, passing
 *  the result to processScanSelfResult:. Classes can override this method to hook into the result
 *  of the scan. The default functionality is to add a visual indicator to the navigation bar and
 *  log the issues to the console.
 */
@interface GSCXWindowOverlayViewController : UIViewController

/**
 *  The overlay and original app window. If this instance is the root view
 *  controller of a window, it is the window’s (or its owner’s) responsibility
 *  to set this value. If this value is nil, then it traverses backwards through
 *  the view controller hierarchy until a GSCXWindowOverlayViewController is found
 *  which has a non-nil value for windowOverlayPair.
 */
@property(strong, nonatomic, nullable) GSCXWindowOverlayPair *windowOverlayPair;
/**
 *  If this view controller has a partially transparent background, returns YES.
 *  If this view controller has a completely opaque background, returns NO.
 *  Defaults to YES. If YES, then loadView sets the view property to an instance of
 *  GSCXHitForwardingView.
 */
- (BOOL)isTransparentOverlay;
/**
 *  Called when this object has finished scanning itself. Subclasses can override this to perform
 *  custom functionality. Default functionality is to set the right navigation item to a success
 *  or failure indicator and log to the console.
 *
 *  @param result The result of scanning the overlay window.
 */
- (void)processScanSelfResult:(GSCXScannerResult *)result;
/**
 *  Constructs a string from a scan result.
 *
 *  @param result A GSCXScannerResult object.
 *  @return The string representation of the result object.
 */
- (NSString *)stringFromScanResult:(GSCXScannerResult *)result;
/**
 *  Sets the left navigation item to a button that dismisses this view controller. Replaces the
 *  current left navigation item if it already exists.
 */
- (void)replaceLeftNavigationItemWithDismissButton;

@end

NS_ASSUME_NONNULL_END
