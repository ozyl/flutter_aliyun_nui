import Flutter
import nuisdk
import UIKit
import AVFoundation

// MARK: - Extensions for Mapping
extension LogLevel {
    func toNui() -> NuiSdkLogLevel {
        switch self {
        case .logLevelVerbose: return NUI_LOG_LEVEL_VERBOSE
        case .logLevelDebug: return NUI_LOG_LEVEL_DEBUG
        case .logLevelInfo: return NUI_LOG_LEVEL_INFO
        case .logLevelWarning: return NUI_LOG_LEVEL_WARNING
        case .logLevelError: return NUI_LOG_LEVEL_ERROR
        case .logLevelNone: return NUI_LOG_LEVEL_NONE
        }
    }
}

extension VadMode {
    func toNui() -> NuiVadMode {
        switch self {
        case .typeVad: return MODE_VAD
        case .typeP2t: return MODE_P2T
        case .typeKws: return MODE_KWS
        case .typeParallel: return MODE_PARALLEL
        case .typeAutoContinual: return MODE_AUTO_CONTINUAL
        case .typeKwsContinual: return MODE_KWS_CONTINUAL
        case .typeOnlyKws: return MODE_ONLY_KWS
        case .typeKws2Parallel:
            return MODE_KWS2PARALLEL
        case .typeKws2Talk:
            return MODE_KWS2TALK
        case .typeUnknown:
            return MODE_P2T
        }
    }
}

// MARK: - Flutter Plugin Implementation

public class FlutterAliyunNuiPlugin: NSObject, FlutterPlugin, FlutterAliyunNuiHostApi, NeoNuiSdkDelegate, ConvVoiceRecorderDelegate {
    
    private var callback: FlutterAliyunNuiCallback?
    private var nuiInstance: NeoNui?
    private var audioController: AudioController?
    private var recordedVoiceData: NSMutableData?
    
    // 单例模式获取 NeoNui，这与 Demo 中的 [NeoNui get_instance] 对应
    private var nui: NeoNui {
        if nuiInstance == nil {
            nuiInstance = NeoNui.get_instance()
            nuiInstance?.delegate = self
        }
        return nuiInstance!
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterAliyunNuiPlugin()
        
        // 设置 HostApi
        FlutterAliyunNuiHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        
        // 创建 Callback
        instance.callback = FlutterAliyunNuiCallback(binaryMessenger: registrar.messenger())
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        FlutterAliyunNuiHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        callback = nil
        // 释放资源
        audioController?.delegate = nil
        audioController = nil
        nuiInstance?.nui_release()
        nuiInstance?.delegate = nil
        nuiInstance = nil
    }
    
    // ========== 实现 FlutterAliyunNuiHostApi 协议 ==========
    
    func initialize(params: [String: Any?], saveLog: Bool, logLevel: LogLevel) throws -> Int64 {
        print("FlutterAliyunNuiPlugin: initialize params: \(params)")
        
        guard let jsonString = mapToJson(params) else {
            return -1
        }
        
        // 调用 iOS SDK 初始化
        let ret = nui.nui_initialize(jsonString, logLevel: logLevel.toNui(), saveLog: saveLog)
        return Int64(ret)
    }
    
    func setParams(params: [String: Any?]) throws -> Int64 {
        print("FlutterAliyunNuiPlugin: setParams params: \(params)")
        
        guard let jsonString = mapToJson(params) else {
            return -1
        }
        
        let ret = nui.nui_set_params(jsonString)
        return Int64(ret)
    }
    
    func startDialog(mode: VadMode, params: [String: Any?]) throws -> Int64 {
        // 检查麦克风权限
        let authStatus = AVAudioSession.sharedInstance().recordPermission
        if authStatus == .denied {
            return -1
        }
        
        print("FlutterAliyunNuiPlugin: startDialog params: \(params)")
        
        // 初始化 AudioController（参照 s.m 第 107-111 行）
        // only_recorder = 2
        if audioController == nil {
            audioController = AudioController(AudioControlType(rawValue: 2))
            audioController?.delegate = self
        }
        
        guard let jsonString = mapToJson(params) else {
            return -1
        }
        
        // 参照 s.m 中的实现，调用 nui_dialog_start
        let ret = nui.nui_dialog_start(mode.toNui(), dialogParam: jsonString)
        return Int64(ret)
    }
    
    func release() throws -> Int64 {
        let ret = nui.nui_release()
        audioController?.delegate = nil
        audioController = nil
        return Int64(ret)
    }
    
    func cancelDialog() throws -> Int64 {
        let ret = nui.nui_dialog_cancel(true)
        if let controller = audioController {
            controller.stopRecorder(false)
        }
        return Int64(ret)
    }
    
    func stopDialog() throws -> Int64 {
        let ret = nui.nui_dialog_cancel(false)
        if let controller = audioController {
            controller.stopRecorder(false)
        }
        return Int64(ret)
    }
    
    // ========== 辅助方法 ==========
    
    func getCallback() -> FlutterAliyunNuiCallback? {
        return callback
    }
    
    private func mapToJson(_ map: [String: Any?]) -> String? {
        // 过滤掉 nil 值，JSONSerialization 不支持 nil
        let validMap = map.compactMapValues { $0 }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: validMap, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            print("FlutterAliyunNuiPlugin: JSON conversion error \(error)")
            return nil
        }
    }
    
    // ========== NeoNuiSdkDelegate 实现 ==========
    
    // 1. 事件回调
    public func onNuiEventCallback(_ event: NuiCallbackEvent, dialog: Int, kwsResult: UnsafePointer<Int8>?, asrResult: UnsafePointer<Int8>?, ifFinish: Bool, retCode: Int32) {
        
        let eventName = mapNuiEventToString(event)
        
        // 转换 C 字符串到 Swift String
        let kwsStr = kwsResult != nil ? String(cString: kwsResult!) : ""
        let asrStr = asrResult != nil ? String(cString: asrResult!) : ""
        
        print("FlutterAliyunNuiPlugin: onNuiEventCallback event=\(eventName) retCode=\(retCode)")
        
        // 切换到主线程回调 Flutter
        DispatchQueue.main.async {
            self.getCallback()?.onNuiEventCallback(
                event: eventName,
                resultCode: Int64(retCode),
                kwsResult: kwsStr,
                asrResult: asrStr,
                completion: { _ in }
            )
        }
    }
    
    // 2. 音频数据回调 (SDK 主动来拉取数据) - 参照 s.m 的实现
    public func onNuiNeedAudioData(_ audioData: UnsafeMutablePointer<Int8>?, length: Int32) -> Int32 {
        guard let buffer = audioData else { return 0 }
        
        // 从 recordedVoiceData 读取数据，类似 s.m 中的实现
        guard let data = recordedVoiceData else { return 0 }
        
        objc_sync_enter(data)
        defer { objc_sync_exit(data) }
        
        if data.length > 0 {
            let recorderLen: Int
            if data.length > length {
                recorderLen = Int(length)
            } else {
                recorderLen = data.length
            }
            
            let tempData = data.subdata(with: NSRange(location: 0, length: recorderLen))
            tempData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                if let baseAddress = bytes.baseAddress {
                    memcpy(buffer, baseAddress, recorderLen)
                }
            }
            
            let remainLength = data.length - recorderLen
            let range = NSRange(location: recorderLen, length: remainLength)
            data.setData(data.subdata(with: range))
            
            return Int32(recorderLen)
        }
        
        return 0
    }
    
    // 3. 音频状态改变回调 - 参照 s.m 的实现
    public func onNuiAudioStateChanged(_ state: NuiAudioState) {
        print("FlutterAliyunNuiPlugin: onNuiAudioStateChanged state=\(state.rawValue)")
        
        var flutterState = AudioState.stateClose
        
        switch state {
        case STATE_OPEN:
            flutterState = AudioState.stateOpen
            // SDK 准备好了，开启录音机
            recordedVoiceData = NSMutableData()
            if audioController != nil {
                audioController?.startRecorder()
            }
            
        case STATE_PAUSE:
            flutterState = AudioState.statePause
            if audioController != nil {
                audioController?.stopRecorder(false)
            }
            
        case STATE_CLOSE:
            flutterState = AudioState.stateClose
            if audioController != nil {
                audioController?.stopRecorder(false)
            }
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.getCallback()?.onNuiAudioStateChanged(state: flutterState, completion: { _ in })
        }
    }
    
    // 4. 音量回调
    public func onNuiRmsChanged(_ rms: Float) {
        // 可以按需添加回调到 Flutter
    }
    
    // 5. VPR 事件
    public func onNuiVprEventCallback(_ event: NuiCallbackEvent, dialog: Int, kwsResult: UnsafePointer<Int8>?, asrResult: UnsafePointer<Int8>?, ifFinish: Bool, retCode: Int32) {
        // 暂不实现
    }
    
    // ========== ConvVoiceRecorderDelegate 实现 - 参照 s.m ==========
    
    public func recorderDidStart() {
        print("FlutterAliyunNuiPlugin: recorderDidStart")
    }
    
    public func recorderDidStop() {
        print("FlutterAliyunNuiPlugin: recorderDidStop")
        recordedVoiceData?.length = 0
    }
    
    public func voiceRecorded(_ buffer: UnsafeMutablePointer<UInt8>!, length len: Int32) {
        // 将录音数据保存到 recordedVoiceData
        let frame = Data(bytes: buffer, count: Int(len))
        
        if let data = recordedVoiceData {
            objc_sync_enter(data)
            data.append(frame)
            objc_sync_exit(data)
        }
    }
    
    public func voiceDidFail(_ error: Error!) {
        print("FlutterAliyunNuiPlugin: recorder error \(String(describing: error))")
    }
    
    // Player callbacks - 所有方法都需要实现（即使为空）
    public func playerDidStart() {
        // 播放器启动，暂不需要
    }
    
    public func playerDrainDataFinish() {
        // 播放器排空数据完成，暂不需要
    }
    
    public func playerDidFinish() {
        // 播放器完成，暂不需要
    }
    
    public func playSoundLevel(_ level: Int32) {
        // 播放音量回调，暂不需要
    }
    
    public func playData(_ buffer: UnsafeMutablePointer<UInt8>!, length len: Int32) {
        // 播放数据回调，暂不需要
    }
    
    // ========== 私有方法 ==========
    
    // 映射 Event 枚举到 String
    private func mapNuiEventToString(_ event: NuiCallbackEvent) -> String {
        switch event {
        case EVENT_TRANSCRIBER_STARTED: return "EVENT_TRANSCRIBER_STARTED"
        case EVENT_TRANSCRIBER_COMPLETE: return "EVENT_TRANSCRIBER_COMPLETE"
        case EVENT_SENTENCE_START: return "EVENT_SENTENCE_START"
        case EVENT_SENTENCE_END: return "EVENT_SENTENCE_END"
        case EVENT_ASR_PARTIAL_RESULT: return "EVENT_ASR_PARTIAL_RESULT"
        case EVENT_ASR_ERROR: return "EVENT_ASR_ERROR"
        case EVENT_VAD_START: return "EVENT_VAD_START"
        case EVENT_VAD_END: return "EVENT_VAD_END"
        case EVENT_MIC_ERROR: return "EVENT_MIC_ERROR"
        case EVENT_DIALOG_EX: return "EVENT_DIALOG_EX"
        case EVENT_ASR_RESULT: return "EVENT_ASR_RESULT"
        case EVENT_WUW: return "EVENT_WUW"
        case EVENT_WUW_TRUSTED: return "EVENT_WUW_TRUSTED"
        case EVENT_WUW_CONFIRMED: return "EVENT_WUW_CONFIRMED"
        case EVENT_WUW_REJECTED: return "EVENT_WUW_REJECTED"
        case EVENT_WUW_END: return "EVENT_WUW_END"
        default: return "UNKNOWN_EVENT_\(event.rawValue)"
        }
    }
}
