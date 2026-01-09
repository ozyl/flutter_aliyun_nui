# flutter_aliyun_nui

Flutter 阿里云 NUI SDK 插件，提供语音识别和对话功能。

## ✅ 配置完成状态

本插件已完成基础配置，包括：

- ✅ Pigeon API 定义
- ✅ 自动生成的平台通信代码（Android Kotlin、iOS Swift、Dart）
- ✅ Android 插件骨架
- ✅ iOS 插件骨架
- ✅ Flutter 主入口类
- ✅ 示例应用

## 📋 待实现功能

需要根据阿里云 NUI SDK 的官方文档，在以下文件中实现具体的 SDK 调用：

- `android/src/main/kotlin/com/example/flutter_aliyun_nui/FlutterAliyunNuiPlugin.kt`
- `ios/Classes/FlutterAliyunNuiPlugin.swift`

详细实现指南请查看 [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)

## 功能特性

- 🎤 实时语音识别（ASR）
- 🔑 关键词识别（KWS）
- 🎙️ 多种 VAD 模式支持
- 📞 对话管理（启动、停止、暂停、恢复）
- 📊 音频状态监听
- 🔄 事件回调机制

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  flutter_aliyun_nui:
    path: ../  # 或者使用 git/pub 地址
```

## 使用示例

### 1. 实现回调接口

```dart
import 'package:flutter_aliyun_nui/flutter_aliyun_nui.dart';
import 'dart:typed_data';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> implements FlutterAliyunNuiCallback {
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
      },
      saveLog: true,
      logLevel: LogLevel.logLevelInfo,
    );

    if (result == 0) {
      print('初始化成功');
    }
  }

  // 实现回调方法
  @override
  int onNuiNeedAudioData(Uint8List buffer, int length) {
    // 填充音频数据到 buffer
    return 0; // 返回实际填充的字节数
  }

  @override
  void onNuiAudioStateChanged(AudioState state) {
    print('音频状态: $state');
  }

  @override
  void onNuiEventCallback(String event, int resultCode, String kwsResult, String asrResult) {
    print('识别结果: $asrResult');
  }
}
```

### 2. 启动对话

```dart
// 启动对话
await _plugin.startDialog(
  VadMode.typeVad,
  {
    // 对话参数
  },
);

// 停止对话
await _plugin.stopDialog();

// 取消对话
await _plugin.cancelDialog();

// 恢复对话
await _plugin.resumeDialog();
```

## API 文档

### 主要类

#### FlutterAliyunNui

主插件类，提供单例访问。

```dart
final plugin = FlutterAliyunNui.instance;
```

#### 方法

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `setCallback` | `FlutterAliyunNuiCallback` | `void` | 设置事件回调 |
| `initialize` | `params, saveLog, logLevel` | `Future<int>` | 初始化 SDK |
| `setParams` | `params` | `Future<int>` | 设置参数 |
| `startDialog` | `mode, params` | `Future<int>` | 启动对话 |
| `stopDialog` | - | `Future<int>` | 停止对话 |
| `cancelDialog` | - | `Future<int>` | 取消对话 |
| `resumeDialog` | - | `Future<int>` | 恢复对话 |
| `release` | - | `Future<int>` | 释放资源 |

### 回调接口

#### FlutterAliyunNuiCallback

```dart
abstract class FlutterAliyunNuiCallback {
  // 需要音频数据时调用
  int onNuiNeedAudioData(Uint8List buffer, int length);
  
  // 音频状态变化时调用
  void onNuiAudioStateChanged(AudioState state);
  
  // SDK 事件回调
  void onNuiEventCallback(String event, int resultCode, String kwsResult, String asrResult);
}
```

### 枚举类型

#### VadMode - VAD 模式

```dart
enum VadMode {
  typeUnknown,      // 未知
  typeVad,          // VAD 模式
  typeP2t,          // 按键说话模式
  typeKws,          // 关键词唤醒模式
  typeParallel,     // 并行模式
  typeKws2Parallel, // 关键词到并行模式
  typeAutoContinual,// 自动连续模式
  typeKwsContinual, // 关键词连续模式
  typeKws2Talk,     // 关键词到说话模式
  typeOnlyKws,      // 仅关键词模式
}
```

#### AudioState - 音频状态

```dart
enum AudioState {
  stateOpen,   // 打开
  statePause,  // 暂停
  stateClose,  // 关闭
}
```

#### LogLevel - 日志级别

```dart
enum LogLevel {
  logLevelVerbose,  // 详细
  logLevelDebug,    // 调试
  logLevelInfo,     // 信息
  logLevelWarning,  // 警告
  logLevelError,    // 错误
  logLevelNone,     // 无
}
```

## 项目结构

```
flutter_aliyun_nui/
├── pigeons/
│   └── pigeon.dart                    # Pigeon API 定义
├── lib/
│   ├── flutter_aliyun_nui.dart        # 主入口
│   └── pigeons/
│       └── pigeon.dart                # 自动生成的 Dart API
├── android/
│   └── src/main/kotlin/com/example/flutter_aliyun_nui/
│       ├── FlutterAliyunNuiPlugin.kt          # Android 插件实现
│       └── FlutterAliyunNuiHostApi.g.kt       # 自动生成
└── ios/
    └── Classes/
        ├── FlutterAliyunNuiPlugin.swift       # iOS 插件实现
        └── FlutterAliyunNuiHostApi.g.swift    # 自动生成
```

## 开发指南

### 重新生成 Pigeon 代码

如果修改了 `pigeons/pigeon.dart`，需要重新生成平台通信代码：

```bash
dart run pigeon --input pigeons/pigeon.dart
```

或

```bash
flutter pub run pigeon --input pigeons/pigeon.dart
```

### 实现原生代码

详细的实现指南请查看 [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)

## 依赖

- Flutter SDK
- Pigeon (代码生成工具)
- 阿里云 NUI SDK（需要自行集成）

## 许可证

请参考项目的 LICENSE 文件。

## 联系方式

如有问题或建议，请提交 Issue。
