#import <Cordova/CDV.h>
#import <TTLock/TTLock.h>

@interface TTLockPlugin : CDVPlugin {

}

- (void)lock_setupBluetooth:(CDVInvokedUrlCommand *)command;
- (void)lock_isScanning:(CDVInvokedUrlCommand *)command;
- (void)lock_startScan:(CDVInvokedUrlCommand *)command;
- (void)lock_stopScan:(CDVInvokedUrlCommand *)command;
- (void)lock_init:(CDVInvokedUrlCommand *)command;
- (void)lock_reset:(CDVInvokedUrlCommand *)command;
- (void)lock_control:(CDVInvokedUrlCommand *)command;
- (void)lock_setTime:(CDVInvokedUrlCommand *)command;
- (void)lock_getTime:(CDVInvokedUrlCommand *)command;
- (void)lock_getAudioState:(CDVInvokedUrlCommand *)command;
- (void)lock_setAudioState:(CDVInvokedUrlCommand *)command;
- (void)lock_setRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command;
- (void)lock_getRemoteUnlockSwitchState:(CDVInvokedUrlCommand *)command;
- (void)lock_getOperationLog:(CDVInvokedUrlCommand *)command;
- (void)lock_BatteryLevel:(CDVInvokedUrlCommand *)command;

- (void)lock_addFingerprint:(CDVInvokedUrlCommand *)command;
- (void)lock_deleteFingerprint:(CDVInvokedUrlCommand *)command;
- (void)lock_getAllValidFingerprints:(CDVInvokedUrlCommand *)command;
- (void)lock_clearAllFingerprints:(CDVInvokedUrlCommand *)command;
- (void)lock_modifyFingerprintValidityPeriod:(CDVInvokedUrlCommand *)command;

- (void)lock_createCustomPasscode:(CDVInvokedUrlCommand *)command;
- (void)lock_modifyPasscode:(CDVInvokedUrlCommand *)command;
- (void)lock_deletePasscode:(CDVInvokedUrlCommand *)command;
- (void)lock_resetPasscode:(CDVInvokedUrlCommand *)command;
- (void)lock_modifyAdminPasscode:(CDVInvokedUrlCommand *)command;
- (void)lock_getAdminPasscode:(CDVInvokedUrlCommand *)command;

- (void)lock_addICCard:(CDVInvokedUrlCommand *)command;
- (void)lock_modifyICCardValidityPeriod:(CDVInvokedUrlCommand *)command;
// - (void)lock_getAllValidICCards:(CDVInvokedUrlCommand *)command;
- (void)lock_deleteICCard:(CDVInvokedUrlCommand *)command;
// - (void)lock_clearAllICCard:(CDVInvokedUrlCommand *)command;

- (void)lock_setAutomaticLockingPeriod:(CDVInvokedUrlCommand *)command;
- (void)lock_setPassageMode:(CDVInvokedUrlCommand *)command;
- (void)lock_clearPassageMode:(CDVInvokedUrlCommand *)command;
// - (void)gateway_getSSID:(CDVInvokedUrlCommand *)command;
// - (void)gateway_disconnect:(CDVInvokedUrlCommand *)command;
// - (void)gateway_upgrade: (CDVInvokedUrlCommand *)command;
- (void) gateway_startScan:(CDVInvokedUrlCommand *)command;
- (void) gateway_connect: (CDVInvokedUrlCommand *)command;
- (void) gateway_stopScan: (CDVInvokedUrlCommand *)command;
- (void) gateway_scanWiFi: (CDVInvokedUrlCommand *)command;
- (void) gateway_init: (CDVInvokedUrlCommand *)command;
@end
