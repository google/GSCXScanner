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

#import "GSCXUITestViewController.h"

NSString *const kUITestsDefaultControlState = @"None";
NSString *const kUITestsPageTextFieldAccessibilityIdentifier =
    @"kUITestsPageTextFieldAccessibilityIdentifier";
NSString *const kUITestsPageSliderAccessibilityIdentifier =
    @"kUITestsPageSliderAccessibilityIdentifier";
NSString *const kUITestsPageButtonAccessibilityIdentifier =
    @"kUITestsPageButtonAccessibilityIdentifier";
NSString *const kUITestsPageButtonPressedTitle = @"Pressed";
NSString *const kUITestsSwipeLabelAccessibilityIdentifier =
    @"kUITestsSwipeLabelAccessibilityIdentifier";
NSString *const kUITestsSwipeLabelRightValue = @"Right Swipe";
NSString *const kUITestsSwipeLabelLeftValue = @"Left Swipe";
NSString *const kUITestsSwipeLabelUpValue = @"Up Swipe";
NSString *const kUITestsSwipeLabelDownValue = @"Down Swipe";
NSString *const kUITestsPinchLabelAccessibilityIdentifier =
    @"kUITestsPinchLabelAccessibilityIdentifier";
NSString *const kUITestsPinchLabelPinchedValue = @"Pinched";

@interface GSCXUITestViewController ()

@end

@implementation GSCXUITestViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = [GSCXUITestViewController pageName];
  self.textField.accessibilityIdentifier = kUITestsPageTextFieldAccessibilityIdentifier;
  self.slider.accessibilityIdentifier = kUITestsPageSliderAccessibilityIdentifier;
  self.button.accessibilityIdentifier = kUITestsPageButtonAccessibilityIdentifier;
  [self.button setTitle:kUITestsDefaultControlState forState:UIControlStateNormal];
  self.swipeLabel.accessibilityIdentifier = kUITestsSwipeLabelAccessibilityIdentifier;
  self.swipeLabel.text = kUITestsDefaultControlState;
  self.pinchLabel.accessibilityIdentifier = kUITestsPinchLabelAccessibilityIdentifier;
  self.pinchLabel.text = kUITestsDefaultControlState;

  [self.view addGestureRecognizer:[[UIPinchGestureRecognizer alloc]
                                      initWithTarget:self
                                              action:@selector(pinchRecognized:)]];
}

#pragma mark - GSCXTestPage

+ (NSString *)pageName {
  return @"UI Tests";
}

- (IBAction)buttonPressed:(UIButton *)sender {
  [self.button setTitle:kUITestsPageButtonPressedTitle forState:UIControlStateNormal];
}

- (IBAction)tapRecognized:(UITapGestureRecognizer *)sender {
  self.swipeLabel.text = kUITestsDefaultControlState;
}

- (IBAction)swipeRecognized:(UISwipeGestureRecognizer *)sender {
  switch ([sender direction]) {
    case UISwipeGestureRecognizerDirectionRight:
      self.swipeLabel.text = kUITestsSwipeLabelRightValue;
      break;
    case UISwipeGestureRecognizerDirectionLeft:
      self.swipeLabel.text = kUITestsSwipeLabelLeftValue;
      break;
    case UISwipeGestureRecognizerDirectionUp:
      self.swipeLabel.text = kUITestsSwipeLabelUpValue;
      break;
    case UISwipeGestureRecognizerDirectionDown:
      self.swipeLabel.text = kUITestsSwipeLabelDownValue;
      break;
  }
}

- (IBAction)pinchRecognized:(id)sender {
  self.pinchLabel.text = kUITestsPinchLabelPinchedValue;
}

@end
