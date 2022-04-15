package club.atcd.choreo_sync.apkinstaller

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import club.atcd.choreo_sync.BuildConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.File

class APKInstallerImpl(private val activity: Activity) : FlutterPlugin,
    APKInstallerPigeon.APKInstallerAndroid {

    override fun hasPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O)
            return true
        return activity.applicationContext.packageManager.canRequestPackageInstalls()
    }

    override fun launchPermissionsSettingsPage() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                activity.startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:" + activity.packageName)
                    )
                )

            } catch (e: Throwable) {
                Log.e(javaClass.name, "Unable to launch APK permission settings", e)
            }
        } else {
            Log.d(javaClass.name, "Attempted to launch APK permission settings on Android < O")
        }
    }

    override fun installApk(path: String) {
        activity.startActivity(
            Intent(Intent.ACTION_VIEW).apply {
                flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                type = "application/vnd.android.package-archive"
                data = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                    Uri.fromFile(File(path))
                } else {
                    FileProvider.getUriForFile(
                        activity,
                        BuildConfig.APPLICATION_ID + ".fileprovider",
                        File(path)
                    )
                }
            }
        )
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        APKInstallerPigeon.APKInstallerAndroid.setup(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        APKInstallerPigeon.APKInstallerAndroid.setup(binding.binaryMessenger, null)
    }
}