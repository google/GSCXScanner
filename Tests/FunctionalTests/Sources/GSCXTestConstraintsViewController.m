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

#import "GSCXTestConstraintsViewController.h"

#import "NSLayoutConstraint+GSCXUtilities.h"

NSString *const kGSCXTestConstraintsMainViewAccessibilityIdentifier =
    @"kGSCXTestConstraintsMainViewAccessibilityIdentifier";

NSString *const kGSCXTestConstraintsEntirelyCoveringViewAccessibilityIdentifier =
    @"kGSCXTestConstraintsEntirelyCoveringViewAccessibilityIdentifier";

NSString *const kGSCXTestConstraintsCenteredViewAccessibilityIdentifier =
    @"kGSCXTestConstraintsCenteredViewAccessibilityIdentifier";

NSString *const kGSCXTestConstraintsAspectRatioViewAccessibilityIdentifier =
    @"kGSCXTestConstraintsAspectRatioViewAccessibilityIdentifier";

/**
 * Margin on the sides of elements in @c GSCXTestConstraintsViewController.
 */
static const CGFloat kGSCXTestConstraintsMargin = 10.0;

/**
 * Padding on the sides of elements in @c GSCXTestConstraintsViewController.
 */
static const CGFloat kGSCXTestConstraintsPadding = 20.0;

/**
 * The width of @c GSCXTestConstraintsViewController.mainView.
 */
static const CGFloat kGSCXTestConstraintsMainViewWidth = 100.0;

/**
 * The height of @c GSCXTestConstraintsViewController.mainView.
 */
static const CGFloat kGSCXTestConstraintsMainViewHeight = 300.0;

@implementation GSCXTestConstraintsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.mainView =
      [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kGSCXTestConstraintsMainViewWidth,
                                               kGSCXTestConstraintsMainViewHeight)];
  self.entirelyCoveringView = [[UIView alloc] initWithFrame:CGRectZero];
  self.centeredView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
  self.aspectRatioView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1000.0, 500.0)];
  NSDictionary<NSString *, id> *views = @{
    @"mainView" : self.mainView,
    @"entirelyCoveringView" : self.entirelyCoveringView,
    @"centeredView" : self.centeredView,
    @"aspectRatioView" : self.aspectRatioView
  };
  NSDictionary<NSString *, id> *metrics = @{
    @"margin" : @(kGSCXTestConstraintsMargin),
    @"padding" : @(kGSCXTestConstraintsPadding),
    @"mainViewWidth" : @(kGSCXTestConstraintsMainViewWidth),
    @"mainViewHeight" : @(kGSCXTestConstraintsMainViewHeight)
  };

  self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
  self.mainView.backgroundColor = [UIColor grayColor];
  self.mainView.accessibilityIdentifier = kGSCXTestConstraintsMainViewAccessibilityIdentifier;
  [self.view addSubview:self.mainView];
  [NSLayoutConstraint
      gscx_constraintsWithHorizontalFormat:@"|-(margin)-[mainView(==mainViewWidth)]"
                            verticalFormat:@"|-(margin)-[mainView(==mainViewHeight)]"
                                   options:0
                                   metrics:metrics
                                     views:views
                                 activated:YES];

  self.entirelyCoveringView.backgroundColor = [self gscxtest_entirelyCoveringViewColor];
  self.entirelyCoveringView.translatesAutoresizingMaskIntoConstraints = NO;
  self.entirelyCoveringView.accessibilityIdentifier =
      kGSCXTestConstraintsEntirelyCoveringViewAccessibilityIdentifier;
  self.entirelyCoveringView.isAccessibilityElement = YES;
  self.entirelyCoveringView.accessibilityLabel = @"covers entire superview";
  [self.mainView addSubview:self.entirelyCoveringView];
  [NSLayoutConstraint gscx_constraintsToFillSuperviewWithView:self.entirelyCoveringView
                                                    activated:YES];

  self.centeredView.backgroundColor = self.view.backgroundColor;
  self.centeredView.translatesAutoresizingMaskIntoConstraints = NO;
  self.centeredView.accessibilityIdentifier =
      kGSCXTestConstraintsCenteredViewAccessibilityIdentifier;
  self.centeredView.isAccessibilityElement = YES;
  self.centeredView.accessibilityLabel = @"centered on sibling view";
  [self.view addSubview:self.centeredView];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.centeredView
                                           withView:self.mainView
                                       horizontally:YES
                                         vertically:YES
                                          activated:YES];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"|-(padding)-[centeredView]"
                                            verticalFormat:@"|-(padding)-[centeredView]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];

  self.aspectRatioView.translatesAutoresizingMaskIntoConstraints = NO;
  self.aspectRatioView.backgroundColor = [self gscxtest_aspectRatioViewColor];
  self.aspectRatioView.accessibilityIdentifier =
      kGSCXTestConstraintsAspectRatioViewAccessibilityIdentifier;
  self.aspectRatioView.isAccessibilityElement = YES;
  self.aspectRatioView.accessibilityLabel = @"constant aspect ratio";
  [self.view addSubview:self.aspectRatioView];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"|[aspectRatioView]"
                                            verticalFormat:@"[mainView]-0-[aspectRatioView]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.aspectRatioView
                                           withView:self.mainView
                                       horizontally:YES
                                         vertically:NO
                                          activated:YES];
  [NSLayoutConstraint gscx_constraintToCurrentAspectRatioWithView:self.aspectRatioView
                                                        activated:YES];
}

+ (NSString *)pageName {
  return @"Constraints";
}

#pragma mark - Private

- (UIColor *)gscxtest_entirelyCoveringViewColor {
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      return [UIColor redColor];
    }
  }
  return [UIColor colorWithRed:238.0 / 255.0 green:0.0 blue:0.0 alpha:1.0];
}

- (UIColor *)gscxtest_aspectRatioViewColor {
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      return [UIColor whiteColor];
    }
  }
  return [UIColor blackColor];
}

@end
