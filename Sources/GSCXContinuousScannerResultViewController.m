//
// Copyright 2019 Google LLC.
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

#import "GSCXContinuousScannerResultViewController.h"

#import <WebKit/WebKit.h>

#import "GSCXDefaultSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kGSCXContinuousScannerResultShareBarButtonTitle = @"Share";

/**
 * The title of the alert presented when the PDF could not be loaded.
 */
static NSString *const kGSCXContinuousScannerFailedToLoadReportAlertTitle = @"Error";

/**
 * The text of the alert presented when the PDF could not be loaded.
 */
static NSString *const kGSCXContinuousScannerFailedToLoadReportAlertText =
    @"Could not load report.";

/**
 * The title of the dismiss button for the alert presented when the PDF could not be loaded.
 */
static NSString *const kGSCXContinuousScannerFailedToLoadReportAlertDismissTitle = @"Ok";

@interface GSCXContinuousScannerResultViewController ()

/**
 * Report to be displayed.
 */
@property(strong, nonatomic) GSCXReport *report;

/**
 * Contains the web view rendering the report so it does not lie underneath the navigation bar.
 */
@property(weak, nonatomic) IBOutlet UIView *webContainerView;

/**
 * Renders the report.
 */
@property(strong, nonatomic) WKWebView *webView;

/**
 * Shares the report.
 */
@property(strong, nonatomic) id<GSCXSharingDelegate> sharingDelegate;

@end

@implementation GSCXContinuousScannerResultViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil
                         report:(GSCXReport *)report
                sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _report = report;
    _sharingDelegate = sharingDelegate;
    __weak __typeof__(self) weakSelf = self;
    [_report createHTMLReportWithCompletionBlock:^(WKWebView *webView) {
      [weakSelf gscx_setupWebView:webView];
    }];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:kGSCXContinuousScannerResultShareBarButtonTitle
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(gscx_beginSharingReport)];
}

#pragma mark - UINavigationControllerDelegate

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:
    (UINavigationController *)navigationController {
  return 0;
}

#pragma mark - Private

- (void)gscx_setupWebView:(WKWebView *)webView {
  self.webView = webView;
  [self.webContainerView addSubview:self.webView];
  self.webView.translatesAutoresizingMaskIntoConstraints = NO;
  NSDictionary<NSString *, id> *views = @{@"webView" : self.webView};
  NSArray<NSLayoutConstraint *> *horizontalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[webView]-0-|"
                                              options:0
                                              metrics:nil
                                                views:views];
  NSArray<NSLayoutConstraint *> *verticalConstraints =
      [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                              options:0
                                              metrics:nil
                                                views:views];
  NSArray<NSLayoutConstraint *> *constraints =
      [horizontalConstraints arrayByAddingObjectsFromArray:verticalConstraints];
  [NSLayoutConstraint activateConstraints:constraints];
}

/**
 * Uses @c sharingDelegate to begin sharing the report.
 */
- (void)gscx_beginSharingReport {
  [self.sharingDelegate shareReport:self.report inViewController:self];
}

/**
 * Presents an alert saying the PDF could not be loaded. Invokes @c failureToLoadCallback when the
 * alert is dismissed.
 */
- (void)gscx_presentFailedToLoadPDFAlert {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXContinuousScannerFailedToLoadReportAlertTitle
                                          message:kGSCXContinuousScannerFailedToLoadReportAlertText
                                   preferredStyle:UIAlertControllerStyleAlert];
  __weak __typeof__(self) weakSelf = self;
  UIAlertAction *dismissAction =
      [UIAlertAction actionWithTitle:kGSCXContinuousScannerFailedToLoadReportAlertDismissTitle
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                               weakSelf.failureCallback();
                             }];
  [alert addAction:dismissAction];
  [self presentViewController:alert animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
