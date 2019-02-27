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

#import "GSCXScannerScreenshotViewController.h"

#import "GSCXRingView.h"
#import "GSCXScannerResultTableViewController.h"

@interface GSCXScannerScreenshotViewController ()

/**
 *  A view that adds black bars to the side of the screenshot. The controller's view cannot be made
 *  black because that causes the navigation bar to look different than expected.
 */
@property(weak, nonatomic) IBOutlet UIView *blackBackgroundView;
/**
 *  An array of rings used to highlight UI elements with accessibility issues.
 */
@property(strong, nonatomic) NSArray<GSCXRingView *> *ringViews;

/**
 *  Adds constraints to the given screenshot and adds it to the view hierarchy.
 *
 *  @param screenshot The screenshot to display.
 */
- (void)_addScreenshotToScreen:(UIView *)screenshot;
/**
 *  Adds constraints to the subviews of a screenshot (themselves screenshots of other views).
 *
 *  @param screenshot The screenshot containing other screenshots as subviews.
 */
- (void)_addConstraintsToScreenshotSubviews:(UIView *)screenshot;
/**
 *  Multiplies all components of @c rect by @c factor.
 *
 *  @param rect The CGRect instance to be scaled.
 *  @param factor The factor to multiply each component by.
 *  @return A CGRect instance with all components scaled.
 */
- (CGRect)_scaleRect:(CGRect)rect byFactor:(CGFloat)factor;
/**
 *  Adds ring views to highlight UI elements with accessibility issues in the screenshot.
 *
 *  @param screenshot The screenshot of the view hierarchy that was scanned.
 */
- (void)_addRingsToScreenshot:(UIView *)screenshot;
/**
 *  Returns a GSCXScannerResult instance with only the issues at the given point, after converting
 *  it to the correct coordinate system. @c point should be in @c scanResult.screenshot's
 *  coordinates.
 *
 *  @param point The point UI elements must contain for their issues to be included in the result.
 *  @return A GSCXScannerResult object containing only issues whose frames contain the given point
 *          when converted to screen coordinates.
 */
- (GSCXScannerResult *)_resultWithIssuesAtPoint:(CGPoint)point;
/**
 *  Returns the accessibility label for the ring view at the given index by determining the number
 *  of issues associated with the corresponding UI element and the UI element's accessibility label.
 *
 *  @param index The index of the ring view. Must be less than @c self.scanResult.issues.count.
 *  @return The accessibility label of the ring view at the given index.
 */
- (NSString *)_accessibilityLabelForRingAtIndex:(NSInteger)index;

@end

@implementation GSCXScannerScreenshotViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = [NSString stringWithFormat:@"%ld Issues", (unsigned long)self.scanResult.issueCount];
  [self replaceLeftNavigationItemWithDismissButton];
  [self _addScreenshotToScreen:self.scanResult.screenshot];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self _addRingsToScreenshot:self.scanResult.screenshot];
}

- (IBAction)tapRecognized:(id)sender {
  CGPoint location = [sender locationInView:self.scanResult.screenshot];
  GSCXScannerResult *result = [self _resultWithIssuesAtPoint:location];
  if (result.issueCount == 0) {
    return;
  }
  GSCXScannerResultTableViewController *resultController =
      [[GSCXScannerResultTableViewController alloc]
          initWithNibName:@"GSCXScannerResultTableViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerResultTableViewController class]]];
  resultController.scanResult = result;
  [self.navigationController pushViewController:resultController animated:YES];
}

- (BOOL)isTransparentOverlay {
  return NO;
}

+ (NSString *)accessibilityIdentifierForRingViewAtIndex:(NSInteger)index {
  return [NSString stringWithFormat:@"GSCXScannerScreenshotViewController_Ring_%ld", (long)index];
}

#pragma mark - UINavigationControllerDelegate

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:
    (UINavigationController *)navigationController {
  return 0;
}

#pragma mark - Private

- (void)_addScreenshotToScreen:(UIView *)screenshot {
  screenshot.translatesAutoresizingMaskIntoConstraints = NO;
  screenshot.userInteractionEnabled = NO;
  CGFloat aspectRatio = screenshot.frame.size.width / screenshot.frame.size.height;
  [self.view addSubview:screenshot];
  NSArray<NSLayoutConstraint *> *constraints = @[
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:screenshot
                                 attribute:NSLayoutAttributeHeight
                                multiplier:aspectRatio
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.bottomLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0],
  ];
  [NSLayoutConstraint activateConstraints:constraints];
  [self _addConstraintsToScreenshotSubviews:screenshot];

  [NSLayoutConstraint constraintWithItem:self.blackBackgroundView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:screenshot
                               attribute:NSLayoutAttributeTop
                              multiplier:1.0
                                constant:0.0]
      .active = YES;
}

- (void)_addConstraintsToScreenshotSubviews:(UIView *)screenshot {
  for (UIView *subview in screenshot.subviews) {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{@"view" : subview}]];
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{@"view" : subview}]];
  }
}

- (CGRect)_scaleRect:(CGRect)rect byFactor:(CGFloat)factor {
  return CGRectMake(rect.origin.x * factor, rect.origin.y * factor, rect.size.width * factor,
                    rect.size.height * factor);
}

- (void)_addRingsToScreenshot:(UIView *)screenshot {
  if (self.ringViews.count > 0) {
    return;
  }
  CGFloat scaleFactor = screenshot.frame.size.width / self.view.frame.size.width;
  NSMutableArray *ringViews = [[NSMutableArray alloc] init];
  NSInteger index = 0;
  for (GSCXScannerIssue *issue in self.scanResult.issues) {
    CGRect frame = [self _scaleRect:issue.frame byFactor:scaleFactor];
    GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:frame];
    ringView.accessibilityLabel = [self _accessibilityLabelForRingAtIndex:index];
    ringView.accessibilityIdentifier =
        [GSCXScannerScreenshotViewController accessibilityIdentifierForRingViewAtIndex:index];
    [screenshot addSubview:ringView];
    [ringViews addObject:ringView];
    index++;
  }
  self.ringViews = ringViews;
}

- (GSCXScannerResult *)_resultWithIssuesAtPoint:(CGPoint)point {
  CGFloat factor = self.scanResult.screenshot.frame.size.width / self.view.frame.size.width;
  CGPoint scaledLocation = CGPointMake(point.x / factor, point.y / factor);
  return [self.scanResult resultWithIssuesAtPoint:scaledLocation];
}

- (NSString *)_accessibilityLabelForRingAtIndex:(NSInteger)index {
  NSParameterAssert((NSUInteger)index < self.scanResult.issues.count);
  NSUInteger count = self.scanResult.issues[(NSUInteger)index].gtxCheckNames.count;
  NSString *pluralModifier = (count == 1) ? @"" : @"s";
  NSString *accessibilityLabel = self.scanResult.issues[(NSUInteger)index].accessibilityLabel;
  if (accessibilityLabel == nil) {
    return [NSString stringWithFormat:@"%ld issue%@ for element without accessibility label.",
                                      (unsigned long)count, pluralModifier];
  } else {
    return [NSString stringWithFormat:@"%ld issue%@ for element with accessibility label %@",
                                      (unsigned long)count, pluralModifier, accessibilityLabel];
  }
}

@end
