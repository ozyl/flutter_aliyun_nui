/// Flutter 阿里云 NUI SDK 插件
library;

import 'pigeons/pigeon.dart';

// 导出 Pigeon 生成的 API
export 'pigeons/pigeon.dart';

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

/// Flutter 阿里云 NUI SDK 主类
class FlutterAliyunNui {
  FlutterAliyunNui._();

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
}
