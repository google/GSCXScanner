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

NS_ASSUME_NONNULL_BEGIN

/**
 * The name of the "accessibility label missing" check.
 */
static NSString *const kGSCXTestAccessibilityLabelCheckName = @"Accessibility label missing";

/**
 * The description of the "accessibility label missing" check.
 */
static NSString *const kGSCXTestAccessibilityLabelCheckDescription =
    @"This element doesn't have an accessibility label.";

/**
 * The name of the "small touch target" check.
 */
static NSString *const kGSCXTestTouchTargetSizeCheckName = @"Touch target size";

/**
 * The description of the "small touch target" check.
 */
static NSString *const kGSCXTestTouchTargetSizeCheckDescription =
    @"This element has a small touch target.";

/**
 * The name of the "insufficient contrast ratio" check.
 */
static NSString *const kGSCXTestContrastRatioCheckName = @"Insufficient contrast ratio";

/**
 * The description of the "insufficient contrast ratio" check.
 */
static NSString *const kGSCXTestContrastRatioCheckDescription =
    @"This element has an insufficient contrast ratio.";

NS_ASSUME_NONNULL_END
