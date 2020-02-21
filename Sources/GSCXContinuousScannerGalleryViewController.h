//
// Copyright 2020 Google Inc.
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

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier for the detail scroll view in the gallery view.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier;

/**
 * Displays detailed information about accessibility issues in a single screen found during a scan.
 * Provides a screenshot that is automatically focused so users can focus on individual elements
 * containing accessibility issues.
 */
@interface GSCXContinuousScannerGalleryViewController : UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * Initializes this object by loading from a xib file from a given bundle. The user provides the
 * scan result to display.
 *
 * @param nibName The name of the xib file to load from (without the ".xib" extension).
 * @param bundle The bundle the xib file is located in, or nil if it's in the main bundle.
 * @param result The @c GSCXScannerResult object to display.
 * @return An initialized @c GSCXContinuousScannerGalleryViewController object.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         result:(GSCXScannerResult *)result;

/**
 * Focuses the screenshot and detail views on the accessibility issue at the given index.
 *
 * @param index The index of the accessibility issue on which to focus.
 * @param animated @c YES if the transition should be animated, @c NO if it should occur
 * immediately.
 */
- (void)focusIssueAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
