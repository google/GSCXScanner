//
// Copyright 2019 Google Inc.
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

#import "GSCXDefaultSharingDelegate.h"

#import <UIKit/UIKit.h>

#import "GSCXReport.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GSCXDefaultSharingDelegate

- (void)shareReport:(GSCXReport *)report inViewController:(UIViewController *__weak)viewController {
  __weak __typeof__(self) weakSelf = self;
  [report createPDFReportWithCompletionBlock:^(NSURL *reportUrl) {
    [weakSelf gscx_shareReportAtURL:reportUrl inViewController:viewController];
  }];
}

#pragma mark - Private

- (void)gscx_shareReportAtURL:(NSURL *)url
             inViewController:(UIViewController *__weak)viewController {
  NSArray *activityItems = @[ url ];
  UIActivityViewController *activityController =
      [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                        applicationActivities:nil];
  activityController.popoverPresentationController.barButtonItem =
      viewController.navigationItem.rightBarButtonItem;
  [viewController presentViewController:activityController animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
