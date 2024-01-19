#import "AppDelegate+TTLockPlugin.h"
#import "TTLockPlugin.h"
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
//#import "ProviderDelegate+TTLockPlugin.h"

@implementation AppDelegate (TTLockPlugin)
static NSDictionary* voipPayload;
static NSUUID* mycallUUid;

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self voipRegistration];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (CXProviderConfiguration *)providerConfiguration {
    CXProviderConfiguration *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"AudioCallKit"];
    providerConfiguration.supportsVideo = YES;
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.supportedHandleTypes = [NSSet setWithArray:@[[NSNumber numberWithInt:CXHandleTypeGeneric]]];
    providerConfiguration.ringtoneSound = @"longbell.wav";
    //providerConfiguration.iconTemplateImageData
    return providerConfiguration;
}

- (void) voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    
    voipRegistry.delegate = self;
    
    NSData *token = [voipRegistry pushTokenForType:PKPushTypeVoIP];
    
        voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
   
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(nonnull PKPushCredentials *)credentials forType:(nonnull NSString *)type {
    //VoIP Push token
       if([credentials.token length] == 0) {
           NSLog(@"[objC] No device token!");
           [TTLockPlugin voipToken:@""];
//           [TTLockPlugin.ttLockPlugin voipToken:@""];
           return;
       }

       //http://stackoverflow.com/a/9372848/534755
       NSLog(@"[objC] Device token: %@", credentials.token);
       const unsigned *tokenBytes = [credentials.token bytes];
       NSString *sToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                            ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                            ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                            ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

       NSMutableDictionary* results = [NSMutableDictionary dictionaryWithCapacity:2];
       [results setObject:sToken forKey:@"deviceToken"];
       [results setObject:@"true" forKey:@"registration"];
    @try {
        [TTLockPlugin voipToken:sToken];
    } @catch (NSException *e){
        NSLog(@"hello", e.description);
    }
}



-(void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(nonnull PKPushPayload *)payload forType:(nonnull NSString *)type withCompletionHandler:(nonnull void (^)(void))completion {
    //Received VOIP
    NSDictionary *payloaddict = payload.dictionaryPayload;
    voipPayload =payloaddict;
    NSString *callid = [[[payloaddict objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"connection_id"];
    NSString *eventType = @"";
    eventType = [[[payloaddict objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"event"];
    
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:callid];//[[NSUUID alloc]init];//[[[payloaddict objectForKey:@"custom"] objectForKey:@"a"] objectForKey:@"connection_id"];//[[NSUUID alloc]init];//[self handlePushNotification:payload];
    mycallUUid = callUUID;
    NSString *displayName = @"Visitor";
    NSString *username = @"Visitor";
    if ([eventType isEqualToString:@"answered"] || [eventType isEqualToString:@"ended"]) {
//                [callProvider reportCallWithUUID:callUUID endedAtDate:[NSDate date] reason:CXCallEndedReasonRemoteEnded];
        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:callUUID];
        CXTransaction *transaction = [[CXTransaction alloc] init];
        [transaction addAction:endCallAction];

        CXCallController *callController = [[CXCallController alloc] init];
        [callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error ending call: %@", error.localizedDescription);
                // Handle the error if needed
            } else {
                NSLog(@"Call ended successfully.");
                // Perform any additional cleanup or post-call logic
            }
        }];

           
    } else {
        CXProvider *callProvider = [[CXProvider alloc] initWithConfiguration:self.providerConfiguration];
        [callProvider setDelegate:self queue:nil];
        CXCallUpdate *callInfo = [[CXCallUpdate alloc] init];
        callInfo.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:@"Visitor"];
        callInfo.supportsHolding = NO;
        callInfo.supportsGrouping = NO;
        callInfo.supportsUngrouping = NO;
        callInfo.supportsDTMF = YES;
        callInfo.hasVideo = YES;
        callInfo.localizedCallerName = displayName;
        [callProvider reportNewIncomingCallWithUUID:callUUID update:callInfo completion:^(NSError * _Nullable error){
            if(error){
                
            }
            //Succesfully shown call screen
        }];
        
    }
    
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsDictionary:voipPayload];
    [pluginResult setKeepCallbackAsBool:true];
    [action fulfill];
    CDVInvokedUrlCommand* mycommand = [TTLockPlugin cdvCommand];
    [TTLockPlugin.ttLockPlugin.commandDelegate sendPluginResult:pluginResult callbackId:mycommand.callbackId];
    
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    // Your logic to end the call based on some condition
    [action fulfill];

}

@end


