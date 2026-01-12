/// Flutter 阿里云 NUI SDK 插件
// ignore_for_file: constant_identifier_names

library;

import 'dart:async';
import 'dart:convert';

import 'pigeons/pigeon.dart';

// 导出 Pigeon 生成的 API
export 'pigeons/pigeon.dart';

/// 阿里云 NUI 事件回调数据
class NuiEventData {
  NuiEventData({
    required this.event,
    required this.resultCode,
    required this.kwsResult,
    required this.asrResult,
  });
  final NuiCallbackEvent event;
  final int resultCode;
  final String kwsResult;
  final AsrResult asrResult;

  @override
  String toString() {
    return 'NuiEventData(event: $event, resultCode: $resultCode, kwsResult: $kwsResult, asrResult: $asrResult)';
  }
}

/// ASR 识别结果模型
class AsrResult {
  /// 是否结束
  final bool? finish;

  /// 识别结果码
  final int? resultCode;

  /// ASR 识别文本结果
  final String? asrResult;

  /// 全部原始响应内容
  final String? allResponse;

  AsrResult({this.finish, this.resultCode, this.asrResult, this.allResponse});

  /// 从 JSON 反序列化 AsrResult
  factory AsrResult.fromJson(Map<String, dynamic> json) {
    return AsrResult(
      finish: json['finish'] as bool?,
      resultCode: json['resultCode'] as int?,
      asrResult: json['asrResult'] as String?,
      allResponse: json['allResponse'] as String?,
    );
  }
}

class ServiceType {
  static const int kServiceTypeASR = 0;
  static const int kServiceTypeTiangongAssistant = 1;
  static const int kServiceTypeDialogAssistant = 2;
  static const int kServiceTypeVirtualAssistant = 3;
  static const int kServiceTypeSpeechTranscriber = 4;
}

class ServiceMode {
  static const String fullMix = "0";
  static const String fullCloud = "1";
  static const String fullLocal = "2";
  static const String asrMix = "3";
  static const String asrCloud = "4";
  static const String asrLocal = "5";
}

enum NuiCallbackEvent {
  EVENT_VAD_START,
  EVENT_VAD_TIMEOUT,
  EVENT_VAD_END,
  EVENT_WUW,
  EVENT_WUW_TRUSTED,
  EVENT_WUW_CONFIRMED,
  EVENT_WUW_REJECTED,
  EVENT_WUW_END,
  EVENT_ASR_PARTIAL_RESULT,
  EVENT_ASR_RESULT,
  EVENT_ASR_ERROR, // 10
  EVENT_DIALOG_ERROR,
  EVENT_ONESHOT_TIMEOUT,
  EVENT_DIALOG_RESULT,
  EVENT_WUW_HINT,
  EVENT_VPR_RESULT,
  EVENT_TEXT2ACTION_DIALOG_RESULT,
  EVENT_TEXT2ACTION_ERROR,
  EVENT_ATTR_RESULT,
  EVENT_MIC_ERROR,
  EVENT_DIALOG_EX, // 20
  EVENT_WUW_ERROR,
  EVENT_BEFORE_CONNECTION,
  EVENT_SENTENCE_START,
  EVENT_SENTENCE_END,
  EVENT_SENTENCE_SEMANTICS,
  EVENT_RESULT_TRANSLATED,
  EVENT_TRANSCRIBER_COMPLETE,
  EVENT_FILE_TRANS_CONNECTED,
  EVENT_FILE_TRANS_UPLOADED,
  EVENT_FILE_TRANS_RESULT, // 30
  EVENT_FILE_TRANS_UPLOAD_PROGRESS,
  EVENT_TRANSCRIBER_STARTED,
  EVENT_ASR_STARTED,
  EVENT_FILE_TRANS_QUERY_RESULT,
  EVENT_WUW_START,
  EVENT_WUW_DATA,
  EVENT_UNKNOWN,
}

/// Flutter 阿里云 NUI SDK 主类
class FlutterAliyunNui implements FlutterAliyunNuiCallback {
  FlutterAliyunNui._();

  // 音频状态变化的流控制器
  final _audioStateController = StreamController<AudioState>.broadcast();

  // 事件回调的流控制器
  final _eventCallbackController = StreamController<NuiEventData>.broadcast();

  // 对外暴露的音频状态流
  Stream<AudioState> get audioStateStream => _audioStateController.stream;

  // 对外暴露的事件回调流
  Stream<NuiEventData> get eventCallbackStream =>
      _eventCallbackController.stream;
  static final FlutterAliyunNui _instance = FlutterAliyunNui._();
  static FlutterAliyunNui get instance => _instance;

  final FlutterAliyunNuiHostApi _hostApi = FlutterAliyunNuiHostApi();

  /// 设置事件回调
  /// 在调用其他方法之前必须先设置回调
  void setCallback(FlutterAliyunNuiCallback callback) {
    FlutterAliyunNuiCallback.setUp(callback);
  }

  /// 初始化 NUI SDK
  ///
  /// [params] - 初始化参数
  /// [saveLog] - 是否保存日志
  /// [logLevel] - 日志级别
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> initialize({
    required Map<String, Object?> params,
    required bool saveLog,
    required LogLevel logLevel,
  }) async {
    setCallback(this);
    return await _hostApi.initialize(
      params: params,
      saveLog: saveLog,
      logLevel: logLevel,
    );
  }

  /// 设置参数
  ///
  /// [params] - 参数 Map
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> setParams(Map<String, Object?> params) async {
    return await _hostApi.setParams(params);
  }

  /// 启动对话
  ///
  /// [mode] - VAD 模式
  /// [params] - 参数 Map
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> startDialog(VadMode mode, Map<String, Object?> params) async {
    return await _hostApi.startDialog(mode, params);
  }

  /// 释放资源
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> release() async {
    return await _hostApi.release();
  }

  /// 取消对话
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> cancelDialog() async {
    return await _hostApi.cancelDialog();
  }

  /// 停止对话
  ///
  /// 返回值: 0 表示成功，非 0 表示错误码
  Future<int> stopDialog() async {
    return await _hostApi.stopDialog();
  }

  @override
  void onNuiAudioStateChanged(AudioState state) {
    _audioStateController.add(state);
  }

  @override
  void onNuiEventCallback(
    String event,
    int resultCode,
    String kwsResult,
    String asrResult,
  ) {
    _eventCallbackController.add(
      NuiEventData(
        event: NuiCallbackEvent.values.firstWhere(
          (e) => e.name == event,
          orElse: () => NuiCallbackEvent.EVENT_UNKNOWN,
        ),
        resultCode: resultCode,
        kwsResult: kwsResult,
        asrResult: AsrResult.fromJson(jsonDecode(asrResult)),
      ),
    );
  }
}
