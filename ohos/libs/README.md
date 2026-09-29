# 阿里云 HarmonyOS NUI SDK

从[智能语音交互 · HarmonyOS Next SDK](https://help.aliyun.com/zh/isi/user-guide/nui-sdk-for-harmonyosnext) 下载 `harmony_neonui_sdk.tar.gz`，解压后将 `entry/libs/neonui.har` 复制到本目录并命名为 `neonui.har`。

未放置 HAR 时鸿蒙工程无法编译本插件；Android / iOS 不受影响。

若 SDK 包内带有 `resources_cloud` 等资源目录，请按官方示例放入宿主工程 `entry/src/main/resources/resfile/`（或插件 `src/main/resources/resfile/`），并在初始化参数的 `workspace` 字段指向对应沙箱路径（插件会在缺少 `workspace` 时用 `resourceDir/resources_cloud` 补全）。
