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

#import "GSCXRingView.h"
#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Presents a screenshot of a scanned view hiearchy. Overlays rings over elements with
 *  accessibility issues so users can see which elements have issues. Users can tap on issues to see
 *  a detail view containing issue name, description, and resolution. This view controller is
 *  considered opaque.
 */
@interface GSCXScannerScreenshotViewController
    : GSCXWindowOverlayViewController <UINavigationControllerDelegate>

/**
 *  The result of scanning a view hierarchy. It is the responsibility of the owner of this view
 *  controller to set this property before viewDidLoad is called.
 */
@property(strong, nonatomic) GSCXScannerResult *scanResult;

/**
 *  Returns the accessibility identifier of the ring view at the given index.
 *
 *  @param index The index of the ring view.
 *  @return A string representing the accessibility identifier of the corresponding ring view.
 */
+ (NSString *)accessibilityIdentifierForRingViewAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
