# Flutter 阿里云 NUI SDK 实现指南

## 项目结构

```
flutter_aliyun_nui/
├── pigeons/pigeon.dart          # Pigeon API 定义文件
├── lib/
│   ├── flutter_aliyun_nui.dart  # 主入口文件
│   └── pigeons/pigeon.dart      # 自动生成的 Dart API
├── android/
│   └── src/main/kotlin/com/example/flutter_aliyun_nui/
│       ├── FlutterAliyunNuiPlugin.kt          # Android 插件实现
│       └── FlutterAliyunNuiHostApi.g.kt       # 自动生成的 Kotlin API
└── ios/
    └── Classes/
        ├── FlutterAliyunNuiPlugin.swift       # iOS 插件实现
        └── FlutterAliyunNuiHostApi.g.swift    # 自动生成的 Swift API
```

## 配置完成情况

✅ Pigeon API 定义已完成
✅ 自动生成的平台代码已完成
✅ Android 插件骨架已配置
✅ iOS 插件骨架已配置
✅ Dart 主入口文件已配置

## 待实现功能

### Android 端 (FlutterAliyunNuiPlugin.kt)

需要在以下方法中实现阿里云 NUI SDK 的调用：

1. **initialize()** - 初始化 SDK
   - 调用阿里云 SDK 初始化方法
   - 设置日志级别
   - 返回错误码（0 表示成功）

2. **setParams()** - 设置参数
   - 更新 SDK 运行时参数

3. **startDialog()** - 启动对话
   - 根据 VAD 模式启动对话
   - 设置事件回调，通过 `callback?.onNuiEventCallback()` 回调到 Flutter

4. **release()** - 释放资源
5. **cancelDialog()** - 取消对话
6. **resumeDialog()** - 恢复对话
7. **stopDialog()** - 停止对话

### iOS 端 (FlutterAliyunNuiPlugin.swift)

需要在以下方法中实现阿里云 NUI SDK 的调用：

1. **initialize()** - 初始化 SDK
2. **setParams()** - 设置参数
3. **startDialog()** - 启动对话
   - 使用 `callback?.onNuiEventCallback()` 回调到 Flutter
4. **release()** - 释放资源
5. **cancelDialog()** - 取消对话
6. **resumeDialog()** - 恢复对话
7. **stopDialog()** - 停止对话

## 如何集成阿里云 NUI SDK

### Android 端集成

1. 将阿里云 SDK 的 `.aar` 文件放入 `android/lib/` 目录（已有 `nuisdk-release.aar`）
2. 在 `android/build.gradle` 中添加依赖（已配置）
3. 在 `FlutterAliyunNuiPlugin.kt` 中：
   ```kotlin
   import com.alibaba.idst.nui.* // 导入阿里云 SDK
   
   class FlutterAliyunNuiPlugin : FlutterPlugin, FlutterAliyunNuiHostApi {
       private var nuiEngine: INuiEngine? = null  // SDK 实例
       
       override fun initialize(params: Map<String, Any?>, saveLog: Boolean, logLevel: LogLevel): Long {
           // 创建和初始化 NUI Engine
           nuiEngine = NuiEngine.getInstance()
           // ... 调用 SDK 初始化方法
           return 0
       }
   }
   ```

### iOS 端集成

1. 将阿里云 SDK framework 添加到 `ios/` 目录
2. 在 `flutter_aliyun_nui.podspec` 中配置依赖
3. 在 `FlutterAliyunNuiPlugin.swift` 中：
   ```swift
   import AliyunNuiSDK  // 导入阿里云 SDK
   
   public class FlutterAliyunNuiPlugin: NSObject, FlutterPlugin, FlutterAliyunNuiHostApi {
       private var nuiEngine: NuiEngine?  // SDK 实例
       
       public func initialize(params: [String: Any?], saveLog: Bool, logLevel: LogLevel) throws -> Int64 {
           // 创建和初始化 NUI Engine
           nuiEngine = NuiEngine.shared()
           // ... 调用 SDK 初始化方法
           return 0
       }
   }
   ```

## 使用示例

### 在 Flutter 应用中使用

```dart
import 'package:flutter_aliyun_nui/flutter_aliyun_nui.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements FlutterAliyunNuiCallback {
  final _plugin = FlutterAliyunNui.instance;
  
  @override
  void initState() {
    super.initState();
    _initPlugin();
  }
  
  Future<void> _initPlugin() async {
    // 1. 设置回调
    _plugin.setCallback(this);
    
    // 2. 初始化
    final result = await _plugin.initialize(
      params: {
        'appKey': 'your_app_key',
        'token': 'your_token',
        // ... 其他参数
      },
      saveLog: true,
      logLevel: LogLevel.logLevelInfo,
    );
    
    if (result == 0) {
      print('初始化成功');
    } else {
      print('初始化失败: $result');
    }
  }
  
  Future<void> _startDialog() async {
    final result = await _plugin.startDialog(
      VadMode.typeVad,
      {
        // 对话参数
      },
    );
    print('启动对话结果: $result');
  }
  
  // 实现回调接口
  @override
  int onNuiNeedAudioData(Uint8List buffer, int length) {
    // 处理音频数据请求
    // 返回实际填充的字节数
    return 0;
  }
  
  @override
  void onNuiAudioStateChanged(AudioState state) {
    print('音频状态变化: $state');
  }
  
  @override
  void onNuiEventCallback(String event, int resultCode, String kwsResult, String asrResult) {
    print('事件回调: $event, 结果码: $resultCode');
    print('关键词识别结果: $kwsResult');
    print('语音识别结果: $asrResult');
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('阿里云 NUI Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startDialog,
                child: Text('开始对话'),
              ),
              ElevatedButton(
                onPressed: () => _plugin.stopDialog(),
                child: Text('停止对话'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 回调说明

### 原生回调 Flutter 的方法

1. **onNuiNeedAudioData(buffer, length)** 
   - 当 SDK 需要音频数据时调用
   - 需要填充 buffer 并返回实际填充的字节数

2. **onNuiAudioStateChanged(state)**
   - 音频状态变化时调用
   - 状态包括: stateOpen, statePause, stateClose

3. **onNuiEventCallback(event, resultCode, kwsResult, asrResult)**
   - SDK 事件回调
   - event: 事件类型
   - resultCode: 结果码
   - kwsResult: 关键词识别结果（JSON）
   - asrResult: 语音识别结果（JSON）

## 下一步

1. 根据阿里云 NUI SDK 文档，在 Android 和 iOS 插件中实现具体的 SDK 调用
2. 测试各个功能是否正常工作
3. 完善错误处理和异常捕获
4. 添加单元测试和集成测试

## 重新生成 Pigeon 代码

如果修改了 `pigeons/pigeon.dart`，需要重新生成代码：

```bash
dart run pigeon --input pigeons/pigeon.dart
```

或

```bash
flutter pub run pigeon --input pigeons/pigeon.dart
```

