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

#import "GSCXHitForwardingView.h"
#import "GSCXScanner.h"
#import "UIViewController+GSCXTraversal.h"

/**
 *  The text displayed when an opaque overlay scans itself and finds accessibility issues.
 */
static NSString *const kGSCXWindowOverlaySelfScanFailTitle = @"❌";
NSString *const kGSCXWindowOverlayDismissButtonText = @"Dismiss";

@interface GSCXWindowOverlayViewController ()

/**
 *  Performs a scan on the current window to check for accessibility issues. Calls processScanResult
 *  with the result of the scan. If the overlay is considered transparent, no scan is performed.
 */
- (void)_scanSelf;
/**
 *  Invoked when the navigation bar's left bar button item is tapped. Dismisses the view controller.
 *
 *  @param sender The object initiating the event.
 */
- (void)_leftBarButtonPressed:(nullable id)sender;

@end

@implementation GSCXWindowOverlayViewController

- (void)loadView {
  // If this object has a non-nil nibName (meaning it's being loaded from a xib or storyboard file),
  // it is illegal to provide custom functionality to loadView, so the super implementation is used.
  if ([self isTransparentOverlay] && self.nibName == nil) {
    self.view = [[GSCXHitForwardingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  } else {
    [super loadView];
    NSAssert(
        [self.view isKindOfClass:[GSCXHitForwardingView class]] || ![self isTransparentOverlay],
        @"Views on transparent view controller must be instances of GSCXHitForwardingView.");
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[self windowOverlayPairAncestor] makeKeyWindowTransparentOverlay:[self isTransparentOverlay]];
  if (![self isTransparentOverlay]) {
    [self _scanSelf];
  }
}

- (BOOL)isTransparentOverlay {
  return YES;
}

- (void)_scanSelf {
  GSCXScanner *scanner = [GSCXScanner scannerWithChecks:[GTXChecksCollection allGTXChecks]
                                             blacklists:@[]];
  GSCXScannerResult *result =
      [scanner scanRootViews:@[ self.windowOverlayPairAncestor.overlayWindow ]];
  [self processScanSelfResult:result];
}

- (void)processScanSelfResult:(GSCXScannerResult *)result {
  if (result.issueCount == 0) {
    self.navigationItem.rightBarButtonItem = nil;
    NSLog(@"Zero accessibility issues were found on %@.", self);
  } else {
    UILabel *label = [[UILabel alloc] init];
    label.text = kGSCXWindowOverlaySelfScanFailTitle;
    label.accessibilityLabel = @"Accessibility issues were found on this overlay";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    NSString *scanResultString = [self stringFromScanResult:result];
    NSLog(@"Accessibility issue(s) were found on %@:\n%@", self, scanResultString);
  }
}

- (NSString *)stringFromScanResult:(GSCXScannerResult *)result {
  NSMutableString *string = [[NSMutableString alloc] init];
  for (GSCXScannerIssue *issue in result.issues) {
    [string appendFormat:@"Issues on element with accessibility label '%@' and frame %@:",
     issue.accessibilityLabel, NSStringFromCGRect(issue.frame)];
    for (NSUInteger i = 0; i < issue.gtxCheckNames.count; i++) {
      [string appendFormat:@"\n  %@:%@", issue.gtxCheckNames[i], issue.gtxCheckDescriptions[i]];
    }
  }
  return [NSString stringWithString:string];
}

- (void)replaceLeftNavigationItemWithDismissButton {
  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:kGSCXWindowOverlayDismissButtonText
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(_leftBarButtonPressed:)];
}

- (void)_leftBarButtonPressed:(nullable id)sender {
  [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end
