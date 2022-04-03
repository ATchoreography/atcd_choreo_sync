package gay.depau.atcd_choreo_sync.p7zip

import com.hzy.lib7z.ErrorCode
import com.hzy.lib7z.IExtractCallback
import com.hzy.lib7z.Z7Extractor
import io.flutter.embedding.engine.plugins.FlutterPlugin

class P7ZipExtractorAndroidImpl : FlutterPlugin, P7ZipExtractorPigeon.P7ZipExtractorAndroid {
    override fun extractArchive(archivePath: String, outputDir: String): MutableList<String> {
        val result = mutableSetOf<String>()

        val status = Z7Extractor.extractFile(archivePath, outputDir, object : IExtractCallback {
            override fun onProgress(name: String, size: Long) {
                result.add(name)
            }

            override fun onError(errorCode: Int, message: String?) {
                print("p7zip error [${errorCode}]: $message")
            }

            override fun onStart() {}
            override fun onGetFileNum(fileNum: Int) {}
            override fun onSucceed() {}
        })

        if (status != ErrorCode.SZ_OK)
            throw IllegalArgumentException("p7zip returned an error: $status")

        return result.toMutableList()
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        P7ZipExtractorPigeon.P7ZipExtractorAndroid.setup(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        P7ZipExtractorPigeon.P7ZipExtractorAndroid.setup(binding.binaryMessenger, null)
    }
}