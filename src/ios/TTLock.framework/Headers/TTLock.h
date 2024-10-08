//
//  TTLock.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/23.
//  Copyright © 2019 Sciener. All rights reserved.

//  version:3.1.3

#import <Foundation/Foundation.h>
#import "TTBlocks.h"
#import "TTGateway.h"
#import "TTGatewayMacro.h"
#import "TTGatewayScanModel.h"
#import "TTSystemInfoModel.h"
#import "TTMacros.h"
#import "TTScanModel.h"
#import "TTSystemInfoModel.h"
#import "TTUtil.h"
#import "TTSecurityUtil.h"
#import "TTWirelessKeypad.h"
#import "TTWirelessKeypadScanModel.h"


@interface TTLock : NSObject
/**
 Print sdk log
 */
@property (class, nonatomic, assign, getter=isPrintLog) BOOL printLog;

/**
 Current Bluetooth state
 */
@property (class, nonatomic, assign, readonly) TTBluetoothState bluetoothState;

/**
 The current authorization of the manager
 */
@property(class, nonatomic, assign, readonly) TTManagerAuthorization authorization API_AVAILABLE(ios(13.0));

/**
  Whether the Bluetooth is scanning
 */
@property (class, nonatomic, assign, readonly) BOOL isScanning;

/**
 Setup Bluetooth

 @param bluetoothStateObserver A block invoked when the bluetooth setup finished
 */
+ (void)setupBluetooth:(TTBluetoothStateBlock)bluetoothStateObserver;

/**
 Start Bluetooth  scanning

 @param scanBlock A block invoked when the bluetooth is scanning
 */
+ (void)startScan:(TTScanBlock)scanBlock;

/**
 Stop Bluetooth scanning
 */
+ (void)stopScan;

#pragma mark - Lock basic operation
/**
 Initialize the lock
 
 @param dict @{@"lockMac": xxx, @"lockName": xxx, @"lockVersion": xxx}
 @param success A block invoked when the lock is initialize
 @param failure A block invoked when the operation fails
 */
+ (void)initLockWithDict:(NSDictionary *)dict
                 success:(TTInitLockSucceedBlock)success
                 failure:(TTFailedBlock)failure;


/**
 Reset the lock

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetLockWithLockData:(NSString*)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;


/**
 Set the lock time

 @param timestamp A timestamp（millisecond）
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock time is set
 @param failure A block invoked when the operation fails
 */
+ (void)setLockTimeWithTimestamp:(long long)timestamp
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure;

/**
 Set the lock audio

 @param enable A timestamp（millisecond）
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock time is set
 @param failure A block invoked when the operation fails
 */
+ (void)setMuteMode:(BOOL)enable
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure;                        

/**
 Get the lock time

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock time is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockTimeWithLockData:(NSString *)lockData
                        success:(TTGetLockTimeSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Get the lock audio

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock audio is got
 @param failure A block invoked when the operation fails
 */
+ (void)getMuteModeState:(NSString *)lockData
                        success:(TTGetMuteModeSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Get the lock battery

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock audio is got
 @param failure A block invoked when the operation fails
 */
+ (void)getBatteryLevel:(NSString *)lockData
                        success:(TTGetBatterySucceedBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Get the lock log

 @param type The log type
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock log is got
 @param failure A block invoked when the operation fails
 */
+ (void)getOperationLogWithType:(TTOperateLogType)type
                       lockData:(NSString *)lockData
                        success:(TTGetLockOperateRecordSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Get the lock electric quantity

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock power is got
 @param failure A block invoked when the operation fails
 */
+ (void)getElectricQuantityWithLockData:(NSString *)lockData
                                success:(TTGetElectricQuantitySucceedBlock)success
                                failure:(TTFailedBlock)failure;


/**
 Get the lock version
 @param lockMac lockMac
 @param success A block invoked when the lock version is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockVersionWithWithLockMac:(NSString *)lockMac
                              success:(TTGetLockVersionSucceedBlock)success
                              failure:(TTFailedBlock)failure;


/**
 Get the lock feature value

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock feature value is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockFeatureValueWithLockData:(NSString *)lockData
                                success:(TTGetFeatureValueSucceedBlock)success
                                failure:(TTFailedBlock)failure;

/**
 Get the lock system infomation

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock system infomation is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockSystemInfoWithLockData:(NSString*)lockData
                              success:(TTGetLockSystemSucceedBlock)success
                              failure:(TTFailedBlock)failure;


/**
 Get the lock switch state

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock switch state is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockSwitchStateWithLockData:(NSString *)lockData
                               success:(TTGetLockStatusSuccessBlock)success
                               failure:(TTFailedBlock)failure;


/**
 Set the lock automatic locking periodic time

 @param time The time(second）must between minTime and maxTime
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock automatic locking periodic time is set
 @param failure A block invoked when the operation fails
 */
+ (void)setAutomaticLockingPeriodicTime:(int)time
                               lockData:(NSString *)lockData
                                success:(TTSucceedBlock)success
                                failure:(TTFailedBlock)failure;


/**
 Get the lock automatic locking periodic time

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock automatic locking periodic time is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAutomaticLockingPeriodicTimeWithLockData:(NSString *)lockData
                                            success:(TTGetAutomaticLockingPeriodicTimeSucceedBlock)success
                                            failure:(TTFailedBlock)failure;


/**
 Set the lock remote unlock switch

 @param on Remote unlock switch on or off
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock remote unlock switch is set
 @param failure A block invoked when the operation fails
 */
+ (void)setRemoteUnlockSwitchOn:(BOOL)on
                       lockData:(NSString *)lockData
                        success:(TTSetRemoteUnlockSwitchSuccessBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Get the lock remote unlock switch state

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock remote unlock switch state is got
 @param failure A block invoked when the operation fails
 */
+ (void)getRemoteUnlockSwitchWithLockData:(NSString *)lockData
                                  success:(TTGetSwitchStateSuccessBlock)success
                                  failure:(TTFailedBlock)failure;


/**
 Config the lock passage mode. If config succeed,the lock will always be unlocked

 @param type TTPassageModeType type
 @param weekly Any number from 1 to 7, such as @[@1,@3,@6,@7]. If type == TTPassageModeTypeMonthly, the weekly will not be set
 @param monthly Any number from 1 to 31, such as @[@1,@13,@26,@31]. If type == TTPassageModeTypeWeekly, the monthly will not be set
 @param startDate The time when it becomes valid (minutes from 0 clock)
 @param endDate The time when it is expired (minutes from 0 clock)
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage mode is set
 @param failure A block invoked when the operation fails
 */
+ (void)configPassageModeWithType:(TTPassageModeType)type
                           weekly:(NSArray<NSNumber *> *)weekly
                          monthly:(NSArray<NSNumber *> *)monthly
                        startDate:(int)startDate
                          endDate:(int)endDate
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;

/**
 get all passage modes of the lock
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when all passage modes is got
 @param failure A block invoked when the operation fails
 */
+ (void)getPassageModesWithLockData:(NSString *)lockData
                                   success:(TTGetPassageModelSuccessBlock)success
                                   failure:(TTFailedBlock)failure;

/**
 Delete passage mode

 @param type TTPassageModeType type
 @param weekly Any number from 1 to 7, such as @[@1,@3,@6,@7]. If type == TTPassageModeTypeMonthly, the weekly will not be set
 @param monthly Any number from 1 to 31, such as @[@1,@13,@26,@31]. If type == TTPassageModeTypeWeekly, the monthly will not be set
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage mode is delete
 @param failure A block invoked when the operation fails
 */
+ (void)deletePassageModeWithType:(TTPassageModeType)type
                           weekly:(NSArray<NSNumber *> *)weekly
                          monthly:(NSArray<NSNumber *> *)monthly
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;


/**
 Clear all passage modes

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage modes are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearPassageModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;

/**
Set Light Time
@param time      Light Time
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setLightTime:(int)time
            lockData:(NSString *)lockData
             success:(TTSucceedBlock)success
             failure:(TTFailedBlock)failure;
/**
Get Light Time

@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)getLightTimeWithLockData:(NSString *)lockData
                         success:(TTGetLightTimeSuccessBlock)success
                         failure:(TTFailedBlock)failure;
/**
Set Lock Config
 
@param type      TTLockConfigType
@param lockData The lock data string used to operate lock
@param success A block invoked when when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setLockConfigWithType:(TTLockConfigType)type
                           on:(BOOL)on
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;
/**
 Get Lock Config
 
 @param type      TTLockConfigType
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation succeeds
 @param failure A block invoked when the operation fails
 */
+ (void)getLockConfigWithType:(TTLockConfigType)type
                     lockData:(NSString *)lockData
                      success:(TTGetLockConfigSuccessBlock)success
                      failure:(TTFailedBlock)failure;
/**
 Set Hotel Card Sector
 @param sector    sector = @[] means all sectors can use. The sector value range is 1 - 16.
 Such as, sector = @"1,4,16" means First, fourth and sixteenth sectors can use.
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation succeeds
 @param failure A block invoked when the operation fails
 */
+ (void)setHotelCardSector:(NSString *)sector
				  lockData:(NSString *)lockData
				   success:(TTSucceedBlock)success
				   failure:(TTFailedBlock)failure;

/**
Set Hotel Data

@param hotelInfo hotel Info
@param buildingNumber building Number
@param floorNumber floor Number
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setHotelDataWithHotelInfo:(NSString *)hotelInfo
				   buildingNumber:(int)buildingNumber
					  floorNumber:(int)floorNumber
						 lockData:(NSString *)lockData
						  success:(TTSucceedBlock)success
						  failure:(TTFailedBlock)failure;

#pragma mark - Lock upgrade

/**
 Activate the lock into upgrade mode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is activated
 @param failure A block invoked when the operation fails
 */
+ (void)enterUpgradeModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;

#pragma mark - NB-IoT

/**
 Set the lock nb-iot

 @param serverAddress The server ip
 @param portNumber The server port
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock nb-iot is set
 @param failure A block invoked when the operation fails
 */
+ (void)setNBServerAddress:(NSString *)serverAddress
                portNumber:(NSString *)portNumber
                  lockData:(NSString *)lockData
                   success:(TTGetElectricQuantitySucceedBlock)success
                   failure:(TTFailedBlock)failure;

#pragma mark - Ekey

/**
 Lock or unlock

 @param controlAction The controlAction
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is unlock or lock
 @param failure A block invoked when the operation fails
 */
+ (void)controlLockWithControlAction:(TTControlAction)controlAction
                            lockData:(NSString *)lockData
                             success:(TTControlLockSucceedBlock)success
                             failure:(TTFailedBlock)failure;


/**
 Reset all eKey but admin eKey

 @param lockData The lock data string used to operate lock
 @param success A block invoked when eKey is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetEkeyWithLockData:(NSString *)lockData
                      success:(TTResetEkeySucceedBlock)success
                      failure:(TTFailedBlock)failure;

#pragma mark - Passcode

/**
 Create custom passcode

 @param passcode The passcode is limited to 4 - 9 digits
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is created
 @param failure A block invoked when the operation fails
 */
+ (void)createCustomPasscode:(NSString *)passcode
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure;


/**
 Modify admin passcode

 @param adminPasscode The new admin passcode is limited to 4 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when admin passcode is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyAdminPasscode:(NSString *)adminPasscode
                   lockData:(NSString *)lockData
                    success:(TTSucceedBlock)success
                    failure:(TTFailedBlock)failure;


/**
 Get admin passcode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when admin passcode is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAdminPasscodeWithLockData:(NSString *)lockData
                             success:(TTGetAdminPasscodeSucceedBlock)success
                             failure:(TTFailedBlock)failure;


/**
 Set admin erase passcode

 @param passcode  The erase passcode can delete all used passcode and it also limited to 7 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when erase passcode is set
 @param failure A block invoked when the operation fails
 */
+ (void)setAdminErasePasscode:(NSString *)passcode
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;


/**
 Reset passcode then all passcode will be invalid

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetPasscodesWithLockData:(NSString *)lockData
                           success:(TTResetPasscodesSucceedBlock)success
                           failure:(TTFailedBlock)failure;


/**
 Get passcode data

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode data is got
 @param failure A block invoked when the operation fails
 */
+ (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData
                                          success:(TTGetPasscodeVerificationParamsSucceedBlock)success
                                          failure:(TTFailedBlock)failure;


/**
 Recover passcode

 @param passcode Old Passcode
 @param newPasscode New Passcode is limited to 4 - 9 digits
 @param passcodeType Passcode Type
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired. If passwordType != TTPasscodeTypePeriod ,can set 0
 @param cycleType Cycle Type , if passwordType != TTPasscodeTypeCycle ,can set any value
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverPasscode:(NSString *)passcode
            newPasscode:(NSString *)newPasscode
           passcodeType:(TTPasscodeType)passcodeType
              startDate:(long long)startDate
                endDate:(long long)endDate
              cycleType:(int)cycleType
               lockData:(NSString *)lockData
                success:(TTSucceedBlock)success
                failure:(TTFailedBlock)failure;



/**
 Get all valid passcode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid passcode is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidPasscodesWithLockData:(NSString *)lockData
                                 success:(TTGetLockAllPasscodeSucceedBlock)success
                                 failure:(TTFailedBlock)failure;

/**
 Delete passcode

 @param passcode The passcode you want to delete it. Passcode is limited to 4 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deletePasscode:(NSString *)passcode
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure;

/**
 Moddify passcode or passcode valid date

 @param passcode The passcode need to be modified
 @param newPasscode The new passcode is used to replace first passcode. If you just want to modify valid date, the new passcode should be nil. New passcode is limited to 4 - 9 digits
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyPasscode:(NSString *)passcode
           newPasscode:(NSString *)newPasscode
             startDate:(long long)startDate
               endDate:(long long)endDate
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure;

#pragma mark - IC card

/**
 Add new IC card
 
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when card is adding
 @param success A block invoked when card is added
 @param failure A block invoked when the operation fails
 */
+ (void)addICCardStartDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                  progress:(TTAddICProgressBlock)progress
                   success:(TTAddICSucceedBlock)success
                   failure:(TTFailedBlock)failure;


/**
 Recover IC card

 @param cardNumber The card number you want to recover
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverICCardNumber:(NSString *)cardNumber
                  startDate:(long long)startDate
                    endDate:(long long)endDate
                   lockData:(NSString *)lockData
                    success:(TTAddICSucceedBlock)success
                    failure:(TTFailedBlock)failure;


/**
 Modify IC card valid date

 @param cardNumber The card number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyICCardValidityPeriodWithCardNumber:(NSString *)cardNumber
                                       startDate:(long long)startDate
                                         endDate:(long long)endDate
                                        lockData:(NSString *)lockData
                                         success:(TTSucceedBlock)success
                                         failure:(TTFailedBlock)failure;


/**
 Delete IC card

 @param cardNumber The card number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deleteICCardNumber:(NSString *)cardNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;

/**
 Report Loss Card

 @param cardNumber The card number you want to report loss
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is reported loss
 @param failure A block invoked when the operation fails
 */
+ (void)reportLossCard:(NSString *)cardNumber
			  lockData:(NSString *)lockData
			   success:(TTSucceedBlock)success
			   failure:(TTFailedBlock)failure;

/**
 Clear all IC cards

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all cards are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearAllICCardsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;


/**
 Get all valid IC cards

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid cards are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidICCardsWithLockData:(NSString *)lockData
                               success:(TTGetAllICCardsSucceedBlock)success
                               failure:(TTFailedBlock)failure;


/**
 Add cyclic IC card

 @param cyclicConfig weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when card is adding
 @param success A block invoked when card is added
 @param failure A block invoked when the operation fails
 */
+ (void)addICCardWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
						startDate:(long long)startDate
						  endDate:(long long)endDate
						 lockData:(NSString *)lockData
						 progress:(TTAddICProgressBlock)progress
						  success:(TTAddICSucceedBlock)success
						  failure:(TTFailedBlock)failure;

/**
 Modify cyclic IC card valid date

 @param cyclicConfig weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param cardNumber The card number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyICCardValidityPeriodWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
										cardNumber:(NSString *)cardNumber
										 startDate:(long long)startDate
										   endDate:(long long)endDate
										  lockData:(NSString *)lockData
										   success:(TTSucceedBlock)success
										   failure:(TTFailedBlock)failure;

#pragma mark - Fingerprint

/**
 Add new fingerprint by pressing finger on the lock

 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when card is adding
  currentCount == -1 || totalCount  == -1 means unknown,continue adding.
 @param success A block invoked when fingerprint is added
 @param failure A block invoked when the operation fails
 */
+ (void)addFingerprintStartDate:(long long)startDate
                        endDate:(long long)endDate
                       lockData:(NSString *)lockData
                       progress:(TTAddFingerprintProgressBlock)progress
                        success:(TTAddFingerprintSucceedBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Add new fingerprint by  writing fingerprint data to the lock

 @param fingerprintData The fingerprint data is obtained by the fingerprint collector
 @param tempFingerprintNumber tempFingerprintNumber
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is added
 @param failure A block invoked when the operation fails
 */
+ (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString *)tempFingerprintNumber
                   startDate:(long long)startDate
                     endData:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTAddFingerprintSucceedBlock)success
                     failure:(TTFailedBlock)failure;


/**
 Recover Fingerprint

 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param fingerprintNum The fingerprint number you want to recover
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData
                                success:(TTAddFingerprintSucceedBlock)success
                                failure:(TTFailedBlock)failure;


/**
 Modify fingerprint valid date

 @param fingerprintNumber The fingerprint number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyFingerprintValidityPeriodWithFingerprintNumber:(NSString *)fingerprintNumber
                                                   startDate:(long long)startDate
                                                     endDate:(long long)endDate
                                                    lockData:(NSString *)lockData
                                                     success:(TTSucceedBlock)success
                                                     failure:(TTFailedBlock)failure;


/**
 Delete fingerprint

 @param fingerprintNumber The fingerprint number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is modified
 @param failure A block invoked when the operation fails
 */
+ (void)deleteFingerprintNumber:(NSString *)fingerprintNumber
                       lockData:(NSString *)lockData
                        success:(TTSucceedBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Clear all fingerprints

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all fingerprints are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearAllFingerprintsWithLockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure;


/**
 Get all valid fingerprint numbers

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid fingerprint numbers  are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidFingerprintsWithLockData:(NSString *)lockData
                                    success:(TTGetAllFingerprintsSucceedBlock)success
                                    failure:(TTFailedBlock)failure;

/**
 Add cyclic fingerprint by pressing finger on the lock

 @param cyclicConfig weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when card is adding
  currentCount == -1 || totalCount  == -1 means unknown,continue adding.
 @param success A block invoked when fingerprint is added
 @param failure A block invoked when the operation fails
 */
+ (void)addFingerprintWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
							 startDate:(long long)startDate
							   endDate:(long long)endDate
							  lockData:(NSString *)lockData
							  progress:(TTAddFingerprintProgressBlock)progress
							   success:(TTAddFingerprintSucceedBlock)success
							   failure:(TTFailedBlock)failure;


/**
 Modify cyclic fingerprint valid date

 @param cyclicConfig weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param fingerprintNumber The fingerprint number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyFingerprintValidityPeriodWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
									  fingerprintNumber:(NSString *)fingerprintNumber
											  startDate:(long long)startDate
												endDate:(long long)endDate
											   lockData:(NSString *)lockData
												success:(TTSucceedBlock)success
												failure:(TTFailedBlock)failure;


#pragma mark - Lift

/**
Activate Lift Floors
 
@param floors lift floors,connect with comma symbol,such as: @"1,2,3"
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)activateLiftFloors:(NSString *)floors
				  lockData:(NSString *)lockData
				   success:(TTActivateLiftSuccessdBlock)success
				   failure:(TTFailedBlock)failure;

/**
Set Lift Controlable Floors
 
@param floors lift floors,connect with comma symbol,such as: @"1,2,3"
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setLiftControlableFloors:(NSString *)floors
							lockData:(NSString *)lockData
							 success:(TTSucceedBlock)success
							 failure:(TTFailedBlock)failure;

/**
Set Lift Work Mode
 
@param workMode TTLiftWorkMode
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setLiftWorkMode:(TTLiftWorkMode)workMode
				   lockData:(NSString *)lockData
					success:(TTSucceedBlock)success
					failure:(TTFailedBlock)failure;

#pragma mark - NB Awake

/**
Set NB Awake Modes
 
@param awakeModes enum TTNBAwakeMode ,such as @[TTNBAwakeModeKeypad,TTNBAwakeModeCard,TTNBAwakeModeFingerprint]
                  awakeModes.count == 0, means no awake mode
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setNBAwakeModes:(NSArray <NSNumber *> *)awakeModes
			   lockData:(NSString *)lockData
				success:(TTSucceedBlock)success
				failure:(TTFailedBlock)failure;

/**
Get NB Awake Modes
 
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)getNBAwakeModesWithLockData:(NSString *)lockData
							success:(TTGetNBAwakeModesSuccessdBlock)success
							failure:(TTFailedBlock)failure;

/**
Set NB Awake Modes
 
@param awakeTimes awakeTimes.count must <= 10 ,awakeTimes.count == 0 means delete awakeTimes.
                  type enum TTNBAwakeTimeType, minutes means minutes from 0 clock or time interval
                  such as,@[@{@"type":@(TTNBAwakeTimeTypePoint),@"minutes":@100}]
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)setNBAwakeTimes:(NSArray<NSDictionary *> *)awakeTimes
			   lockData:(NSString *)lockData
				success:(TTSucceedBlock)success
				failure:(TTFailedBlock)failure;

/**
Get NB Awake Times
 
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation succeeds
@param failure A block invoked when the operation fails
*/
+ (void)getNBAwakeTimesWithLockData:(NSString *)lockData
							success:(TTGetNBAwakeTimesSuccessdBlock)success
							failure:(TTFailedBlock)failure;

#pragma mark - DoorSensor
+ (void)setDoorSensorLockingSwitchOn:(BOOL)on
                            lockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;

+ (void)getDoorSensorLockingSwitchStateWithLockData:(NSString *)lockData
                                            success:(TTGetSwitchStateSuccessBlock)success
                                            failure:(TTFailedBlock)failure;

+ (void)getDoorSensorStateWithLockData:(NSString *)lockData
                               success:(TTGetSwitchStateSuccessBlock)success
                               failure:(TTFailedBlock)failure;

#pragma mark - Wristband
+ (void)setWristbandKey:(NSString *)wristbandKey passcode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

+ (void)setWristbandKey:(NSString *)wristbandKey isOpen:(BOOL)isOpen success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;
+ (void)setWristbandRssi:(int)rssi success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

#pragma mark - deprecated
+ (void)getLockSpecialValueWithLockData:(NSString *)lockData
                                success:(TTGetSpecialValueSucceedBlock)success
                                failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,Use getLockFeatureValue")));

+ (void)setLockFreezeStateWithOn:(BOOL)on
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,setLockConfig")));

+ (void)getLockFreezeStateWithLockData:(NSString *)lockData
                               success:(TTGetLockConfigSuccessBlock)success
                               failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,getLockConfig")));

+ (void)setAudioSwitchOn:(BOOL)on
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                 failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,setLockConfig")));

+ (void)getAudioSwitchWithLockData:(NSString *)lockData
                           success:(TTGetLockConfigSuccessBlock)success
                           failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,getLockConfig")));

+ (void)setPasscodeVisibleSwitchOn:(BOOL)on
                          lockData:(NSString *)lockData
                           success:(TTSucceedBlock)success
                           failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,setLockConfig")));

+ (void)getPasscodeVisibleSwitchWithLockData:(NSString *)lockData
                                     success:(TTGetLockConfigSuccessBlock)success
                                     failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,getLockConfig")));

+ (void)setHotelCardSectorWithSectorArr:(NSArray <NSNumber *>*)sectorArr
							   lockData:(NSString *)lockData
								success:(TTSucceedBlock)success
								failure:(TTFailedBlock)failure __attribute__((deprecated("SDK3.1.0,setHotelCardSector")));
@end

