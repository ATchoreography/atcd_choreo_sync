package club.atcd.choreo_sync

import club.atcd.choreo_sync.p7zip.P7ZipExtractorAndroidImpl
import club.atcd.choreo_sync.wakelock.WakelockAndroidImpl
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val plugins = listOf(
            P7ZipExtractorAndroidImpl(),
            WakelockAndroidImpl(context)
        )

        for (plugin in plugins) {
            try {
                flutterEngine.plugins.add(plugin)
            } catch (e: Exception) {
                Log.e(
                    "MainActivity",
                    "Error registering plugin ${plugin.javaClass.canonicalName}",
                    e
                )
            }
        }

    }
}
