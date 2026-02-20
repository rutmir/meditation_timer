// package pro.optima.meditimer
// 
// import android.os.Build
// import android.os.Bundle
// import androidx.core.view.WindowCompat
// import io.flutter.embedding.android.FlutterActivity
// 
// class MainActivity : FlutterActivity() {
//   override fun onCreate(savedInstanceState: Bundle?) {
//     // Aligns the Flutter view vertically with the window.
//     WindowCompat.setDecorFitsSystemWindows(getWindow(), false)
// 
//     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//       // Disable the Android splash screen fade out animation to avoid
//       // a flicker before the similar frame is drawn in Flutter.
//       splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
//     }
// 
//     super.onCreate(savedInstanceState)
//   }
// }

package pro.optima.meditimer

import androidx.annotation.NonNull
import android.content.Context
import android.content.Intent
import android.app.NotificationManager 
import android.media.AudioManager
import android.provider.Settings
import android.service.voice.VoiceInteractionSession
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val mNotificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val mAudioManager: AudioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_SERVICE_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "INTERRUPTION_FILTER_ALL" -> onMethodCallSetInterruptionFilter(call, result, mNotificationManager, NotificationManager.INTERRUPTION_FILTER_ALL)
                    "INTERRUPTION_FILTER_NONE" -> onMethodCallSetInterruptionFilter(call, result, mNotificationManager, NotificationManager.INTERRUPTION_FILTER_NONE)
                    "INTERRUPTION_FILTER_ALARMS" -> onMethodCallSetInterruptionFilter(call, result, mNotificationManager, NotificationManager.INTERRUPTION_FILTER_ALARMS)
                    "INTERRUPTION_FILTER_PRIORITY" -> onMethodCallSetInterruptionFilter(call, result, mNotificationManager, NotificationManager.INTERRUPTION_FILTER_PRIORITY)
                    "INTERRUPTION_FILTER_STATUS" -> onMethodCallInterruptionFilterStatus(call, result, mNotificationManager)
                    // "IS_POLICY_ACCESS_GRANTED" -> onMethodCallIsPolicyAccessGranted(call, result, mNotificationManager)
                    // "ASK_POLICY_ACCESS_GRANTED" -> onMethodCallAskPolicyAccessGranted(call, result, mNotificationManager)
                    else  -> {
                      result.notImplemented();
                    }
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_SERVICE_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "RINGER_MODE_NORMAL" -> onMethodCallSetRingerMode(call, result, mAudioManager, AudioManager.RINGER_MODE_NORMAL)
                    "RINGER_MODE_SILENT" -> onMethodCallSetRingerMode(call, result, mAudioManager, AudioManager.RINGER_MODE_SILENT)
                    "RINGER_MODE_VIBRATE" -> onMethodCallSetRingerMode(call, result, mAudioManager, AudioManager.RINGER_MODE_VIBRATE)
                    "RINGER_MODE" -> onMethodCallGetRingerMode(call, result, mAudioManager)
                    else  -> {
                      result.notImplemented();
                    }
                }
            }
        }
    }

    private fun onMethodCallSetInterruptionFilter(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mNotificationManager: NotificationManager, filter: Int) {
        if (mNotificationManager == null) {
            result.error("not-found-notification-manager", "Not found 'Notification Manager'.", null)
            return
        }

        try {
            mNotificationManager.setInterruptionFilter(filter)
            result.success(true);
        } catch (e: Exception) {
            result.error("not-able-set-interruption-filter", "Not able set interruption filter: $filter.", e.message)
        }
    }

    // private fun onMethodCallIsPolicyAccessGranted(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mNotificationManager: NotificationManager) {
    //     if (mNotificationManager == null) {
    //         result.error("not-found-notification-manager", "Not found 'Notification Manager'.", null)
    //         return
    //     }
    // 
    //     try {
    //         result.success(mNotificationManager.isNotificationPolicyAccessGranted());
    //     } catch (e: Exception) {
    //         result.error("not-able-set-interruption-filter", "Not able get IsPolicyAccessGranted.", e.message)
    //     }
    // }

    // private fun onMethodCallAskPolicyAccessGranted(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mNotificationManager: NotificationManager) {
    //     if (mNotificationManager == null) {
    //         result.error("not-found-notification-manager", "Not found 'Notification Manager'.", null)
    //         return
    //     }
    // 
    //     try {
    //         // val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
    //         // val intent = Intent("android.settings.ZEN_MODE_SETTINGS")
    //         // startActivityForResult(intent, 1001011) // Use a unique request code
    //         // startActivity(intent)
    // 
    //         val intent = Intent(Settings.ACTION_ZEN_MODE_PRIORITY_SETTINGS)
    //         intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    // 
    //         // val intent = Intent("android.settings.VOICE_CONTROL_DO_NOT_DISTURB_MODE")
    //         // var vis = VoiceInteractionSession(this.context)
    //         // vis.startVoiceActivity(intent)
    //         
    //         startActivity(intent)
    //         result.success(true);
    //     } catch (e: Exception) {
    //         result.error("not-able-set-interruption-filter", "Not able get AskPolicyAccessGranted.", e.message)
    //     }
    // }

    private fun onMethodCallInterruptionFilterStatus(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mNotificationManager: NotificationManager) {
        if (mNotificationManager == null) {
            result.error("not-found-notification-manager", "Not found 'Notification Manager'.", null)
            return
        }

        try {
            val status: Int = mNotificationManager.getCurrentInterruptionFilter()
            result.success(status);
        } catch (e: Exception) {
            result.error("not-able-set-interruption-filter", "Not able get InterruptionFilterStatus.", e.message)
        }
    }

    private fun onMethodCallGetRingerMode(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mAudioManager: AudioManager) {
        if (mAudioManager == null) {
            result.error("not-found-audio-manager", "Not found 'Audio Manager'.", null)
            return
        }

        try {
            val mode: Int = mAudioManager.getRingerMode()
            result.success(mode);
        } catch (e: Exception) {
            result.error("not-able-get-ringer-mode", "Not able get RingerMode.", e.message)
        }
    }

    private fun onMethodCallSetRingerMode(@Suppress("UNUSED_PARAMETER") call: MethodCall, result: MethodChannel.Result, mAudioManager: AudioManager, mode: Int) {
        if (mAudioManager == null) {
            result.error("not-found-audio-manager", "Not found 'Audio Manager'.", null)
            return
        }

        try {
            mAudioManager.setRingerMode(mode)
            result.success(true);
        } catch (e: Exception) {
            result.error("not-able-set-ringer-mode", "Not able set ringer mode: $mode.", e.message)
        }
    }

    companion object {
      const val NOTIFICATION_SERVICE_CHANNEL = "pro.optima.meditimer/notification_service";
      const val AUDIO_SERVICE_CHANNEL = "pro.optima.meditimer/audio_service";
    }
}