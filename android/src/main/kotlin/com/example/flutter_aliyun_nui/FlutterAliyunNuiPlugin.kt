package com.example.flutter_aliyun_nui

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import com.alibaba.fastjson.JSONObject
import com.alibaba.idst.nui.AsrResult
import com.alibaba.idst.nui.Constants
import com.alibaba.idst.nui.Constants.AudioState.STATE_CLOSE
import com.alibaba.idst.nui.Constants.AudioState.STATE_OPEN
import com.alibaba.idst.nui.Constants.AudioState.STATE_PAUSE
import com.alibaba.idst.nui.INativeNuiCallback
import com.alibaba.idst.nui.KwsResult
import com.alibaba.idst.nui.NativeNui
import com.example.flutter_aliyun_nui.VadMode.TYPE_AUTO_CONTINUAL
import com.example.flutter_aliyun_nui.VadMode.TYPE_KWS
import com.example.flutter_aliyun_nui.VadMode.TYPE_KWS2PARALLEL
import com.example.flutter_aliyun_nui.VadMode.TYPE_KWS2TALK
import com.example.flutter_aliyun_nui.VadMode.TYPE_KWS_CONTINUAL
import com.example.flutter_aliyun_nui.VadMode.TYPE_ONLY_KWS
import com.example.flutter_aliyun_nui.VadMode.TYPE_P2T
import com.example.flutter_aliyun_nui.VadMode.TYPE_PARALLEL
import com.example.flutter_aliyun_nui.VadMode.TYPE_UNKNOWN
import com.example.flutter_aliyun_nui.VadMode.TYPE_VAD
import io.flutter.embedding.engine.plugins.FlutterPlugin

fun LogLevel.toNui(): Constants.LogLevel {
    return when (this) {
        LogLevel.LOG_LEVEL_VERBOSE -> Constants.LogLevel.LOG_LEVEL_VERBOSE
        LogLevel.LOG_LEVEL_DEBUG -> Constants.LogLevel.LOG_LEVEL_DEBUG
        LogLevel.LOG_LEVEL_INFO -> Constants.LogLevel.LOG_LEVEL_INFO
        LogLevel.LOG_LEVEL_WARNING -> Constants.LogLevel.LOG_LEVEL_WARNING
        LogLevel.LOG_LEVEL_ERROR -> Constants.LogLevel.LOG_LEVEL_ERROR
        LogLevel.LOG_LEVEL_NONE -> Constants.LogLevel.LOG_LEVEL_NONE
    }
}

fun VadMode.toNui(): Constants.VadMode {
    return when (this) {
        TYPE_UNKNOWN -> Constants.VadMode.TYPE_UNKNOWN
        TYPE_VAD -> Constants.VadMode.TYPE_VAD
        TYPE_P2T -> Constants.VadMode.TYPE_P2T
        TYPE_KWS -> Constants.VadMode.TYPE_KWS
        TYPE_PARALLEL -> Constants.VadMode.TYPE_PARALLEL
        TYPE_KWS2PARALLEL -> Constants.VadMode.TYPE_KWS2PARALLEL
        TYPE_AUTO_CONTINUAL -> Constants.VadMode.TYPE_AUTO_CONTINUAL
        TYPE_KWS_CONTINUAL -> Constants.VadMode.TYPE_KWS_CONTINUAL
        TYPE_KWS2TALK -> Constants.VadMode.TYPE_KWS2TALK
        TYPE_ONLY_KWS -> Constants.VadMode.TYPE_ONLY_KWS
    }
}

/** FlutterAliyunNuiPlugin */
class FlutterAliyunNuiPlugin : FlutterPlugin, INativeNuiCallback , FlutterAliyunNuiHostApi{
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var callback: FlutterAliyunNuiCallback? = null

    var mAudioRecorder: AudioRecord?=null
    val nuiInstance: NativeNui by lazy {
        NativeNui()
    }

    companion object{

        const val SAMPLE_RATE: Int = 16000
        const val WAVE_FARM_SIZE: Int = 20 * 2 * 1 * SAMPLE_RATE / 1000 //20ms audio for 16k/16bit/mono
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding

        // 设置 HostApi - 处理 Flutter 调用 Native 的方法
        FlutterAliyunNuiHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        // 创建 Callback - 用于 Native 回调 Flutter
        callback = FlutterAliyunNuiCallback(flutterPluginBinding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        FlutterAliyunNuiHostApi.setUp(binding.binaryMessenger, null)
        callback = null
        flutterPluginBinding = null
    }

    // ========== 实现 FlutterAliyunNuiHostApi 接口 ==========

    override fun initialize(params: Map<String, Any?>, saveLog: Boolean, logLevel: LogLevel): Long {
        print("参数 initialize - ${JSONObject.toJSONString(params)}")
        return nuiInstance.initialize(this, JSONObject.toJSONString(params), logLevel.toNui())
            .toLong()
    }

    override fun setParams(params: Map<String, Any?>): Long {
        print("参数 setParams - ${JSONObject.toJSONString(params)}")
        return nuiInstance.setParams(JSONObject.toJSONString(params)).toLong()
    }

    override fun startDialog(mode: VadMode, params: Map<String, Any?>): Long {
        if (ActivityCompat.checkSelfPermission(
                flutterPluginBinding!!.applicationContext, Manifest.permission.RECORD_AUDIO
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            if (mAudioRecorder == null) {
                //录音初始化，录音参数中格式只支持16bit/单通道，采样率支持8K/16K
                //使用者请根据实际情况选择Android设备的MediaRecorder.AudioSource
                //录音麦克风如何选择,可查看https://developer.android.google.cn/reference/android/media/MediaRecorder.AudioSource
                mAudioRecorder = AudioRecord(
                    MediaRecorder.AudioSource.DEFAULT,
                    SAMPLE_RATE,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,

                    WAVE_FARM_SIZE * 4
                )
            }
        }else{
            return -1
        }
        print("参数 startdialog - ${JSONObject.toJSONString(params)}")
        return nuiInstance.startDialog(mode.toNui(), JSONObject.toJSONString(params)).toLong()
    }

    override fun release(): Long {
        return nuiInstance.release().toLong()
    }

    override fun cancelDialog(): Long {
        return nuiInstance.cancelDialog().toLong()
    }

    override fun stopDialog(): Long {
        return nuiInstance.stopDialog().toLong()
    }

    // ========== 辅助方法 ==========

    /**
     * 获取 Callback 实例，用于回调 Flutter
     * 例如：callback?.onNuiEventCallback(event, resultCode, kwsResult, asrResult) { }
     */
    fun getCallback(): FlutterAliyunNuiCallback? = callback


    override fun onNuiEventCallback(
        p0: Constants.NuiEvent?,
        resultCode: Int,
        p2: Int,
        p3: KwsResult?,
        p4: AsrResult?
    ) {

        print("event=$p0 resultCode=$resultCode")
        postMain {
        getCallback()?.onNuiEventCallback(
            p0?.name ?: "",
            resultCode.toLong(),
            JSONObject.toJSONString(p3),
            JSONObject.toJSONString(p4)
        ) {}}

    }
    override fun onNuiNeedAudioData(buffer: ByteArray, len: Int): Int {
        val recorder = mAudioRecorder
        if (recorder?.state != AudioRecord.STATE_INITIALIZED) {
            print("audio recorder not init")
            return -1
        }
        return recorder.read(buffer, 0, len)
    }

    override fun onNuiAudioStateChanged(state: Constants.AudioState) {
        when(state){
            STATE_OPEN ->mAudioRecorder?.startRecording()
            STATE_PAUSE -> mAudioRecorder?.stop()
            STATE_CLOSE -> {
                mAudioRecorder?.release()
                mAudioRecorder = null
            }
        }
        postMain {
            getCallback()?.onNuiAudioStateChanged(when(state){
                STATE_OPEN -> AudioState.STATE_OPEN
                STATE_PAUSE -> AudioState.STATE_PAUSE
                STATE_CLOSE -> AudioState.STATE_CLOSE
            }){}
        }
    }

    override fun onNuiAudioRMSChanged(p0: Float) {

    }

    override fun onNuiVprEventCallback(p0: Constants.NuiVprEvent?) {
    }

    fun postMain(r:Runnable){

        val handler = Handler(Looper.getMainLooper())
        handler.post(r)
    }

    fun print(log: String){
        Log.e("flutter_aliyun_nui",log)
    }
}
