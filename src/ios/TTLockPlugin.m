#import "TTLockPlugin.h"
#import <CallKit/CallKit.h>
#import <Photos/Photos.h>


@implementation TTLockPlugin

// Private static reference
static TTLockPlugin* ttLockPlugin;
static NSString* voipToken;
static NSDictionary* voipPayload;
static CDVInvokedUrlCommand* myCDVCommand;

// Public static method
+ (TTLockPlugin*) ttLockPlugin {
    return ttLockPlugin;
}

+ (CDVInvokedUrlCommand*) cdvCommand {
    return myCDVCommand;
}

// implement CDVPlugin delegate
- (void)pluginInitialize {
    ttLockPlugin = self;
}

// A public instance method
+ (void)voipToken: (NSString*)token
{
    NSLog(@"MyPlugin: %@", token);
    voipToken = token;
}

+ (void)voipPayload:(NSDictionary *)payload
{
    voipPayload = payload;
}

- (void)voip_endCall:(CDVInvokedUrlCommand *)command {
    NSString *callId = (NSString *)[command argumentAtIndex:0];
    NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:callId];
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
}

- (void)voip_pushToken:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:voipToken];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)open_nativesettings:(CDVInvokedUrlCommand *)command {
    NSString* urlString = (NSString *)[command argumentAtIndex:0];
    NSDictionary* options = @{};
    if(@available(iOS 10.0, *)){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:options completionHandler:^(BOOL success){
            if(success){
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to open settings"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        if(success){
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to open settings"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }
}

- (void)voip_getNotificationData:(CDVInvokedUrlCommand *)command {
    if (myCDVCommand == nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:voipPayload];
        [pluginResult setKeepCallbackAsBool:true];
        _myCDVCommand = command;
        myCDVCommand = command;  
    }
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}


- (void)voip_getNotificationData_internal {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                 messageAsDictionary:voipPayload];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:_myCDVCommand.callbackId];
    
}

- (void)misc_saveVideoToGallery:(CDVInvokedUrlCommand*)command {
    NSString *base64Video = [command.arguments objectAtIndex:0]; // Get the base64 video string from args
    
    // Decode the Base64 string into NSData
    NSData *videoData = [[NSData alloc] initWithBase64EncodedString:base64Video options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // Get current date and time for unique video name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
    NSString *formattedDateTime = [formatter stringFromDate:[NSDate date]];
    
    // Set the video file name
    NSString *title = [NSString stringWithFormat:@"S_HUB_CAP_%@.mp4", formattedDateTime];
    
    // Get a path to save the video temporarily
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *filePath = [tempDirectory stringByAppendingPathComponent:title];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // Write the video data to the temporary file
    NSError *error = nil;
    [videoData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    
    if (error) {
        NSLog(@"Error writing video to file: %@", error.localizedDescription);
        // Send error result to the callback
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to save video, make sure that photos permissions are enabled in app settings"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
  
    
    // Request authorization to access the Photos library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Create a video request and save the video to the gallery
        PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
        [creationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:fileURL options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // Check the completion result
        if (success) {
            // Send success result to the callback
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Video saved successfully."];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } else {
            NSLog(@"Error saving video to gallery: %@", error.localizedDescription);
            // Send error result to the callback
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to save video, make sure that photos permissions are enabled in app settings"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }];
}


- (void)misc_saveImageBase64ToGallery:(CDVInvokedUrlCommand*)command {
    // Get the base64 image string from the arguments
    NSString* base64Image = [command.arguments objectAtIndex:0];

    // Convert Base64 string to NSData
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image options:0];

    // Create UIImage from NSData
    UIImage *image = [UIImage imageWithData:imageData];

    if (image) {
        // Request authorization to access the photo library if needed
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                // Save the image to the photo library
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:image];
                    creationRequest.creationDate = [NSDate date]; // Set the creation date for the image
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    CDVPluginResult* pluginResult;
                    if (success) {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    } else {
                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.localizedDescription];
                    }
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }];
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Access to photo library was denied."];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    } else {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Invalid image data."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


- (void)lock_isScanning:(CDVInvokedUrlCommand *)command {
  CDVPluginResult* pluginResult = nil;
  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TTLock.isScanning];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)door_isScanning:(CDVInvokedUrlCommand *)command {
  CDVPluginResult* pluginResult = nil;
  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:TTLock.isScanning];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)lock_setupBluetooth:(CDVInvokedUrlCommand *)command {
  TTLock.printLog = YES;
  [TTLock setupBluetooth:^(TTBluetoothState state) {
    NSLog(@"##############  TTLock is working, bluetooth state: %ld  ##############", (long)state);

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:state];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)door_startScan:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin door_startScan  ##############");
    [TTDoorSensor startScanWithSuccess:^(TTDoorSensorScanModel * _Nonnull model) {
        NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:
          model.name, @"name",
          model.mac, @"address",
        nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:device];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTDoorSensorError error) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)lock_startScan:(CDVInvokedUrlCommand *)command {
  NSLog(@"##############  TTLockPlugin lock_startScan  ##############");
  [TTLock startScan:^(TTScanModel *scanModel) {
    NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:
      scanModel.lockName, @"name",
      scanModel.lockMac, @"address",
      scanModel.lockVersion, @"version",
      [NSNumber numberWithBool:!scanModel.isInited], @"isSettingMode",
      [NSNumber numberWithInteger:scanModel.electricQuantity], @"electricQuantity",
      [NSNumber numberWithInteger:scanModel.RSSI], @"rssi",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:device];
    [pluginResult setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)lock_getOrientation:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_getOrientation  ##############");
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock getUnlockDirectionWithLockData:lockData success:^(TTUnlockDirection direction) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt:direction], @"lockorientation",
        nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_setOrientation %@",errorMsg);    }];
}

- (void)lock_setLockPowerSavingMode:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_setOrientation  ##############");
    NSString *direction = (NSString *)[command argumentAtIndex:0];
    NSString *lockData = (NSString *)[command argumentAtIndex:1];
    BOOL powerFlag;
    if ([direction isEqual:@"1"]) {
        powerFlag = YES;
    } else {
        powerFlag = NO;
    }
    [TTLock setLockConfigWithType:TTWifiPowerSavingMode on:powerFlag lockData:lockData success:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_setLockPowerSavingMode %@",errorMsg);
    }];
}

- (void)lock_setOrientation:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_setOrientation  ##############");
    NSString *direction = (NSString *)[command argumentAtIndex:0];
    NSString *lockData = (NSString *)[command argumentAtIndex:1];
    TTUnlockDirection unlockdirection; 
    if ([direction  isEqual: @"1"]) {
        unlockdirection = TTUnlockDirectionLeft;
    } else {
        unlockdirection = TTUnlockDirectionRight;
    }
    [TTLock setUnlockDirection:unlockdirection lockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_setOrientation %@",errorMsg);
    }];
}

- (void)lock_addDoorSensor:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_addDoorSensor  ##############");
    NSString *doorMac = (NSString *)[command argumentAtIndex:0];
    NSString *lockData = (NSString *)[command argumentAtIndex:1];
    [TTLock addDoorSensorWithDoorSensorMac:doorMac lockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_addDoorSensor %@",errorMsg);
    }];
}

- (void)lock_deleteDoorSensor:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_deleteDoorSensor  ##############");
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock clearDoorSensorWithLockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_deleteDoorSensor %@",errorMsg);
    }];
}

- (void)lock_configWifi:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_configwifi  ##############");
    NSString *wifiName = (NSString *)[command argumentAtIndex:0];
    NSString *wifiPassword = (NSString *)[command argumentAtIndex:1];
    NSString *lockData = (NSString *)[command argumentAtIndex:2];
    [TTLock configWifiWithSSID:wifiName wifiPassword:wifiPassword lockData:lockData success:^{
        [TTLock configServerWithServerAddress:@"wifilock.ttlock.com" portNumber: @"4999" lockData:lockData success:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        } failure:^(TTError errorCode, NSString *errorMsg) {
            NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            NSLog(@"lock_configwifi %@",errorMsg);
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_configwifi %@",errorMsg);
    }];
}

- (void)lock_scanWifi:(CDVInvokedUrlCommand *)command {
    NSLog(@"##############  TTLockPlugin lock_scanwifi  ##############");
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock scanWifiWithLockData:lockData success:^(BOOL isFinished, NSArray *wifiArr) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:wifiArr];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        NSLog(@"lock_scanwifi %@",errorMsg);
    }];
}

- (void)lock_stopScan:(CDVInvokedUrlCommand *)command {
  [TTLock stopScan];
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)lock_stopDoorScan:(CDVInvokedUrlCommand *)command {
  [TTDoorSensor stopScan];
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)doorsensor_init:(CDVInvokedUrlCommand *)command {
    NSString *doorMac = (NSString *)[command argumentAtIndex:0];
    NSString *lockData = (NSString *)[command argumentAtIndex:1];
    
    [TTDoorSensor initializeWithDoorSensorMac:doorMac lockData:lockData success:^(int electricQuantity, TTSystemInfoModel * _Nonnull systemModel) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTDoorSensorError error) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)lock_init:(CDVInvokedUrlCommand *)command {
  NSString *lockMac = (NSString *)[command argumentAtIndex:0];
  NSString *lockName = (NSString *)[command argumentAtIndex:1];
  NSString *lockVersion = (NSString *)[command argumentAtIndex:2];

  NSDictionary *arguments = [NSDictionary dictionaryWithObjectsAndKeys:
    lockMac, @"lockMac",
    lockName, @"lockName",
    lockVersion, @"lockVersion",
  nil];

  [TTLock initLockWithDict:arguments success:^(NSString *lockData) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      lockData, @"lockData",
      [NSNumber numberWithLongLong:0], @"specialValue",
      [TTLockPlugin getLockFeaturesWithLockData:lockData], @"features",
    nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_init %@",errorMsg);
  }];
}

- (void)lock_reset:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock resetLockWithLockData:lockData success:^(void) {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_reset %@",errorMsg);
  }];
}

- (void)lock_control:(CDVInvokedUrlCommand *)command {
  TTControlAction action = (TTControlAction)[[command.arguments objectAtIndex:0] integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  NSLog(@"lock_control action %d",action);

  [TTLock controlLockWithControlAction:action lockData:lockData success:^(long long lockTime, NSInteger electricQuantity, long long uniqueId) {
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithLongLong:lockTime], @"lockTime",
      [NSNumber numberWithInteger:electricQuantity], @"electricQuantity",
      [NSNumber numberWithLongLong:uniqueId], @"uniqueId",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"lock_control %@",errorMsg);
  }];
}

- (void)lock_getTime:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock getLockTimeWithLockData:lockData
    success:^(long long timestamp) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithLongLong:timestamp], @"timestamp",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setTime:(CDVInvokedUrlCommand *)command {
  NSString *timestampStr = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];
  long long timestamp = [timestampStr integerValue];

  [TTLock setLockTimeWithTimestamp:timestamp lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_BatteryLevel:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock getElectricQuantityWithLockData:lockData
    success:^(NSInteger battery_level) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:battery_level], @"battery_level",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_getAudioState:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

    [TTLock getLockConfigWithType:1 lockData:lockData
    success:^(TTLockConfigType type, BOOL audioState) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:audioState], @"audiostate",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_getRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

    [TTLock getRemoteUnlockSwitchWithLockData:lockData
    success:^(BOOL isOn) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:isOn], @"remoteunlockstate",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setAudioState:(CDVInvokedUrlCommand *)command {
  NSString *audioState = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];
  int audioStateInt = [audioState integerValue];
  BOOL enableAudio = YES;
  if (audioStateInt == 1) {
      enableAudio = NO;
  }

    [TTLock setLockConfigWithType:1 on:enableAudio lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command {
  NSString *remoteUnlockState = (NSString *)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:0];
  int remoteUnlockStateInt = [remoteUnlockState integerValue];
  BOOL enableRemoteUnlock = YES;
  if (remoteUnlockStateInt == 1) {
      enableRemoteUnlock = NO;
  }

    [TTLock setRemoteUnlockSwitchOn:enableRemoteUnlock lockData:lockData
    success:^(NSString *lockData) {
       NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        lockData, @"lockData",
        nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_getOperationLog:(CDVInvokedUrlCommand *)command {
  NSString *type = (NSString *)[command argumentAtIndex:0];
  TTOperateLogType logType = [type integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock getOperationLogWithType:logType lockData:lockData
    success:^(NSString *logs) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        logs, @"logs",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyFaceValidityPeriod:(CDVInvokedUrlCommand *)command {
    long long startDate = (long long)[[command.arguments objectAtIndex:0] longValue];
    long long endDate = (long long)[[command.arguments objectAtIndex:1] longValue];
    NSString *faceNumber = (NSString *)[command argumentAtIndex:2];
    NSString *lockData = (NSString *)[command argumentAtIndex:3];
    [TTLock modifyFaceValidityWithCyclicConfig:@[] faceNumber:faceNumber startDate:startDate endDate:endDate lockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"status",
          [NSNumber numberWithInteger:errorCode], @"error",
          errorMsg, @"message",
        nil];
        // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_addFace failure %@",errorMsg);
    }];
}

- (void)lock_addFace:(CDVInvokedUrlCommand *)command {
    long long startDate = (long long)[[command.arguments objectAtIndex:0] longValue];
    long long endDate = (long long)[[command.arguments objectAtIndex:1] longValue];
    NSString *lockData = (NSString *)[command argumentAtIndex:2];
    [TTLock addFaceWithCyclicConfig:@[] startDate:startDate endDate:endDate lockData:lockData progress:^(TTAddFaceState state, TTFaceErrorCode faceErrorCode) {
        NSString *status = @"unknown";
        NSDictionary *resultDict;

        if (state == 2) {
          status = @"add";
        } else if (state == 1) {
          status = @"collected";
        } else {
            status = @"1";
        }

        resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          status, @"status",
          [NSNumber numberWithInteger:faceErrorCode], @"description",
//          [NSNumber numberWithInteger:totalCount], @"totalCount",
        nil];

        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [pluginResult setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_addFingerprint progress");
    } success:^(NSString *faceNumber) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"finished", @"status",
         faceNumber, @"faceNumber",
        nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_addFingerprint success");
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"status",
          [NSNumber numberWithInteger:errorCode], @"error",
          errorMsg, @"message",
        nil];
        // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_addFace failure %@",errorMsg);
    }];
}

- (void)lock_getAllValidFaces:(CDVInvokedUrlCommand *)command {
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock getAllValidFacesWithLockData:lockData success:^(NSString *allFacesJsonString) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:allFacesJsonString];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"status",
          [NSNumber numberWithInteger:errorCode], @"error",
          errorMsg, @"message",
        nil];
        // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_getFaces failure %@",errorMsg);
    }];
}

- (void)lock_clearAllFaces:(CDVInvokedUrlCommand *)command {
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock clearFaceWithLockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"status",
          [NSNumber numberWithInteger:errorCode], @"error",
          errorMsg, @"message",
        nil];
        // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_getFaces failure %@",errorMsg);
    }];
}

- (void)lock_deleteFace:(CDVInvokedUrlCommand *)command {
    NSString *faceNumber = (NSString *)[command argumentAtIndex:0];
    NSString *lockData = (NSString *)[command argumentAtIndex:1];
    [TTLock deleteFaceNumber:faceNumber lockData:lockData success:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"status",
          [NSNumber numberWithInteger:errorCode], @"error",
          errorMsg, @"message",
        nil];
        // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        NSLog(@"lock_deleteface failure %@",errorMsg);
    }];
}

- (void)lock_addFingerprint:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[[command.arguments objectAtIndex:0] longValue];
  long long endDate = (long long)[[command.arguments objectAtIndex:1] longValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:2];
  [TTLock addFingerprintStartDate:startDate endDate:endDate lockData:lockData
    progress:^(int currentCount, int totalCount) {
      NSString *status = @"unknown";
      NSDictionary *resultDict;

      if (currentCount == 0) {
        status = @"add";
      } else if (currentCount > 0) {
        status = @"collected";
      }

      resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        status, @"status",
        [NSNumber numberWithInteger:currentCount], @"currentCount",
        [NSNumber numberWithInteger:totalCount], @"totalCount",
      nil];

      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [pluginResult setKeepCallbackAsBool:true];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint progress");
    }
    success:^(NSString *fingerprintNumber) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"finished", @"status",
        fingerprintNumber, @"fingerprintNumber",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint success");
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"error", @"status",
        [NSNumber numberWithInteger:errorCode], @"error",
        errorMsg, @"message",
      nil];
      // NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addFingerprint failure %@",errorMsg);
    }
  ];
}

- (void)lock_deleteFingerprint:(CDVInvokedUrlCommand *)command {
  NSString *fingerprintNumber = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deleteFingerprintNumber:fingerprintNumber lockData:lockData
    success:^(void) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_getAllValidFingerprints:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock getAllValidFingerprintsWithLockData:lockData
    success:^(NSString *allFingerprintsJsonString) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:allFingerprintsJsonString];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_clearAllFingerprints:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock clearAllFingerprintsWithLockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyFingerprintValidityPeriod:(CDVInvokedUrlCommand *)command {
  long long startDate = (long long)[command argumentAtIndex:0];
  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *fingerprintNumber = (NSString *)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock modifyFingerprintValidityPeriodWithFingerprintNumber:fingerprintNumber startDate:startDate endDate:endDate lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_createCustomPasscode:(CDVInvokedUrlCommand *)command {
  NSString *customPasscode = (NSString *)[command argumentAtIndex:0];
    NSString *startTime = (NSString *)[command argumentAtIndex:1];
    NSString *endTime = (NSString *)[command argumentAtIndex:2];
    long startDate = [startTime integerValue];
    long endDate = [endTime integerValue];
//  long long startDate = (long long)[command argumentAtIndex:1];
//  long long endDate = (long long)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock createCustomPasscode:customPasscode startDate:startDate endDate:endDate lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyAdminPasscode:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];
  NSString *lockMac = (NSString *)[command argumentAtIndex:1];
  NSString *newAdminPasscode = (NSString *)[command argumentAtIndex:2];
  [TTLock modifyAdminPasscode:newAdminPasscode lockData:lockData success:^{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } failure:^(TTError errorCode, NSString *errorMsg) {
    NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

- (void)lock_getAdminPasscode:(CDVInvokedUrlCommand *)command {
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    BOOL isSupportAdminPasscode = [TTUtil lockFeatureValue:lockData suportFunction:TTLockFeatureValueGetAdminPasscode];
  if(!isSupportAdminPasscode){
    NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
     @"false", @"isSupported",
    nil];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  } else {
    [TTLock getAdminPasscodeWithLockData:lockData success:^(NSString *adminPasscode) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
       @"true", @"isSupported",
       adminPasscode, @"adminpasscode",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
  }
}

- (void)lock_modifyPasscode:(CDVInvokedUrlCommand *)command {
  NSString *oldPasscode = (NSString *)[command argumentAtIndex:0];
  NSString *newPasscode = (NSString *)[command argumentAtIndex:1];
    NSString *startTime = (NSString *)[command argumentAtIndex:2];
    NSString *endTime = (NSString *)[command argumentAtIndex:3];
    long startDate = [startTime integerValue];
    long endDate = [endTime integerValue];
  NSString *lockData = (NSString *)[command argumentAtIndex:4];

  [TTLock modifyPasscode:oldPasscode newPasscode:newPasscode startDate:startDate endDate:endDate lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_deletePasscode:(CDVInvokedUrlCommand *)command {
  NSString *passcode = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deletePasscode:passcode lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_resetPasscode:(CDVInvokedUrlCommand *)command {
  NSString *lockData = (NSString *)[command argumentAtIndex:0];

  [TTLock resetPasscodesWithLockData:lockData
    success:^(NSString *lockData) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_addICCard:(CDVInvokedUrlCommand *)command {
    NSString *startTime = (NSString *)[command argumentAtIndex:0];
    NSString *endTime = (NSString *)[command argumentAtIndex:1];
    long startDate = [startTime integerValue];
    long endDate = [endTime integerValue];
//  long long startDate = (long long)[command argumentAtIndex:0];
//  long long endDate = (long long)[command argumentAtIndex:1];
  NSString *lockData = (NSString *)[command argumentAtIndex:2];

  [TTLock addICCardStartDate:startDate endDate:endDate lockData:lockData
    progress:^(TTAddICState state) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"entered", @"status",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [pluginResult setKeepCallbackAsBool:true];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    success:^(NSString *cardNumber) {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"collected", @"status",
        cardNumber, @"cardNum",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

      NSLog(@"lock_addICCard success");
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_modifyICCardValidityPeriod:(CDVInvokedUrlCommand *)command {
    NSString *startTime = (NSString *)[command argumentAtIndex:0];
    NSString *endTime = (NSString *)[command argumentAtIndex:1];
    long startDate = [startTime integerValue];
    long endDate = [endTime integerValue];
 // long long startDate = (long long)[command argumentAtIndex:0];
  //long long endDate = (long long)[command argumentAtIndex:1];
  NSString *cardNumber = (NSString *)[command argumentAtIndex:2];
  NSString *lockData = (NSString *)[command argumentAtIndex:3];

  [TTLock modifyICCardValidityPeriodWithCardNumber:cardNumber startDate:startDate endDate:endDate lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_deleteICCard:(CDVInvokedUrlCommand *)command {
  NSString *cardNumber = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];

  [TTLock deleteICCardNumber:cardNumber lockData:lockData
    success:^() {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}

- (void)lock_setAutomaticLockingPeriod:(CDVInvokedUrlCommand *)command {
  NSString *autoLock = (NSString *)[command argumentAtIndex:0];
  NSString *lockData = (NSString *)[command argumentAtIndex:1];
    int autoLockPeriod = [autoLock integerValue];
  [TTLock setAutomaticLockingPeriodicTime:autoLockPeriod lockData:lockData
    success:^() {
      NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"success", @"status",
      nil];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
      messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    failure:^(TTError errorCode, NSString *errorMsg) {
      NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
  ];
}
-(void) lock_clearPassageMode:(CDVInvokedUrlCommand *)command {
    NSString *lockData = (NSString *)[command argumentAtIndex:0];
    [TTLock clearPassageModeWithLockData:lockData success:^(){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    //[self showToastAndLog:LS(@"Success")];
                }
        failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    //[self showToastAndLog:errorMsg];
                }];
}

- (void) lock_setPassageMode:(CDVInvokedUrlCommand *)command {
    NSString *startTime = (NSString *)[command argumentAtIndex:0];
    NSString *endTime = (NSString *)[command argumentAtIndex:1];
    int startDate = [startTime integerValue];
    int endDate = [endTime integerValue];
    NSString *lockData = (NSString *)[command argumentAtIndex:3];
    NSArray *weekly = (NSArray *)[command argumentAtIndex:2];
    [TTLock configPassageModeWithType:TTPassageModeTypeWeekly weekly:weekly monthly:nil startDate:startDate endDate:endDate lockData:lockData success:^(){
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                  // [self showToastAndLog:LS(@"Success")];
               }
        failure:^(TTError errorCode, NSString *errorMsg) {
        NSDictionary *resultDict = [TTLockPlugin makeError:errorCode errorMessage:errorMsg];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDict];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                  // [self showToastAndLog:errorMsg];
               }];
}

- (void) gateway_startScan:(CDVInvokedUrlCommand *)command {
    [TTGateway startScanGatewayWithBlock:^(TTGatewayScanModel *model) {
        NSDictionary* resultDevice = @{
            @"mAddress": model.gatewayMac,
            @"name": model.gatewayName,
            @"rssi": [NSString stringWithFormat:@"%ld", (NSInteger)model.RSSI],
            @"isDfuMode" : model.isDfuMode == YES ? @"1" : @"0"
        };
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDevice];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) gateway_connect: (CDVInvokedUrlCommand *)command {
    NSString* gatewayMac = [command argumentAtIndex:0];
    [TTGateway connectGatewayWithGatewayMac:gatewayMac block:^(TTGatewayConnectStatus connectStatus) {
        if (connectStatus == TTGatewayConnectSuccess) {
            [TTGateway stopScanGateway];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
          }
    }];
}

- (void) gateway_stopScan: (CDVInvokedUrlCommand *)command {
    [TTGateway stopScanGateway];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) gateway_scanWiFi: (CDVInvokedUrlCommand *)command {
    [TTGateway  scanWiFiByGatewayWithBlock:^(BOOL isFinished, NSArray *WiFiArr, TTGatewayStatus status) {
        if (status == TTGatewayNotConnect || status == TTGatewayDisconnect ) {
            NSDictionary *errDict = [TTLockPlugin makeError:TTErrorDisconnection errorMessage:@"Gateway Diconnected, please try again"];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
     
        if (WiFiArr.count > 0) {
            if (isFinished == YES) {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
                [pluginResult setKeepCallbackAsBool:false];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            } else {
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:WiFiArr];
                [pluginResult setKeepCallbackAsBool:true];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }
    }];
}

- (void) gateway_init: (CDVInvokedUrlCommand *)command {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"SSID"] = [command argumentAtIndex:3];
    dict[@"wifiPwd"] = [command argumentAtIndex:4];
    dict[@"uid"] = [command argumentAtIndex:1];
    dict[@"userPwd"] = [command argumentAtIndex:2];
    dict[@"gatewayName"]= [command argumentAtIndex:0];
     
    [TTGateway initializeGatewayWithInfoDic:dict block:^(TTSystemInfoModel *systemInfoModel, TTGatewayStatus status) {
     
            if (status == TTGatewayNotConnect || status == TTGatewayDisconnect) {
                NSDictionary *errDict = [TTLockPlugin makeError:TTErrorDisconnection errorMessage:@"Gateway Diconnected, turn off and on the gateway and please try again"];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errDict];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return ;
            }
            if (status == TTGatewaySuccess) {
                NSDictionary* res = @{
                    @"modelNum": systemInfoModel.modelNum,
                    @"firmwareRevision": systemInfoModel.firmwareRevision,
                    @"hardwareRevision": systemInfoModel.hardwareRevision
                };
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:res];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
            if (status == TTGatewayWrongSSID) {
     
                NSDictionary *errDict = [TTLockPlugin makeError:TTErrorInvalidParameter errorMessage:@"Wifi Name is wrong, please check and try again"];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errDict];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
            if (status == TTGatewayWrongWifiPassword) {
     
                NSDictionary *errDict = [TTLockPlugin makeError:TTErrorInvalidParameter errorMessage:@"Wifi password is wrong, please check and try again"];
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:errDict];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
        }];
}

// Helpers

+ (NSDictionary *)makeError:(TTError) errorCode errorMessage:(NSString *)errorMessage {
  NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
    [NSNumber numberWithInteger:errorCode], @"error",
    errorMessage, @"message",
  nil];
  return resultDict;
}

+ (NSNumber *)hasFeature:(long long)specialValue feature:(TTLockSpecialFunction)feature {
  return [NSNumber numberWithBool:[TTUtil lockSpecialValue:specialValue suportFunction:feature]];
}

+ (NSNumber *)hasFeatureValue:(NSString *)lockData feature:(TTLockFeatureValue)feature {
  return [NSNumber numberWithBool:[TTUtil lockFeatureValue:lockData suportFunction:feature]];
}

+ (NSDictionary *)getLockFeatures:(long long)specialValue {
  NSDictionary *features = [NSDictionary dictionaryWithObjectsAndKeys:
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPasscode], @"passcode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionICCard], @"icCard",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionFingerprint], @"fingerprint",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionWristband], @"autolock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionAutoLock], @"autolock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionDeletePasscode], @"deletePasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionManagePasscode], @"managePasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLocking], @"locking",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPasscodeVisible], @"passcodeVisible",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionGatewayUnlock], @"gatewayUnlock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLockFreeze], @"lockFreeze",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionCyclePassword], @"cyclicPassword",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionDoorSensor], @"doorSensor",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionRemoteUnlockSwicth], @"remoteUnlockSwitch",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionAudioSwitch], @"audioSwitch",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNBIoT], @"nbIoT",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionGetAdminPasscode], @"getAdminPasscode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionHotelCard], @"hotelCard",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNoClock], @"noClock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionNoBroadcastInNormal], @"noBroadcastInNormal",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionPassageMode], @"passageMode",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionTurnOffAutoLock], @"turnOffAutolock",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionWirelessKeypad], @"wirelessKeypad",
    [TTLockPlugin hasFeature:specialValue feature:TTLockSpecialFunctionLight], @"light",
  nil];
  return features;
}

+ (NSDictionary *)getLockFeaturesWithLockData:(NSString *)lockData {
  NSDictionary *features = [NSDictionary dictionaryWithObjectsAndKeys:
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePasscode], @"passcode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueICCard], @"icCard",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueFingerprint], @"fingerprint",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueWristband], @"autolock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueAutoLock], @"autolock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueDeletePasscode], @"deletePasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueManagePasscode], @"managePasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLocking], @"locking",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePasscodeVisible], @"passcodeVisible",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueGatewayUnlock], @"gatewayUnlock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLockFreeze], @"lockFreeze",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueCyclePassword], @"cyclicPassword",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueDoorSensor], @"doorSensor",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueRemoteUnlockSwicth], @"remoteUnlockSwitch",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueAudioSwitch], @"audioSwitch",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNBIoT], @"nbIoT",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueGetAdminPasscode], @"getAdminPasscode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueHotelCard], @"hotelCard",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNoClock], @"noClock",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueNoBroadcastInNormal], @"noBroadcastInNormal",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValuePassageMode], @"passageMode",
    [TTLockPlugin hasFeatureValue:lockData feature:TTLockFeatureValueLight], @"light",
  nil];
  return features;
}

@end
