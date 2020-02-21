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

#import "GSCXTestSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The title of the alert presented when sharing a report.
 */
static NSString *const kGSCXTestSharingDelegateAlertTitle = @"Sharing";

/**
 * The message of the alert presented when sharing a report.
 */
static NSString *const kGSCXTestSharingDelegateAlertMessage =
    @"You pressed the \"Share\" button. In development, this presents a share sheet to export the "
    @"scan report. In the test suite, this presents an alert to mitigate timeout issues related to "
    @"the system share sheet.";

NSString *const kGSCXTestSharingDelegateAlertDismissTitle = @"Dismiss Sharing";

@implementation GSCXTestSharingDelegate

- (void)shareReport:(GSCXReport *)report inViewController:(UIViewController *__weak)viewController {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXTestSharingDelegateAlertTitle
                                          message:kGSCXTestSharingDelegateAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXTestSharingDelegateAlertDismissTitle
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *_Nonnull action){
                                              // The alert will be automatically dismissed, so no
                                              // action needs to be taken.
                                          }]];
  [viewController presentViewController:alert animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
