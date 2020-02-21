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

#import <UIKit/UIKit.h>

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerResultTableViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate>

/**
 * The result of a scan. It is the responsibility of this object's owner to set scanResult before
 * this view controller appears.
 */
@property(strong, nonatomic) GSCXScannerResult *scanResult;

/**
 * The table view displaying all individual issues found in a scan.
 */
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
