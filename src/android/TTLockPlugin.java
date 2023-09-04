// (c) 2014-2016 Don Coleman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// (c) 2014-2016 Don Coleman
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.apartx.ttlock;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import androidx.core.content.ContextCompat;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Build;

import android.provider.Settings;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

// import android.support.v4.content.ContextCompat;
import com.google.gson.Gson;

import java.util.*;
import java.lang.*;

import com.ttlock.bl.sdk.api.TTLockClient;
import com.ttlock.bl.sdk.api.ExtendedBluetoothDevice;
import com.ttlock.bl.sdk.api.LockDfuClient;
import com.ttlock.bl.sdk.callback.ClearPassageModeCallback;
import com.ttlock.bl.sdk.callback.SetPassageModeCallback;
import com.ttlock.bl.sdk.entity.LockError;
import com.ttlock.bl.sdk.constant.ControlAction;
import com.ttlock.bl.sdk.entity.ControlLockResult;
import com.ttlock.bl.sdk.constant.Feature;
import com.ttlock.bl.sdk.entity.PassageModeConfig;
import com.ttlock.bl.sdk.entity.PassageModeType;
import com.ttlock.bl.sdk.util.GsonUtil;
import com.ttlock.bl.sdk.util.SpecialValueUtil;
import com.ttlock.bl.sdk.util.FeatureValueUtil;

import com.ttlock.bl.sdk.callback.DfuCallback;
import com.ttlock.bl.sdk.callback.ScanLockCallback;
import com.ttlock.bl.sdk.callback.InitLockCallback;
import com.ttlock.bl.sdk.callback.ResetLockCallback;
import com.ttlock.bl.sdk.callback.ControlLockCallback;
import com.ttlock.bl.sdk.callback.GetLockTimeCallback;
import com.ttlock.bl.sdk.callback.SetLockTimeCallback;
import com.ttlock.bl.sdk.callback.GetLockMuteModeStateCallback;
import com.ttlock.bl.sdk.callback.SetLockMuteModeCallback;
import com.ttlock.bl.sdk.callback.SetRemoteUnlockSwitchCallback;
import com.ttlock.bl.sdk.callback.GetRemoteUnlockStateCallback;
import com.ttlock.bl.sdk.callback.AddFingerprintCallback;
import com.ttlock.bl.sdk.callback.GetAllValidFingerprintCallback;
import com.ttlock.bl.sdk.callback.DeleteFingerprintCallback;
import com.ttlock.bl.sdk.callback.ClearAllFingerprintCallback;
import com.ttlock.bl.sdk.callback.ModifyFingerprintPeriodCallback;
import com.ttlock.bl.sdk.callback.GetOperationLogCallback;
import com.ttlock.bl.sdk.callback.GetBatteryLevelCallback;
import com.ttlock.bl.sdk.callback.CreateCustomPasscodeCallback;
import com.ttlock.bl.sdk.callback.GetAllValidPasscodeCallback;
import com.ttlock.bl.sdk.callback.ModifyPasscodeCallback;
import com.ttlock.bl.sdk.callback.DeletePasscodeCallback;
import com.ttlock.bl.sdk.callback.ResetPasscodeCallback;
import com.ttlock.bl.sdk.callback.AddICCardCallback;
import com.ttlock.bl.sdk.callback.ModifyICCardPeriodCallback;
import com.ttlock.bl.sdk.callback.GetAllValidICCardCallback;
import com.ttlock.bl.sdk.callback.DeleteICCardCallback;
import com.ttlock.bl.sdk.callback.ClearAllICCardCallback;
import com.ttlock.bl.sdk.callback.SetAutoLockingPeriodCallback;

import com.ttlock.bl.sdk.gateway.api.GatewayClient;
import com.ttlock.bl.sdk.gateway.callback.InitGatewayCallback;
import com.ttlock.bl.sdk.gateway.callback.ScanGatewayCallback;
import com.ttlock.bl.sdk.gateway.callback.ScanWiFiByGatewayCallback;
import com.ttlock.bl.sdk.gateway.callback.ConnectCallback;

import com.ttlock.bl.sdk.gateway.model.ConfigureGatewayInfo;
import com.ttlock.bl.sdk.gateway.model.DeviceInfo;
import com.ttlock.bl.sdk.gateway.model.GatewayError;
import com.ttlock.bl.sdk.gateway.model.WiFi;

import com.apartx.ttlock.ChannelCreator;

public class TTLockPlugin extends CordovaPlugin {
  private TTLockClient mTTLockClient = TTLockClient.getDefault();
  private LockDfuClient mLockDfuClient = LockDfuClient.getDefault();
  private GatewayClient mGatewayClient = GatewayClient.getDefault();
  protected Context context;

  // callbacks
  CallbackContext discoverCallback;
  private CallbackContext enableBluetoothCallback;

  private static final String TAG = "TTLockPlugin";

  // Android 23 requires new permissions for BluetoothLeScanner.startScan()
  private CallbackContext permissionCallback;

  private Boolean mIsScanning = false;

  private Map<String, ExtendedBluetoothDevice> mDevicesCache = new HashMap<String, ExtendedBluetoothDevice>();

  public void onDestroy() {

  }

  public void onReset() {

  }

  @Override
  public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    LOG.d(TAG, "action = %s", action);

    boolean validAction = true;
    java.lang.reflect.Method method;

    try {
      // if(action=="createNotificationChannel"){
      // createNotificationChannel(args,callbackContext);
      // }
      // method = this.getClass().getMethod(action);
      method = TTLockPlugin.class.getMethod(action, CordovaArgs.class, CallbackContext.class);
    } catch (java.lang.SecurityException e) {
      LOG.d(TAG, "getMethod SecurityException = %s", e.toString());
      return false;

    } catch (java.lang.NoSuchMethodException e) {
      LOG.d(TAG, "getMethod NoSuchMethodException = %s", e.toString());
      return false;
    }

    try {
      method.invoke(this, args, callbackContext);
    } catch (java.lang.IllegalArgumentException e) {
      callbackContext.error(e.toString());
    } catch (java.lang.IllegalAccessException e) {
      callbackContext.error(e.toString());
    } catch (java.lang.reflect.InvocationTargetException e) {
      callbackContext.error(e.toString());
    }
    return true;
  }

  public void lock_isScanning(CordovaArgs args, CallbackContext callbackContext) {
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, mIsScanning);
    callbackContext.sendPluginResult(pluginResult);
  }

  public void createNotificationChannel(CordovaArgs args, CallbackContext callbackContext) {
    cordova.getActivity().runOnUiThread(new Runnable() {
      public void run() {
        new ChannelCreator(getContext()).createNotificationChannel(callbackContext, args);
      }
    });
  }

  public void lock_isBLEEnabled(CordovaArgs args, CallbackContext callbackContext) {
    boolean isBLEEnabled = mTTLockClient.isBLEEnabled(cordova.getActivity().getApplicationContext());
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, isBLEEnabled);
    callbackContext.sendPluginResult(pluginResult);
  }

  public void lock_requestBleEnable(CordovaArgs args, CallbackContext callbackContext) {
    mTTLockClient.requestBleEnable(cordova.getActivity());
    callbackContext.success();
  }

  public void lock_prepareBTService(CordovaArgs args, CallbackContext callbackContext) {
    mTTLockClient.prepareBTService(cordova.getActivity().getApplicationContext());
    callbackContext.success();
  }

  public void lock_stopBTService(CordovaArgs args, CallbackContext callbackContext) {
    mTTLockClient.stopBTService();
    callbackContext.success();
  }

  public void lock_startScan(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    if (mIsScanning) {
      callbackContext.error("Already scanning");
      return;
    }

    mIsScanning = true;

    mTTLockClient.startScanLock(new ScanLockCallback() {
      @Override
      public void onScanLockSuccess(ExtendedBluetoothDevice device) {
        LOG.d(TAG, "ScanLockCallback device found = %s", device.getName());

        // Save device in cache
        mDevicesCache.put(device.getAddress(), device);

        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("name", device.getName());
          deviceObj.put("address", device.getAddress());
          deviceObj.put("version", device.getLockVersionJson());
          deviceObj.put("isSettingMode", device.isSettingMode());
          deviceObj.put("electricQuantity", device.getBatteryCapacity());
          deviceObj.put("rssi", device.getRssi());
        } catch (Exception e) {
          LOG.d(TAG, "startScanLock error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        mIsScanning = false;
        LOG.d(TAG, "ScanLockCallback device found error = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_updateCheck (CordovaArgs args, CallbackContext callbackContext) throws
    JSONException {
      String lockData = args.getString(0);
      String lockMac = args.getString(1);
      Integer lockId = args.getInt(2);
      String clientId = args.getString(3);
      String access_token = args.getString(4);

      mLockDfuClient.startDfu(cordova.getActivity().getApplicationContext(), clientId, access_token, lockId, lockData,
              lockMac, new DfuCallback() {
                @Override
                public void onDfuSuccess(String deviceAddress) {
                  JSONObject deviceObj = new JSONObject();
                  try {
                    deviceObj.put("success", 1);
                  } catch (Exception e) {
                    LOG.d(TAG, "startDfu error = %s", e.toString());
                  }
                  PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
                  callbackContext.sendPluginResult(pluginResult);
                }

                @Override
                public void onStatusChanged(int status) {

                }

                @Override
                public void onDfuAborted(String deviceAddress) {

                }

                @Override
                public void onProgressChanged(String deviceAddress, int percent, float speed, float avgSpeed, int currentPart,
                                              int partsTotal) {
                  LOG.d(TAG, "percent:", percent);

                  JSONObject deviceObj = new JSONObject();
                  try {
                    deviceObj.put("progress", percent);
                  } catch (Exception e) {
                    LOG.d(TAG, "startDfu error = %s", e.toString());
                  }
                  PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
                  pluginResult.setKeepCallback(true);
                  callbackContext.sendPluginResult(pluginResult);
                }

                @Override
                public void onError(int errorCode, String errorContent) {
                  LOG.d(TAG, "DfuCallback device found error = %s", errorContent);
                  callbackContext.error(errorContent);
                }

              });
    }

  public void lock_stopScan(CordovaArgs args, CallbackContext callbackContext) {
    mIsScanning = false;
    mTTLockClient.stopScanLock();
    callbackContext.success();
  }

  public void lock_init(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockMac = args.getString(0);
    String lockName = args.getString(1);

    ExtendedBluetoothDevice _device = mDevicesCache.get(lockMac);

    LOG.d(TAG, "initLock = %s", _device.toString());
    mTTLockClient.initLock(_device, new InitLockCallback() {
      @Override
      public void onInitLockSuccess(String lockData) {
        // init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("lockData", lockData);
          deviceObj.put("specialValue", "");
          deviceObj.put("features", getLockFeatures(lockData));
        } catch (Exception e) {
          LOG.d(TAG, "initLock error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        // failed
        LOG.d(TAG, "initLock onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_reset(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    LOG.d(TAG, "lock_reset = %s", lockMac.toString());
    mTTLockClient.resetLock(lockData, lockMac, new ResetLockCallback() {
      @Override
      public void onResetLockSuccess() {
        // PluginResult pluginResult = new PluginResult(PluginResult.Status.OK,
        // deviceObj);
        // callbackContext.sendPluginResult(pluginResult);
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        // failed
        LOG.d(TAG, "initLock onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_control(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    int controlAction = args.getInt(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.controlLock(controlAction, lockData, lockMac, new ControlLockCallback() {
      @Override
      public void onControlLockSuccess(ControlLockResult controlLockResult) {
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("lockAction", controlLockResult.controlAction);
          deviceObj.put("battery", controlLockResult.battery);
          deviceObj.put("uniqueId", controlLockResult.uniqueid);
        } catch (Exception e) {
          LOG.d(TAG, "controlLock error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "controlLock onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_getAudioState(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getMuteModeState(lockData, lockMac, new GetLockMuteModeStateCallback() {
      @Override
      public void onGetMuteModeStateSuccess(boolean audioState) {
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("audiostate", audioState);
        } catch (Exception e) {
          LOG.d(TAG, "getAudioState error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getAudioState onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_setAudioState(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    Boolean enable = args.getBoolean(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.setMuteMode(enable, lockData, lockMac, new SetLockMuteModeCallback() {
      @Override
      public void onSetMuteModeSuccess(boolean enabled) {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "setLockMuteMode onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_getTime(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getLockTime(lockData, lockMac, new GetLockTimeCallback() {
      @Override
      public void onGetLockTimeSuccess(long lockTimestamp) {
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("timestamp", lockTimestamp);
        } catch (Exception e) {
          LOG.d(TAG, "getLockTime error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getLockTime onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_setTime(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    long timestamp = args.getLong(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.setLockTime(timestamp, lockData, lockMac, new SetLockTimeCallback() {
      @Override
      public void onSetTimeSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "setLockTime onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_setRemoteUnlockSwitchState(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    Boolean enabled = args.getBoolean(2);
    mTTLockClient.setRemoteUnlockSwitchState(enabled, lockData, lockMac, new SetRemoteUnlockSwitchCallback() {
      @Override
      public void onSetRemoteUnlockSwitchSuccess(String lockData) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("lockData", lockData);
          resultObj.put("specialValue", "");
        } catch (Exception e) {
          LOG.d(TAG, "setRemoteUnlockSwitchState error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "setRemoteUnlockSwitchState onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_getRemoteUnlockSwitchState(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getRemoteUnlockSwitchState(lockData, lockMac, new GetRemoteUnlockStateCallback() {
      @Override
      public void onGetRemoteUnlockSwitchStateSuccess(boolean enabled) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("remoteunlockstate", enabled);
        } catch (Exception e) {
          LOG.d(TAG, "getRemoteUnlockSwitchState error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getRemoteUnlockSwitchState onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_getOperationLog(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    int logType = args.getInt(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.getOperationLog(logType, lockData, lockMac, new GetOperationLogCallback() {
      @Override
      public void onGetLogSuccess(String logs) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("logs", logs);
        } catch (Exception e) {
          LOG.d(TAG, "getOperationLog error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getOperationLog onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void getAdminPasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    if(!FeatureValueUtil.isSupportFeature(lockData, FeatureValue.GET_ADMIN_CODE)){
       JSONObject resultObj = new JSONObject();
       resultObj.put("isSupported",false);
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
      callbackContext.sendPluginResult(pluginResult);
    } else {
       mTTLockClient.getAdminPasscode(lockData, lockMac, new GetAdminPasscodeCallback() {
         @Override
         public void onGetAdminPasscodeSuccess(String s) {
           JSONObject resultObj = new JSONObject();
           try {
             resultObj.put("isSupported", true);
             resultObj.put("adminpasscode", s);
           } catch (JSONException e) {
             LOG.d(TAG, "getAdminPassCode error = %s", e.toString());
           }
           PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
           callbackContext.sendPluginResult(pluginResult);
         }

         @Override
         public void onFail(LockError lockError) {
           LOG.d(TAG, "getAdminPassCode onFail = %s", lockError.getErrorMsg());
           callbackContext.error(makeError(lockError));
         }
       });
    }
  }

  public void modifyAdminPasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
      String lockData = args.getString(0);
      String lockMac = args.getString(1);
      String newAdminPasscode = args.getString(2);
      mTTLockClient.modifyAdminPasscode(newAdminPasscode, lockData, lockMac, new ModifyAdminPasscodeCallback() {
        @Override
        public void onModifyAdminPasscodeSuccess(String s) {
          callbackContext.success();
        }

        @Override
        public void onFail(LockError lockError) {
          LOG.d(TAG, "modifyAdminPassCode onFail = %s", lockError.getErrorMsg());
          callbackContext.error(makeError(lockError));
        }
      });
  }

  public void lock_BatteryLevel(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getBatteryLevel(lockData, lockMac, new GetBatteryLevelCallback() {
      @Override
      public void onGetBatteryLevelSuccess(int battery_level) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("battery_level", battery_level);
        } catch (Exception e) {
          LOG.d(TAG, "getBatteryLevel error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getBatteryLevel onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_addFingerprint(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    long startDate = args.getLong(0);
    long endDate = args.getLong(1);
    String lockData = args.getString(2);
    String lockMac = args.getString(3);
    mTTLockClient.addFingerprint(startDate, endDate, lockData, lockMac, new AddFingerprintCallback() {
      @Override
      public void onEnterAddMode(int totalCount) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "add");
          resultObj.put("totalCount", totalCount);
        } catch (Exception e) {
          LOG.d(TAG, "onEnterAddMode error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }
      public void onCollectFingerprint(int currentCount) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "collected");
          resultObj.put("currentCount", currentCount);
        } catch (Exception e) {
          LOG.d(TAG, "onCollectFingerprint error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }
      public void onAddFingerpintFinished(long fingerprintNumber) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "finished");
          resultObj.put("fingerprintNumber", String.valueOf(fingerprintNumber));
        } catch (Exception e) {
          LOG.d(TAG, "onAddFingerpintFinished error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "addFingerprint onFail = %s", error.getErrorMsg());
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "error");
          resultObj.put("error", error.getErrorMsg());
        } catch (Exception e) {
          LOG.d(TAG, "addFingerprint error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }
    });
  }

  public void lock_deleteFingerprint(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String fingerprintNumber = args.getString(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.deleteFingerprint(fingerprintNumber, lockData, lockMac, new DeleteFingerprintCallback() {
      @Override
      public void onDeleteFingerprintSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "deleteFingerprint onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_getAllValidFingerprints(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getAllValidFingerprints(lockData, lockMac, new GetAllValidFingerprintCallback() {
      @Override
      public void onGetAllFingerprintsSuccess(String fingerprintsJson) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("fingerprintsJson", fingerprintsJson);
        } catch (Exception e) {
          LOG.d(TAG, "onGetAllFingerprintsSuccess error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "getAllValidFingerprints onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_clearAllFingerprints(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.clearAllFingerprints(lockData, lockMac, new ClearAllFingerprintCallback() {
      @Override
      public void onClearAllFingerprintSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "deleteFingerprint onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_modifyFingerprintValidityPeriod(CordovaArgs args, CallbackContext callbackContext)
      throws JSONException {
    long startDate = args.getLong(0);
    long endDate = args.getLong(1);
    String fingerprintNumber = args.getString(2);
    String lockData = args.getString(3);
    String lockMac = args.getString(4);
    mTTLockClient.modifyFingerprintValidityPeriod(startDate, endDate, fingerprintNumber, lockData, lockMac,
        new ModifyFingerprintPeriodCallback() {
          @Override
          public void onModifyPeriodSuccess() {
            callbackContext.success();
          }

          @Override
          public void onFail(LockError error) {
            LOG.d(TAG, "deleteFingerprint onFail = %s", error.getErrorMsg());
            callbackContext.error(makeError(error));
          }
        });
  }

  public void lock_createCustomPasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String passCode = args.getString(0);
    long startDate = args.getLong(1);
    long endDate = args.getLong(2);
    String lockData = args.getString(3);
    String lockMac = args.getString(4);
    mTTLockClient.createCustomPasscode(passCode, startDate, endDate, lockData, lockMac,
        new CreateCustomPasscodeCallback() {
          @Override
          public void onCreateCustomPasscodeSuccess(String passcode) {
            callbackContext.success();
          }

          @Override
          public void onFail(LockError error) {
            LOG.d(TAG, "onCreateCustomPasscode onFail = %s", error.getErrorMsg());
            callbackContext.error(makeError(error));
          }
        });
  }

  public void lock_getAllValidPasscodes(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getAllValidPasscodes(lockData, lockMac, new GetAllValidPasscodeCallback() {
      @Override
      public void onGetAllValidPasscodeSuccess(String passcodeStr) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("passcodes", passcodeStr);
        } catch (Exception e) {
          LOG.d(TAG, "onGetAllValidPasscodeSuccess error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "onGetAllValidPasscode onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_modifyPasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String originalPassCode = args.getString(0);
    String newPassCode = args.getString(1);
    long startDate = args.getLong(2);
    long endDate = args.getLong(3);
    String lockData = args.getString(4);
    String lockMac = args.getString(5);
    mTTLockClient.modifyPasscode(originalPassCode, newPassCode, startDate, endDate, lockData, lockMac,
        new ModifyPasscodeCallback() {
          @Override
          public void onModifyPasscodeSuccess() {
            callbackContext.success();
          }

          @Override
          public void onFail(LockError error) {
            LOG.d(TAG, "onModifyPasscodeSuccess onFail = %s", error.getErrorMsg());
            callbackContext.error(makeError(error));
          }
        });
  }

  public void lock_deletePasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String passCode = args.getString(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.deletePasscode(passCode, lockData, lockMac, new DeletePasscodeCallback() {
      @Override
      public void onDeletePasscodeSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "onDeletePasscodeSuccess onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_resetPasscode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.resetPasscode(lockData, lockMac, new ResetPasscodeCallback() {
      @Override
      public void onResetPasscodeSuccess(String lockData) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("lockData", lockData);
        } catch (Exception e) {
          LOG.d(TAG, "resetPasscode error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "onResetPasscode onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_addICCard(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    long startDate = args.getLong(0);
    long endDate = args.getLong(1);
    String lockData = args.getString(2);
    String lockMac = args.getString(3);
    mTTLockClient.addICCard(startDate, endDate, lockData, lockMac, new AddICCardCallback() {
      @Override
      public void onEnterAddMode() {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "entered");
        } catch (Exception e) {
          LOG.d(TAG, "onEnterAddMode error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onAddICCardSuccess(long cardNum) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "collected");
          resultObj.put("cardNum", cardNum);
        } catch (Exception e) {
          LOG.d(TAG, "onCollectFingerprint error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "addICCard onFail = %s", error.getErrorMsg());
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("status", "error");
          resultObj.put("error", error.getErrorMsg());
        } catch (Exception e) {
          LOG.d(TAG, "addICCard error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }
    });
  }

  public void lock_modifyICCardValidityPeriod(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    long startDate = args.getLong(0);
    long endDate = args.getLong(1);
    String cardNum = args.getString(2);
    String lockData = args.getString(3);
    String lockMac = args.getString(4);
    mTTLockClient.modifyICCardValidityPeriod(startDate, endDate, cardNum, lockData, lockMac,
        new ModifyICCardPeriodCallback() {
          @Override
          public void onModifyICCardPeriodSuccess() {
            callbackContext.success();
          }

          @Override
          public void onFail(LockError error) {
            LOG.d(TAG, "modifyICCardValidityPeriod onFail = %s", error.getErrorMsg());
            callbackContext.error(makeError(error));
          }
        });
  }

  public void lock_getAllValidICCards(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getAllValidICCards(lockData, lockMac, new GetAllValidICCardCallback() {
      @Override
      public void onGetAllValidICCardSuccess(String cardDataStr) {
        JSONObject resultObj = new JSONObject();
        try {
          resultObj.put("cards", cardDataStr);
        } catch (Exception e) {
          LOG.d(TAG, "getAllValidICCards error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "modifyICCardValidityPeriod onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_deleteICCard(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String cardNum = args.getString(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.deleteICCard(cardNum, lockData, lockMac, new DeleteICCardCallback() {
      @Override
      public void onDeleteICCardSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "deleteICCard onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_clearAllICCard(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.clearAllICCard(lockData, lockMac, new ClearAllICCardCallback() {
      @Override
      public void onClearAllICCardSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "clearAllICCard onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_setAutomaticLockingPeriod(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    int autoLockPeriod = args.getInt(0);
    String lockData = args.getString(1);
    String lockMac = args.getString(2);
    mTTLockClient.setAutomaticLockingPeriod(autoLockPeriod, lockData, lockMac, new SetAutoLockingPeriodCallback() {
      @Override
      public void onSetAutoLockingPeriodSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError error) {
        LOG.d(TAG, "setAutomaticLockingPeriod onFail = %s", error.getErrorMsg());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void lock_setPassageMode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    // JSONObject modeData = args.getJSONObject(0);
    Integer startDate = args.getInt(0);
    Integer endDate = args.getInt(1);
    JSONArray weekDays = args.getJSONArray(2);
    String lockData = args.getString(3);
    String lockMac = args.getString(4);
    PassageModeConfig modeConfig = new PassageModeConfig();
    LOG.d(TAG, "setPassageMode onFail = %s");
    modeConfig.setModeType(PassageModeType.Weekly);
    int[] mCircleWeeksArray = { 1, 2, 3, 4, 5 };// modeData["weekDays"];
    modeConfig.setStartDate(startDate);// am: 8:00
    modeConfig.setEndDate(endDate);
    modeConfig.setRepeatWeekOrDays(String.valueOf(weekDays));
    mTTLockClient.setPassageMode(modeConfig, lockData, lockMac, new SetPassageModeCallback() {
      @Override
      public void onSetPassageModeSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError lockError) {
        LOG.d(TAG, "setPassageMode onFail = %s", lockError);
        callbackContext.error(makeError(lockError));
      }
    });
  }

  public void lock_clearPassageMode(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String lockData = args.getString(0);
    String lockMac = args.getString(1);
    mTTLockClient.getDefault().clearPassageMode(lockData, lockMac, new ClearPassageModeCallback() {
      @Override
      public void onClearPassageModeSuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(LockError lockError) {
        LOG.d(TAG, "clearPassageMode onFail = %s", lockError.getErrorMsg());
        callbackContext.error(makeError(lockError));
      }
    });
  }

  /*
   * Gateway API section
   */

  public void gateway_startScan(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    if (mIsScanning) {
      callbackContext.error("Already scanning");
      return;
    }

    mIsScanning = true;

    mGatewayClient.startScanGateway(new ScanGatewayCallback() {
      @Override
      public void onScanGatewaySuccess(ExtendedBluetoothDevice device) {
        LOG.d(TAG, "ScanGatewayCallback device found = %s", device.getName());

        // Save device in cache
        mDevicesCache.put(device.getAddress(), device);

        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("mAddress", device.getAddress());
          deviceObj.put("name", device.getName());
        } catch (Exception e) {
          LOG.d(TAG, "startScanGateway error = %s", e.toString());
        }
        // Gson gson = new Gson();
        // String json = gson.toJson(device);
        String json = String.valueOf(deviceObj);
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, json);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }
      @Override
      public void onScanFailed(int errorCode) {
        mIsScanning = false;
        LOG.d(TAG, "ScanGatewayCallback device found error = %i", errorCode);
        callbackContext.error(errorCode);
      }
    });
  }

  public void gateway_stopScan(CordovaArgs args, CallbackContext callbackContext) {
    mIsScanning = false;
    mGatewayClient.stopScanGateway();
    callbackContext.success();
  }

  public void gateway_connect(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String gatewayMac = args.getString(0);
    // LOG.d(TAG, "connectGateway = %s", _device.toString());
    mGatewayClient.connectGateway(gatewayMac, new ConnectCallback() {
      @Override
      public void onConnectSuccess(ExtendedBluetoothDevice device) {
        // init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("status", "connected");
        } catch (Exception e) {
          LOG.d(TAG, "connectGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onDisconnected() {
        // failed
        LOG.d(TAG, "connectGateway onDisconnected");
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("status", "disconnected");
        } catch (Exception e) {
          LOG.d(TAG, "connectGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }
    });
  }

  public void gateway_init(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    ConfigureGatewayInfo configureGatewayInfo = new ConfigureGatewayInfo();
    configureGatewayInfo.plugName = args.getString(0);
    configureGatewayInfo.uid = args.getInt(1);
    configureGatewayInfo.userPwd = args.getString(2);
    configureGatewayInfo.ssid = args.getString(3);
    configureGatewayInfo.wifiPwd = args.getString(4);

    LOG.d(TAG, "initGateway = %s", configureGatewayInfo.plugName);
    mGatewayClient.initGateway(configureGatewayInfo, new InitGatewayCallback() {
      @Override
      public void onInitGatewaySuccess(DeviceInfo deviceInfo) {
        // init success
        JSONObject deviceObj = new JSONObject();
        try {
          deviceObj.put("modelNum", deviceInfo.getModelNum());
          deviceObj.put("hardwareRevision", deviceInfo.getHardwareRevision());
          deviceObj.put("firmwareRevision", deviceInfo.getFirmwareRevision());
        } catch (Exception e) {
          LOG.d(TAG, "initGateway error = %s", e.toString());
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, deviceObj);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onFail(GatewayError error) {
        // failed
        LOG.d(TAG, "initGateway onFail = %s", error.getDescription());
        callbackContext.error(makeError(error));
      }
    });
  }

  public void gateway_scanWiFi(CordovaArgs args, CallbackContext callbackContext) throws JSONException {
    String gatewayMac = args.getString(0);

    LOG.d(TAG, "scanWiFiByGateway = %s", gatewayMac);
    mGatewayClient.scanWiFiByGateway(gatewayMac, new ScanWiFiByGatewayCallback() {
      @Override
      public void onScanWiFiByGateway(List<WiFi> wifis) {
        JSONArray resultAr = new JSONArray();
        for (WiFi wifi : wifis) {
          JSONObject resultObj = new JSONObject();
          try {
            resultObj.put("ssid", wifi.getSsid());
            resultObj.put("rssi", wifi.getRssi());
            resultAr.put(resultObj);
          } catch (Exception e) {
            LOG.d(TAG, "scanWiFiByGateway error = %s", e.toString());
          }
        }
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, resultAr);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
      }

      @Override
      public void onScanWiFiByGatewaySuccess() {
        callbackContext.success();
      }

      @Override
      public void onFail(GatewayError error) {
        LOG.d(TAG, "scanWiFiByGateway onFail = %s", error.getDescription());
        callbackContext.error(makeError(error));
      }
    });
  }

  private JSONObject getLockFeatures(String specialValue) throws JSONException {
    JSONObject features = new JSONObject();
    features.put("passcode", FeatureValueUtil.isSupportFeature(specialValue, Feature.PASSCODE));
    features.put("icCard", FeatureValueUtil.isSupportFeature(specialValue, Feature.IC));
    features.put("fingerprint", FeatureValueUtil.isSupportFeature(specialValue, Feature.FINGER_PRINT));
    features.put("autolock", FeatureValueUtil.isSupportFeature(specialValue, Feature.AUTO_LOCK));
    features.put("deletePasscode", FeatureValueUtil.isSupportFeature(specialValue, Feature.PASSCODE_WITH_DELETE_FUNCTION));
    features.put("managePasscode", FeatureValueUtil.isSupportFeature(specialValue, Feature.MODIFY_PASSCODE_FUNCTION));
    features.put("locking", FeatureValueUtil.isSupportFeature(specialValue, Feature.MANUAL_LOCK));
    features.put("passcodeVisible", FeatureValueUtil.isSupportFeature(specialValue, Feature.PASSWORD_DISPLAY_OR_HIDE));
    features.put("gatewayUnlock", FeatureValueUtil.isSupportFeature(specialValue, Feature.GATEWAY_UNLOCK));
    features.put("lockFreeze", FeatureValueUtil.isSupportFeature(specialValue, Feature.FREEZE_LOCK));
    features.put("cyclicPassword", FeatureValueUtil.isSupportFeature(specialValue, Feature.CYCLIC_PASSWORD));
    features.put("doorSensor", FeatureValueUtil.isSupportFeature(specialValue, Feature.MAGNETOMETER));
    features.put("remoteUnlockSwitch", FeatureValueUtil.isSupportFeature(specialValue, Feature.CONFIG_GATEWAY_UNLOCK));
    features.put("audioSwitch", FeatureValueUtil.isSupportFeature(specialValue, Feature.AUDIO_MANAGEMENT));
    features.put("nbIoT", FeatureValueUtil.isSupportFeature(specialValue, Feature.NB_LOCK));
    features.put("getAdminPasscode", FeatureValueUtil.isSupportFeature(specialValue, Feature.GET_ADMIN_CODE));
    features.put("hotelCard", FeatureValueUtil.isSupportFeature(specialValue, Feature.HOTEL_LOCK));
    features.put("noClock", FeatureValueUtil.isSupportFeature(specialValue, Feature.LOCK_NO_CLOCK_CHIP));
    features.put("noBroadcastInNormal", FeatureValueUtil.isSupportFeature(specialValue, Feature.CAN_NOT_CLICK_UNLOCK));
    features.put("passageMode", FeatureValueUtil.isSupportFeature(specialValue, Feature.PASSAGE_MODE));
    features.put("turnOffAutolock", FeatureValueUtil.isSupportFeature(specialValue, Feature.PASSAGE_MODE_AND_AUTO_LOCK_AND_CAN_CLOSE));
    features.put("wirelessKeypad", FeatureValueUtil.isSupportFeature(specialValue, Feature.WIRELESS_KEYBOARD));
    features.put("light", FeatureValueUtil.isSupportFeature(specialValue, Feature.LAMP));
    return features;
  }

  private JSONObject getLockFeatures_3_0_6(int specialValue) throws JSONException {
    JSONObject features = new JSONObject();
    features.put("passcode", SpecialValueUtil.isSupportFeature(specialValue, Feature.PASSCODE));
    features.put("icCard", SpecialValueUtil.isSupportFeature(specialValue, Feature.IC));
    features.put("fingerprint", SpecialValueUtil.isSupportFeature(specialValue, Feature.FINGER_PRINT));
    features.put("autolock", SpecialValueUtil.isSupportFeature(specialValue, Feature.AUTO_LOCK));
    features.put("deletePasscode", SpecialValueUtil.isSupportFeature(specialValue, Feature.PASSCODE_WITH_DELETE_FUNCTION));
    features.put("managePasscode", SpecialValueUtil.isSupportFeature(specialValue, Feature.MODIFY_PASSCODE_FUNCTION));
    features.put("locking", SpecialValueUtil.isSupportFeature(specialValue, Feature.MANUAL_LOCK));
    features.put("passcodeVisible", SpecialValueUtil.isSupportFeature(specialValue, Feature.PASSWORD_DISPLAY_OR_HIDE));
    features.put("gatewayUnlock", SpecialValueUtil.isSupportFeature(specialValue, Feature.GATEWAY_UNLOCK));
    features.put("lockFreeze", SpecialValueUtil.isSupportFeature(specialValue, Feature.FREEZE_LOCK));
    features.put("cyclicPassword", SpecialValueUtil.isSupportFeature(specialValue, Feature.CYCLIC_PASSWORD));
    features.put("doorSensor", SpecialValueUtil.isSupportFeature(specialValue, Feature.MAGNETOMETER));
    features.put("remoteUnlockSwitch", SpecialValueUtil.isSupportFeature(specialValue, Feature.CONFIG_GATEWAY_UNLOCK));
    features.put("audioSwitch", SpecialValueUtil.isSupportFeature(specialValue, Feature.AUDIO_MANAGEMENT));
    features.put("nbIoT", SpecialValueUtil.isSupportFeature(specialValue, Feature.NB_LOCK));
    features.put("getAdminPasscode", SpecialValueUtil.isSupportFeature(specialValue, Feature.GET_ADMIN_CODE));
    features.put("hotelCard", SpecialValueUtil.isSupportFeature(specialValue, Feature.HOTEL_LOCK));
    features.put("noClock", SpecialValueUtil.isSupportFeature(specialValue, Feature.LOCK_NO_CLOCK_CHIP));
    features.put("noBroadcastInNormal", SpecialValueUtil.isSupportFeature(specialValue, Feature.CAN_NOT_CLICK_UNLOCK));
    features.put("passageMode", SpecialValueUtil.isSupportFeature(specialValue, Feature.PASSAGE_MODE));
    features.put("turnOffAutolock", SpecialValueUtil.isSupportFeature(specialValue, Feature.PASSAGE_MODE_AND_AUTO_LOCK_AND_CAN_CLOSE));
    features.put("wirelessKeypad", SpecialValueUtil.isSupportFeature(specialValue, Feature.WIRELESS_KEYBOARD));
    features.put("light", SpecialValueUtil.isSupportFeature(specialValue, Feature.LAMP));
    return features;
  }

  // Helpers

  private JSONObject makeError(LockError error) {
    JSONObject resultObj = new JSONObject();
    try {
      resultObj.put("error", error.getErrorCode());
      resultObj.put("message", error.getErrorMsg());
    } catch (Exception e) {}
    return resultObj;
  }

  private JSONObject makeError(GatewayError error) {
    JSONObject resultObj = new JSONObject();
    try {
      resultObj.put("error", error.getDescription());
      resultObj.put("message", error.getDescription());
    } catch (Exception e) {}

    return resultObj;
  }

  protected Context getContext() {
    context = cordova != null ? cordova.getActivity().getBaseContext() : context;
    if (context == null) {
      throw new RuntimeException("The Android Context is required. Verify if the 'activity' or 'context' are passed by constructor");
    }

    return context;
  }
}
