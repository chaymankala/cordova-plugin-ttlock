#import "AppDelegate.h"
#import "CallKit/CallKit.h"

@interface AppDelegate (TTLockPlugin) <CXProviderDelegate>
@property (nonatomic, nonnull, strong) CXProvider *provider;
@property (nonatomic, nonnull, strong) CXCallController *callController;
@end
