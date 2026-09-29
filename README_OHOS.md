# HarmonyOS（OpenHarmony / HarmonyOS NEXT）

## 依赖

1. `ohos/libs/neonui.har` 已随仓库提供；升级 SDK 见 `ohos/libs/README.md`。
2. 宿主 `nui.json` 的 `nls_config` 须含 **`key` / `token` / `app_key`**（均为占位 `"default"`）；V2.6.8 DialogEngine 依次校验（`no appkey found` → `no token found`）。真实鉴权仍走 `startDialog` 的 `apikey`。插件 init 前拷贝到 `filesDir/resources_cloud` 并补全上述字段。

## 与 Android / iOS 的差异

- 录音与 Android 一致：`AudioCapturer` 入队，`onNuiNeedAudioData` 拉 PCM。init JSON **不要**写 `app_key`（只放在 workspace 的 `nui.json`）。
- Flutter 侧仍走 Pigeon，通道名与 `lib/pigeons/pigeon.dart` 一致，Dart API 不变。
- 鸿蒙宿主代码由 **CPF pigeon** 生成（`ohos/src/main/ets/pigeon/FlutterAliyunNuiHostApi.g.ets`），勿手改；改接口后执行：

```bash
dart pub get
dart run pigeon --input pigeons/pigeon.dart
```

`dev_dependencies.pigeon` 指向 `gitcode.com/CPF-Flutter/flutter_packages` 的 `pigeon-v26.1.5-ohos-*`（含 `arkTSOut`）。业务逻辑只在 `FlutterAliyunNuiPlugin.ets`；Map 转 plain object 用 `PigeonMapUtil.ets`。
- `debug_path` 仅在 `saveLog: true` 时注入。
- 百炼 Fun-ASR：按[官方文档](https://help.aliyun.com/zh/model-studio/harmonyos-sdk-for-fun-asr-real-time-service) 顺序 **`initialize` → `setParams` → `startDialog(apikey)`**；鉴权只用 `startDialog` 的 `apikey`。

## 宿主权限

在 `entry/src/main/module.json5` 声明 `ohos.permission.MICROPHONE`（聊天语音输入场景说明）。

## 联调

```bash
flutter pub get   # 使用 HarmonyOS Flutter SDK
```

确认 `.flutter-plugins` 含 `flutter_aliyun_nui` 的 `ohos` 实现后再编译鸿蒙工程。
