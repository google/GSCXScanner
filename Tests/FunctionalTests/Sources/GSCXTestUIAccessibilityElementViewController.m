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

#import "GSCXTestUIAccessibilityElementViewController.h"

#import "GSCXTestAppDelegate.h"

/**
 *  A UIAccessibilityElement containing a unique integer identifying it.
 */
@interface GSCXTestUIAccessibilityElement : UIAccessibilityElement

/**
 *  A unique integer identifying this object.
 */
@property(assign, nonatomic) NSInteger tag;

@end

@implementation GSCXTestUIAccessibilityElement
@end

@interface GSCXTestUIAccessibilityElementViewController ()

/**
 *  An accessibility element with the same frame as @c visualIndicator.
 */
@property(strong, nonatomic) GSCXTestUIAccessibilityElement *accessibilityElement;
/**
 *  An accessibility container with the same frame as @c container.
 */
@property(strong, nonatomic) GSCXTestUIAccessibilityElement *accessibilityContainer;
/**
 *  An accessibility element with the same frame as @c subVisualIndicator.
 */
@property(strong, nonatomic) GSCXTestUIAccessibilityElement *subAccessibilityElement;

@end

@implementation GSCXTestUIAccessibilityElementViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  GSCXTestUIAccessibilityElement *element =
      [[GSCXTestUIAccessibilityElement alloc] initWithAccessibilityContainer:self.view];
  GSCXTestUIAccessibilityElement *container =
      [[GSCXTestUIAccessibilityElement alloc] initWithAccessibilityContainer:self.view];
  GSCXTestUIAccessibilityElement *subElement =
      [[GSCXTestUIAccessibilityElement alloc] initWithAccessibilityContainer:container];
  element.tag = kGSCXTestTagCheckTag2;
  subElement.tag = kGSCXTestTagCheckTag3;
  container.isAccessibilityElement = NO;
  container.accessibilityElements = @[ subElement ];
  self.view.accessibilityElements = @[ element, container ];
  self.accessibilityElement = element;
  self.accessibilityContainer = container;
  self.subAccessibilityElement = subElement;
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.accessibilityElement.accessibilityFrame = self.visualIndicator.accessibilityFrame;
  self.accessibilityContainer.accessibilityFrame = self.container.accessibilityFrame;
  self.subAccessibilityElement.accessibilityFrame = self.subVisualIndicator.accessibilityFrame;
}

#pragma mark - GSCXTestPage

+ (NSString *)pageName {
  return @"UIAccessibilityElement";
}

@end
