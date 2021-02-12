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

#import <Foundation/Foundation.h>

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@class GSCXScanner;

/**
 * Allows objects to hook into a scan's lifecycle and perform custom functionality.
 */
@protocol GSCXScannerDelegate <NSObject>

@optional

/**
 * Called before the scanner begins a scan.
 *
 * @param scanner The scanner object about to perform the scan.
 */
- (void)scannerWillBeginScan:(GSCXScanner *)scanner;

/**
 * Called after the scanner finishes a scan.
 *
 * @param scanner The scanner object that just completed the scan.
 * @param scanResult The result of the scan. The same as [scanner lastScanResult].
 */
- (void)scanner:(GSCXScanner *)scanner
    didFinishScanWithResult:(GTXHierarchyResultCollection *)scanResult;

@end

NS_ASSUME_NONNULL_END
