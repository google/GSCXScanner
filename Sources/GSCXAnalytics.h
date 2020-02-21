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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum of all possible analytics events handled by GSCXScanner.
 */
typedef NS_ENUM(NSUInteger, GSCXAnalyticsEvent) {
  /**
   Analytics event indicating that the scanner was installed.
   */
  GSCXAnalyticsEventScannerInstalled,

  /**
   Analytics event indicating that a scan was performed.
   */
  GSCXAnalyticsEventScanPerformed,

  /**
   Analytics event indicating that scan found errors.
   */
  GSCXAnalyticsEventErrorsFound,
};

/**
 Typedef for Analytics handler.

 @param event The analytics event to be handled.
 */
typedef void(^GSCXAnalyticsHandlerBlock)(GSCXAnalyticsEvent event, NSInteger count);

/**
 Class that handles all analytics in GSCXScanner.

 Note: by default GSCXAnalytics is a no op, to capture analytics of scans, iOS app must
 set `GSCXAnalytics.handler` property.
 */
@interface GSCXAnalytics : NSObject

/**
 Boolean property that specifies if analytics is enabled or not. Users must use this to quickly
 toggle analytics rather than modifying the @c handler. Default is @c NO.
 */
@property (class, nonatomic, assign) BOOL enabled;

/**
 Current analytics handler. Default is a no-op block and all analytics events are ignored.
 Users can set this block for custom handling of analytics events.
 */
@property (class, nonatomic) GSCXAnalyticsHandlerBlock handler;

/**
 Feeds an analytics event to be handled.

 @param event The event to be handled.
 @param count The count associated with the event.
 */
+ (void)invokeAnalyticsEvent:(GSCXAnalyticsEvent)event count:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
