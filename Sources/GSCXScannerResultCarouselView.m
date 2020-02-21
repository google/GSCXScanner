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

#import "GSCXScannerResultCarouselView.h"

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@implementation GSCXScannerResultCarouselView

- (UIAccessibilityTraits)accessibilityTraits {
  return UIAccessibilityTraitAdjustable;
}

- (void)accessibilityIncrement {
  GTX_ASSERT(self.indexPathsForSelectedItems.count == 1,
             @"GSCXScannerResultCarouselView must have a single selected element.");
  NSInteger currentSection = self.indexPathsForSelectedItems[0].section;
  NSInteger currentIndex = self.indexPathsForSelectedItems[0].item;
  if (currentIndex + 1 >= [self.dataSource collectionView:self
                                   numberOfItemsInSection:currentSection]) {
    return;
  }
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex + 1
                                                  inSection:currentSection];
  [self selectItemAtIndexPath:newIndexPath
                     animated:YES
               scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
  [self.delegate collectionView:self didSelectItemAtIndexPath:newIndexPath];
}

- (void)accessibilityDecrement {
  GTX_ASSERT(self.indexPathsForSelectedItems.count == 1,
             @"GSCXScannerResultCarouselView must have a single selected element.");
  NSInteger currentSection = self.indexPathsForSelectedItems[0].section;
  NSInteger currentIndex = self.indexPathsForSelectedItems[0].item;
  if (currentIndex == 0) {
    return;
  }
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex - 1
                                                  inSection:currentSection];
  [self selectItemAtIndexPath:newIndexPath
                     animated:YES
               scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
  [self.delegate collectionView:self didSelectItemAtIndexPath:newIndexPath];
}

// These must be overwritten to prevent VoiceOver from traversing the collection view cells.
// Otherwise, the collection view is treated as a container, not an adjustable element.
- (NSInteger)accessibilityElementCount {
  return 0;
}

- (nullable NSArray *)accessibilityElements {
  return nil;
}

@end

NS_ASSUME_NONNULL_END
