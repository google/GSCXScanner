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

#import "GSCXTestPage.h"

/**
 *  The accessibility identifier of GSCXTestViewController's tableView property.
 */
FOUNDATION_EXTERN NSString *const kMainTableViewAccessibilityId;

/**
 *  A view controller exposing access to other view controllers in the app.
 */
@interface GSCXTestViewController
    : UIViewController <UITableViewDelegate, UITableViewDataSource, GSCXTestPage>

/**
 *  The table view containing all view controllers that can be accessed.
 */
@property(weak, nonatomic) IBOutlet UITableView *tableView;

/**
 *  Returns the accessibilityIdentifier of the cell corresponding to the given
 *  page.
 *
 *  @param pageClass The class of the page's view controller.
 *  @return The accessibility identifier of the cell that opens the given page.
 */
+ (NSString *)accessibilityIdentifierOfCellForPage:(Class<GSCXTestPage>)pageClass;

@end
