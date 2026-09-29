# HarmonyOS（OpenHarmony / HarmonyOS NEXT）

## 依赖

1. `ohos/libs/neonui.har` 已随仓库提供；升级 SDK 见 `ohos/libs/README.md`。
2. 插件内已带 `ohos/src/main/resources/resfile/resources_cloud`；宿主 `entry` 需有一份 `resfile/resources_cloud`（小来工程已拷），或在初始化 JSON 里自行指定 `workspace`。

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
