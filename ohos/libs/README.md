# 阿里云 HarmonyOS NUI SDK

本目录 **`neonui.har` 已随仓库提交**（厂商 SDK 二进制，不含账号凭证）。clone 后可直接编鸿蒙插件。

升级 SDK 时从[官方文档](https://help.aliyun.com/zh/isi/user-guide/nui-sdk-for-harmonyosnext) 下载新包（如 `V1.5.016.napi.*.tar.gz`），替换 HAR：

```bash
# 在 flutter_aliyun_nui 仓库根目录；TAR 换成本机路径
TAR=~/Downloads/V1.5.016.napi.003.010_*.tar.gz
tar -xzf "$TAR" -O '*/entry/libs/neonui.har' > ohos/libs/neonui.har
```

同步更新 `ohos/src/main/resources/resfile/resources_cloud/`（从 HAR 内 `package/src/main/resources/resfile/resources_cloud` 解压拷贝）。

Android / iOS 仍使用各自平台 SDK，不依赖此 HAR。
