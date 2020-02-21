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

#import "GSCXTouchActivitySource.h"

#import "GSCXSwizzledMethodNotifier.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface GSCXTouchActivitySource ()

/**
 * The current state of this source.
 */
@property(assign, nonatomic) GSCXActivityStateType state;

/**
 * A callback invoked when this source's state changes.
 */
@property(copy, nonatomic) GSCXActivitySourceStateChangedBlock onStateChanged;

@end

@implementation GSCXTouchActivitySource

- (instancetype)init {
  self = [super init];
  if (self) {
    // The default is no touches on screen, so _state starts as free, not unknown.
    _state = GSCXActivityStateFree;
  }
  return self;
}

+ (instancetype)touchSource {
  return [[GSCXTouchActivitySource alloc] init];
}

- (void)startMonitoringWithStateChangedBlock:(GSCXActivitySourceStateChangedBlock)onStateChanged {
  GTX_ASSERT(!self.isMonitoring, @"Cannot start monitoring while already monitoring.");
  GTX_ASSERT(onStateChanged, @"State changed callback must not be nil.");
  self.onStateChanged = onStateChanged;
  __weak __typeof__(self) weakSelf = self;
  [[GSCXSwizzledMethodNotifier sharedInstance] addSendEventObserver:self
                                                          withBlock:^(UIEvent *_Nonnull event) {
                                                            [weakSelf gscx_sendEvent:event];
                                                          }];
  _monitoring = YES;
}

- (void)stopMonitoring {
  GTX_ASSERT(self.isMonitoring, @"Cannot stop monitoring while not monitoring.");
  [[GSCXSwizzledMethodNotifier sharedInstance] removeSendEventObserver:self];
  _monitoring = NO;
}

#pragma mark - Private

- (BOOL)gscx_someTouchesInSetAreActive:(NSSet<UITouch *> *)touches {
  __block BOOL isActive = NO;
  [touches enumerateObjectsUsingBlock:^(UITouch *obj, BOOL *stop) {
    if (obj.phase != UITouchPhaseEnded && obj.phase != UITouchPhaseCancelled) {
      isActive = YES;
      *stop = YES;
    }
  }];
  return isActive;
}

- (void)gscx_sendEvent:(UIEvent *)event {
  // If there are no touches, it must not be a touch event. This source does not handle non-touch
  // events.
  if ([[event allTouches] count] == 0) {
    return;
  }
  BOOL isActive = [self gscx_someTouchesInSetAreActive:event.allTouches];
  GSCXActivityStateType state = (isActive ? GSCXActivityStateBusy : GSCXActivityStateFree);
  if (state != self.state) {
    self.onStateChanged(state);
    _state = state;
  }
}

@end

NS_ASSUME_NONNULL_END
