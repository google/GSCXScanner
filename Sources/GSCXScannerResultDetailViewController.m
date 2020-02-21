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

#import "GSCXScannerResultDetailViewController.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXDetailCheckNameAccessibilityIdentifier =
    @"kGSCXDetailCheckNameAccessibilityIdentifier";
NSString *const kGSCXDetailCheckDescriptionAccessibilityIdentifier =
    @"kGSCXDetailCheckDescriptionAccessibilityIdentifier";

@interface GSCXScannerResultDetailViewController ()
@end

@implementation GSCXScannerResultDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  GTX_ASSERT(self.scanResult != nil, @"scanResult cannot be nil in viewDidLoad.");
  self.checkName.text = [self.scanResult gtxCheckNameAtIndex:self.issueIndex];
  self.checkDescription.text = [self.scanResult gtxCheckDescriptionAtIndex:self.issueIndex];
  self.checkName.accessibilityIdentifier = kGSCXDetailCheckNameAccessibilityIdentifier;
  self.checkDescription.accessibilityIdentifier =
      kGSCXDetailCheckDescriptionAccessibilityIdentifier;
}

- (void)setScanResult:(GSCXScannerResult *)scanResult issueIndex:(NSUInteger)issueIndex {
  _scanResult = scanResult;
  _issueIndex = issueIndex;
  self.checkName.text = [self.scanResult gtxCheckNameAtIndex:self.issueIndex];
  self.checkDescription.text = [self.scanResult gtxCheckDescriptionAtIndex:self.issueIndex];
}

@end

NS_ASSUME_NONNULL_END
