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

#import <Foundation/Foundation.h>

/**
 * The name of the environment variable determining whether the overlay window forwards or does not
 * forward hits.
 */
FOUNDATION_EXTERN NSString *const kEnvWindowOverlayTypeKey;

/**
 * The value of the overlay type environment variable configuring the overlay window to forward
 * hits.
 */
FOUNDATION_EXTERN NSString *const kEnvWindowOverlayTypeTransparent;

/**
 * The value of the overlay type environment variable configuring the overlay window to not forward
 * hits. The app starts on the GSCXUITestsViewController page instead of the table view page
 * because there's no other way to navigate to the UI tests page manually with an opaque window.
 */
FOUNDATION_EXTERN NSString *const kEnvWindowOverlayTypeOpaque;

/**
 * The name of the environment variable determining whether multiple results windows can be
 * displayed.
 */
FOUNDATION_EXTERN NSString *const kEnvResultsWindowPresentationTypeKey;

/**
 * The value of the results window presentation type environment variable allowing only a single
 * results window.
 */
FOUNDATION_EXTERN NSString *const kEnvResultsWindowPresentationTypeSingle;

/**
 * The value of the results window presentation type environment variable allowing multiple results
 * windows.
 */
FOUNDATION_EXTERN NSString *const kEnvResultsWindowPresentationTypeMultiple;

/**
 * The name of the environment variable determining how frequently continuous scans should be
 * scheduled
 */
FOUNDATION_EXTERN NSString *const kEnvContinuousScannerTimeIntervalKey;

/**
 * The name of the environment variable determining if the default sharing delegate is used or if a
 * dummy sharing delegate is used.
 */
FOUNDATION_EXTERN NSString *const kEnvUseTestSharingDelegateKey;

/**
 * The name of the environmnet variable determining if the canonical GTXiLib checks are used or if
 * only the test checks are used. If the value is this environment variable is @c @"YES", the test
 * checks and the GTXiLib checks are used. If @c @"NO", or if it does not exist, only the test
 * checks are used.
 */
FOUNDATION_EXTERN NSString *const kEnvUseCanonicalGTXChecksKey;
