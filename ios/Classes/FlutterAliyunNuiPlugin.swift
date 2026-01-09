import Flutter
import UIKit

public class FlutterAliyunNuiPlugin: NSObject, FlutterPlugin, FlutterAliyunNuiHostApi {
  private var callback: FlutterAliyunNuiCallback?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterAliyunNuiPlugin()
    
    // 设置 HostApi - 处理 Flutter 调用 Native 的方法
    FlutterAliyunNuiHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    
    // 创建 Callback - 用于 Native 回调 Flutter
    instance.callback = FlutterAliyunNuiCallback(binaryMessenger: registrar.messenger())
  }
  
  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    FlutterAliyunNuiHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
    callback = nil
  }
  
  // ========== 实现 FlutterAliyunNuiHostApi 协议 ==========
  
  public func initialize(params: [String: Any?], saveLog: Bool, logLevel: LogLevel) throws -> Int64 {
    // TODO: 实现初始化逻辑
    // 1. 调用阿里云 NUI SDK 初始化
    // 2. 设置参数和日志级别
    return 0  // 返回 0 表示成功，非 0 表示错误码
  }
  
  public func setParams(params: [String: Any?]) throws -> Int64 {
    // TODO: 实现设置参数逻辑
    return 0
  }
  
  public func startDialog(mode: VadMode, params: [String: Any?]) throws -> Int64 {
    // TODO: 实现启动对话逻辑
    // 在适当的时候调用 callback 回调 Flutter
    return 0
  }
  
  public func release() throws -> Int64 {
    // TODO: 实现释放资源逻辑
    return 0
  }
  
  public func cancelDialog() throws -> Int64 {
    // TODO: 实现取消对话逻辑
    return 0
  }
  
  public func stopDialog() throws -> Int64 {
    // TODO: 实现停止对话逻辑
    return 0
  }
  
  // ========== 辅助方法 ==========
  
  /// 获取 Callback 实例，用于回调 Flutter
  /// 例如：callback?.onNuiEventCallback(event: event, resultCode: resultCode, kwsResult: kwsResult, asrResult: asrResult) { }
  public func getCallback() -> FlutterAliyunNuiCallback? {
    return callback
  }
}
