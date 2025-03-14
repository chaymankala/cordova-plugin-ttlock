  var exec = function exec(method, params) {
    return new Promise(function (resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, method, params);
    });
  };
  const pluginName = 'TTLockPlugin';

  var VoIP = {
    init: function init() {
      return exec("voip_init", []);
    },
    pushToken: function pushToken() {
      return exec("voip_pushToken", []);
    },
    endCall: function endCall(callId) {
      return exec("voip_endCall", [callId]);
    },
    getNotificationData: function getNotificationData(resolve,reject) {
      return cordova.exec(resolve, reject, pluginName, "voip_getNotificationData", []);
    },
    opennativesettings: function opennativesettings(urlString) {
      return exec("open_nativesettings", [urlString]);
    }
  }
  
  var Lock = {
    // Universal
    isScanning: function isScanning() {
      return exec("lock_isScanning", []);
    },
    isRemoteScanning: function isRemoteScanning() {
    return exec("remote_isScanning", []);
    },
    isDoorScanning: function isDoorScanning() {
      return exec("door_isScanning", []);
    },
    createNotificationChannel: function createNotificationChannel(channelConfig) {
      return exec("createNotificationChannel", [channelConfig]);
    },
    startScan: function startScan(resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, "lock_startScan", []);
    },
    configWifi: function configWifi(wifiname, wifipassword, lockData) {
      return exec("lock_configWifi", [wifiname, wifipassword, lockData]);
    },
    scanWiFi: function scanWiFi(resolve, reject, lockData) {
      return cordova.exec(resolve, reject, pluginName, "lock_scanWifi", [lockData]);
    },
    setlockPowerSavingMode: function setlockPowerSavingMode(direction, lockData) {
      return exec("lock_setLockPowerSavingMode", [direction, lockData]);
    },
    setlockOrientation: function setLockOrientation(direction, lockData) {
      return exec("lock_setOrientation", [direction, lockData]);
    },
    getlockOrientation: function getLockOrientation(lockData) {
      return exec("lock_getOrientation", [ lockData]);
    },
    addDoorSensor: function addDoorSensor(doorMac, lockData) {
      return exec("lock_addDoorSensor", [doorMac, lockData]);
    },
    deleteDoorSensor: function deleteDoorSensor(lockData) {
      return exec("lock_deleteDoorSensor", [lockData]);
    },
    startDoorSensorScan: function startDoorSensorScan(resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, "door_startScan", []);
    },
    startRemoteScan: function startRemoteScan(resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, "remote_startScan", []);
    },
    stopScan: function stopScan() {
      return exec("lock_stopScan", []);
    },
    stopRemoteScan: function stopRemoteScan() {
      return exec("lock_stopRemoteScan", []);
    },
    stopDoorScan: function stopDoorScan() {
      return exec("lock_stopDoorScan", []);
    },
    init: function init(lockMac, lockName, lockVersion) {
      return exec("lock_init", [lockMac, lockName, lockVersion]);
    },
    remoteInit: function remoteInit(remote, lockData, startDate, endDate) {
      return exec("remote_init", [remote, lockData, startDate, endDate]);
    },
    doorsensorInit: function doorsensorInit(door, lockData) {
      return exec("doorsensor_init", [door, lockData]);
    },
    firmwareRemote: function firmwareRemote(remote, lockData) {
      return exec("lock_firmwareRemote", [remote, lockData]);
    },
    reset: function reset(lockData, lockMac) {
      return exec("lock_reset", [lockData, lockMac]);
    },
    control: function control(controlAction, lockData, lockMac) {
      return exec("lock_control", [controlAction, lockData, lockMac]);
    },
    lockUpdateCheck: function lockUpdateCheck(resolve, reject, lockData,lockMac,lockId,clientId,access_token) {
      return cordova.exec(resolve, reject, pluginName, "lock_updateCheck", [lockData, lockMac,lockId,clientId,access_token]);
    },
    getTime: function getTime(lockData, lockMac) {
      return exec("lock_getTime", [lockData, lockMac]);
    },
    setTime: function setTime(time, lockData, lockMac) {
      return exec("lock_setTime", [time, lockData, lockMac]);
    },
    getAudioState: function getAudioState(lockData, lockMac) {
      return exec("lock_getAudioState", [lockData, lockMac]);
    },
    setAudioState: function setAudioState(audiostate, lockData, lockMac) {
      return exec("lock_setAudioState", [audiostate, lockData, lockMac]);
    },
    getRemoteUnlockSwitchState: function getRemoteUnlockSwitchState(
      lockData,
      lockMac
    ) {
      return exec("lock_getRemoteUnlockSwitchState", [lockData, lockMac]);
    },
    setRemoteUnlockSwitchState: function setRemoteUnlockSwitchState(
      lockData,
      lockMac,
      enabled
    ) {
      return exec("lock_setRemoteUnlockSwitchState", [
        lockData,
        lockMac,
        enabled
      ]);
    },
    getOperationLog: function getOperationLog(logType, lockData, lockMac) {
      return exec("lock_getOperationLog", [logType, lockData, lockMac]);
    },
    getBatteryLevel: function getBatteryLevel(lockData, lockMac) {
      return exec("lock_BatteryLevel", [lockData, lockMac]);
    },
    getAdminPasscode: function getAdminPasscode(lockData, lockMac) {
      return exec("lock_getAdminPasscode", [lockData, lockMac]);
    },
    modifyAdminPasscode: function modifyAdminPasscode(lockData, lockMac, newAdminPasscode) {
      return exec("lock_modifyAdminPasscode", [lockData, lockMac, newAdminPasscode]);
    },
    addFingerprint: function addFingerprint(
      startDate,
      endDate,
      lockData,
      lockMac,
      cb
    ) {
      if (!cb && typeof lockMac === "function") {
        cb = lockMac;
      }
  
      return cordova.exec(cb, cb, pluginName, "lock_addFingerprint", [
        startDate,
        endDate,
        lockData,
        lockMac,
      ]);
    },
    addFace: function addFace(
      startDate,
      endDate,
      lockData,
      cb
    ) {
      return cordova.exec(cb, cb, pluginName, "lock_addFace", [
        startDate,
        endDate,
        lockData,
      ]);
    },
    getAllValidFingerprints: function getAllValidFingerprints(lockData, lockMac) {
      return exec("lock_getAllValidFingerprints", [lockData, lockMac]);
      },
    getAllValidFaces: function getAllValidFaces(lockData) {
        return exec("lock_getAllValidFaces", [lockData]);
      },
    deleteRemote: function deleteRemote(
    remoteMac,
    lockData
    ){
      return exec("lock_deleteRemote", [remoteMac, lockData]);
    },
    clearRemote: function clearRemote(
    lockData
    ){
      return exec("lock_clearRemote", [lockData]);
    },
    deleteFace: function deleteFace(
      faceNum,
      lockData
    ) {
      return exec("lock_deleteFace", [faceNum, lockData]);
    },
    deleteFingerprint: function deleteFingerprint(
      fingerprintNum,
      lockData,
      lockMac
    ) {
      return exec("lock_deleteFingerprint", [fingerprintNum, lockData, lockMac]);
    },
    clearAllFingerprints: function clearAllFingerprints(lockData, lockMac) {
      return exec("lock_clearAllFingerprints", [lockData, lockMac]);
    },
    clearAllFaces: function clearAllFaces(lockData) {
      return exec("lock_clearAllFaces", [lockData]);
    },
    modifyRemoteValidityPeriod: function modifyRemoteValidityPeriod(validityInfo, remoteMac, lockData){
      return exec("lock_modifyRemoteValidityPeriod", [
      validityInfo,
      remoteMac,
      lockData
      ]);
    },
    modifyFaceValidityPeriod: function modifyFaceValidityPeriod(
      startDate,
      endDate,
      faceNumber,
      lockData
    ) {
      return exec("lock_modifyFaceValidityPeriod", [
        startDate,
        endDate,
        faceNumber,
        lockData
      ]);
    },
    modifyFingerprintValidityPeriod: function modifyFingerprintValidityPeriod(
      startDate,
      endDate,
      fingerprintNum,
      lockData,
      lockMac
    ) {
      return exec("lock_modifyFingerprintValidityPeriod", [
        startDate,
        endDate,
        fingerprintNum,
        lockData,
        lockMac,
      ]);
    },
    createCustomPasscode: function createCustomPasscode(
      passCode,
      startDate,
      endDate,
      lockData,
      lockMac
    ) {
      return exec("lock_createCustomPasscode", [
        passCode,
        startDate,
        endDate,
        lockData,
        lockMac,
      ]);
    },
    getAllValidPasscodes: function getAllValidPasscodes(lockData, lockMac) {
      return exec("lock_getAllValidPasscodes", [lockData, lockMac]);
    },
    modifyPasscode: function modifyPasscode(
      originalPassCode,
      newPassCode,
      startDate,
      endDate,
      lockData,
      lockMac
    ) {
      return exec("lock_modifyPasscode", [
        originalPassCode,
        newPassCode,
        startDate,
        endDate,
        lockData,
        lockMac,
      ]);
    },
    deletePasscode: function deletePasscode(passCode, lockData, lockMac) {
      return exec("lock_deletePasscode", [passCode, lockData, lockMac]);
    },
    resetPasscode: function resetPasscode(lockData, lockMac) {
      return exec("lock_resetPasscode", [lockData, lockMac]);
    },
    addICCard: function addICCard(startDate, endDate, lockData, lockMac, cb) {
      if (!cb && typeof lockMac === "function") {
        cb = lockMac;
      }
  
      return cordova.exec(cb, cb, pluginName, "lock_addICCard", [
        startDate,
        endDate,
        lockData,
        lockMac,
      ]);
    },
    modifyICCardValidityPeriod: function modifyICCardValidityPeriod(
      startDate,
      endDate,
      cardNum,
      lockData,
      lockMac
    ) {
      return exec("lock_modifyICCardValidityPeriod", [
        startDate,
        endDate,
        cardNum,
        lockData,
        lockMac,
      ]);
    },
    getAllValidICCards: function getAllValidICCards(lockData, lockMac) {
      return exec("lock_getAllValidICCards", [lockData, lockMac]);
    },
    deleteICCard: function deleteICCard(cardNum, lockData, lockMac) {
      return exec("lock_deleteICCard", [cardNum, lockData, lockMac]);
    },
    clearAllICCard: function clearAllICCard(lockData, lockMac) {
      return exec("lock_clearAllICCard", [lockData, lockMac]);
    },
    setAutomaticLockingPeriod: function setAutomaticLockingPeriod(
      time,
      lockData,
      lockMac
    ) {
      return exec("lock_setAutomaticLockingPeriod", [time, lockData, lockMac]);
    },
    setPassageMode: function setPassageMode(
    startDate,
    endDate,
    weekDays,
    lockData,
    lockMac
    ) {
    return exec("lock_setPassageMode", [startDate, endDate, weekDays, lockData, lockMac])
    },
    clearPassageMode: function clearPassageMode(
    lockData,
    lockMac
    ) {
     return exec("lock_clearPassageMode", [lockData, lockMac])
    },
    // Android
    isBLEEnabled: function isBLEEnabled() {
      return exec("lock_isBLEEnabled", []);
    },
    requestBleEnable: function requestBleEnable() {
      return exec("lock_requestBleEnable", []);
    },
    prepareBTService: function prepareBTService() {
      return exec("lock_prepareBTService", []);
    },
    stopBTService: function stopBTService() {
      return exec("lock_stopBTService", []);
    },
    // IOS
    setupBluetooth: function setupBluetooth() {
      return exec("lock_setupBluetooth", []);
    },

        //misc
    saveImageBase64ToGallery: function saveImageBase64ToGallery(base64Image){
      return exec("misc_saveImageBase64ToGallery", [base64Image]);
    },
    saveVideoToGallery: function saveVideoToGallery(base64Video){
      return exec("misc_saveVideoToGallery", [base64Video]);
    }

  };
  var Gateway = {
    isBLEEnabled: function isBLEEnabled() {
      return exec("gateway_isBLEEnabled", []);
    },
    requestBleEnable: function requestBleEnable() {
      return exec("gateway_requestBleEnable", []);
    },
    prepareBTService: function prepareBTService() {
      return exec("gateway_prepareBTService", []);
    },
    stopBTService: function stopBTService() {
      return exec("gateway_stopBTService", []);
    },
    startScan: function startScan(resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, "gateway_startScan", []);
    },
    stopScan: function stopScan() {
      return exec("gateway_stopScan", []);
    },
    connect: function connect(gatewayMac) {
      return exec("gateway_connect", [gatewayMac]);
    },
    disconnect: function disconnect(gatewayMac) {
      return exec("gateway_disconnect", [gatewayMac]);
    },
    init: function init(gatewayMac, uid, userPwd, ssid, wifiPwd) {
      return exec("gateway_init", [gatewayMac, uid, userPwd, ssid, wifiPwd]);
    },
    scanWiFi: function scanWiFi(gatewayMac, resolve, reject) {
      return cordova.exec(resolve, reject, pluginName, "gateway_scanWiFi", [
        gatewayMac,
      ]);
    },
    upgrade: function upgrade(gatewayMac) {
      return exec("gateway_upgrade", [gatewayMac]);
    },
  };
  var TTLock = {
    Lock: Lock,
    Gateway: Gateway,
    VoIP: VoIP,
  };
  
  if (navigator.platform === "iPhone") {
    TTLock.ControlAction = {
      Unlock: 1,
      Lock: 2,
    };
  } else {
    TTLock.ControlAction = {
      Unlock: 3,
      Lock: 6,
    };
  }
  
  TTLock.BluetoothState = {
    Unknown: 0,
    Resetting: 1,
    Unsupported: 2,
    Unauthorized: 3,
    PoweredOff: 4,
    PoweredOn: 5,
  };
  
  if (navigator.platform === "iPhone") {
    TTLock.LogType = {
      All: 2,
      New: 1,
    };
  } else {
    TTLock.LogType = {
      All: 1,
      New: 0,
    };
  }
  
  TTLock.LogRecordType = {
    MobileUnlock: 1,
    ServerUnlock: 3,
    KeyboardPasswordUnlock: 4,
    KeyboardModifyPassword: 5,
    KeyboardRemoveSinglePassword: 6,
    ErrorPasswordUnlock: 7,
    KeyboardRemoveAllPasswords: 8,
    KeyboardPasswordKicked: 9,
    UseDeleteCode: 10,
    PasscodeExpired: 11,
    SpaceInsufficient: 12,
    PasscodeInBlacklist: 13,
    DoorReboot: 14,
    AddIC: 15,
    ClearIC: 16,
    ICUnlock: 17,
    DeleteIC: 18,
    ICUnlockFailed: 25,
    BleLock: 26,
    KeyUnlock: 27,
    GatewayUnlock: 28,
    IllegalUnlock: 29,
    DoorSensorLock: 30,
    DoorSensorUnlock: 31,
    DoorGoOut: 32,
  };
  
  module.exports = TTLock;  
