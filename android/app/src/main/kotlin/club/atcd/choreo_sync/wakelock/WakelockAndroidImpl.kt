package club.atcd.choreo_sync.wakelock

import android.annotation.SuppressLint
import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.engine.plugins.FlutterPlugin

class WakelockAndroidImpl(private val context: Context) : FlutterPlugin,
    WakelockPigeon.WakelockAndroid {
    private val powerService: PowerManager by lazy {
        context.getSystemService(Context.POWER_SERVICE) as PowerManager
    }
    private val wakeLock: PowerManager.WakeLock by lazy {
        powerService.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "ATCDChoreoSync::ChoreoDownloader")
    }

    @SuppressLint("WakelockTimeout")
    override fun acquire(timeout: Long?) {
        timeout?.let {
            wakeLock.acquire(timeout)
        } ?: run {
            wakeLock.acquire()
        }
    }

    override fun release() {
        wakeLock.release()
    }


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        WakelockPigeon.WakelockAndroid.setup(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        WakelockPigeon.WakelockAndroid.setup(binding.binaryMessenger, null)
    }
}