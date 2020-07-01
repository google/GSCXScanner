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

@interface GSCXTestSharingDelegate ()

/**
 * @c YES if a share action is in progress, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isSharing) BOOL sharing;

/**
 * Invoked when the share action finishes.
 */
@property(copy, nonatomic, nullable) GSCXSharingDelegateCompletionBlock completionBlock;

@end

@implementation GSCXTestSharingDelegate

- (BOOL)shareReport:(GSCXReport *)report
    inViewController:(UIViewController *__weak)viewController
          completion:(nullable GSCXSharingDelegateCompletionBlock)completionBlock {
  if (self.sharing) {
    return NO;
  }
  self.sharing = YES;
  self.completionBlock = completionBlock;
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXTestSharingDelegateAlertTitle
                                          message:kGSCXTestSharingDelegateAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  __weak __typeof__(self) weakSelf = self;
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXTestSharingDelegateAlertDismissTitle
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            [weakSelf gscx_onSharingComplete];
                                          }]];
  [viewController presentViewController:alert animated:YES completion:nil];
  return YES;
}

#pragma mark - Private

/**
 * Invoked when the alert is dismissed. Invokes the completion block, if it exists.
 */
- (void)gscx_onSharingComplete {
  self.sharing = NO;
  if (self.completionBlock != nil) {
    self.completionBlock();
    self.completionBlock = nil;
  }
}

@end

NS_ASSUME_NONNULL_END
