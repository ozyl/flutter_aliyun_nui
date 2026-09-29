# HarmonyOS（OpenHarmony / HarmonyOS NEXT）

## 依赖

1. 按 [阿里云 HarmonyOS Next NUI SDK 文档](https://help.aliyun.com/zh/isi/user-guide/nui-sdk-for-harmonyosnext) 下载 `harmony_neonui_sdk.tar.gz`。
2. 将 `entry/libs/neonui.har` 复制到 `ohos/libs/neonui.har`（见 `ohos/libs/README.md`）。
3. 将 SDK 包内的 `resources_cloud`（若有）放到宿主 `entry/src/main/resources/resfile/resources_cloud`，或在初始化 JSON 里自行指定 `workspace`。

## 与 Android / iOS 的差异

- 录音走 `AudioCapturer` + `NativeNui.updateAudio()`，不使用 `onNuiNeedAudioData` 填数据（与官方鸿蒙示例一致）。
- Flutter 侧仍走 Pigeon，通道名与 `lib/pigeons/pigeon.dart` 一致，Dart API 不变。
- 初始化时若 JSON 未带 `workspace` / `debug_path`，插件会用 `resourceDir/resources_cloud` 与 `filesDir` 补全。

## 宿主权限

在 `entry/src/main/module.json5` 声明 `ohos.permission.MICROPHONE`（聊天语音输入场景说明）。

## 联调

```bash
flutter pub get   # 使用 HarmonyOS Flutter SDK
```

确认 `.flutter-plugins` 含 `flutter_aliyun_nui` 的 `ohos` 实现后再编译鸿蒙工程。
