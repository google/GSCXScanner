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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Treats a collection view as an accessibility element so users of assistive technologies don't
 * have to navigate through every item to pass the collection view. The collection view is
 * considered "adjustable", so users can use accessibility actions to change which item in the
 * collection view is selected. Exactly one cell must be selected at all times. It is the owner's
 * responsibility to select the initial element.
 */
@interface GSCXScannerResultCarouselView : UICollectionView

@end

NS_ASSUME_NONNULL_END
