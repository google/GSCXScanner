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

#import "GSCXTestPage.h"

/**
 *  Default state of a UI control when no action has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsDefaultControlState;
/**
 *  Accessibility identifier for GSCXUITestViewController's text field.
 */
FOUNDATION_EXTERN NSString *const kUITestsPageTextFieldAccessibilityIdentifier;
/**
 *  Accessibility identifier for GSCXUITestViewController's slider.
 */
FOUNDATION_EXTERN NSString *const kUITestsPageSliderAccessibilityIdentifier;
/**
 *  Accessibility identifier for GSCXUITestViewController's button.
 */
FOUNDATION_EXTERN NSString *const kUITestsPageButtonAccessibilityIdentifier;
/**
 *  The GSCXUITestViewController's button's title after it has been pressed at least once.
 */
FOUNDATION_EXTERN NSString *const kUITestsPageButtonPressedTitle;
/**
 *  Accessibility identifier for GSCXUITestViewController's swipe label.
 */
FOUNDATION_EXTERN NSString *const kUITestsSwipeLabelAccessibilityIdentifier;
/**
 *  GSCXUITestViewController's swipe label's value when a swipe right has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsSwipeLabelRightValue;
/**
 *  GSCXUITestViewController's swipe label's value when a swipe left has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsSwipeLabelLeftValue;
/**
 *  GSCXUITestViewController's swipe label's value when a swipe up has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsSwipeLabelUpValue;
/**
 *  GSCXUITestViewController's swipe label's value when a swipe down has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsSwipeLabelDownValue;
/**
 *  Accessibility identifier for GSCXUITestViewController's pinch label.
 */
FOUNDATION_EXTERN NSString *const kUITestsPinchLabelAccessibilityIdentifier;
/**
 *  GSCXUITestViewController's pinch label's value when a pinch has been detected.
 */
FOUNDATION_EXTERN NSString *const kUITestsPinchLabelPinchedValue;

/**
 *  A view controller containing interactable elements that should remain interactable if the window
 *  forwards hit events.
 */
@interface GSCXUITestViewController : UIViewController <GSCXTestPage>

@property(weak, nonatomic) IBOutlet UITextField *textField;
@property(weak, nonatomic) IBOutlet UISlider *slider;
@property(weak, nonatomic) IBOutlet UIButton *button;
@property(weak, nonatomic) IBOutlet UILabel *swipeLabel;
@property(weak, nonatomic) IBOutlet UILabel *pinchLabel;

@end
