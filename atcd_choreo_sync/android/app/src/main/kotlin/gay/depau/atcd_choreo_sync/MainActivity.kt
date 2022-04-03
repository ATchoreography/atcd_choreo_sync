package gay.depau.atcd_choreo_sync

import android.os.Bundle
import android.os.PersistableBundle
import gay.depau.atcd_choreo_sync.p7zip.P7ZipExtractorAndroidImpl
import gay.depau.atcd_choreo_sync.p7zip.P7ZipExtractorPigeon
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val plugin = P7ZipExtractorAndroidImpl()
        try {
            flutterEngine.plugins.add(plugin)
        } catch (e: Exception) {
            Log.e(
                "MainActivity",
                "Error registering plugin P7ZipExtractorAndroidImpl",
                e
            )
        }
    }
}
