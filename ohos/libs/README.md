# 阿里云 HarmonyOS NUI SDK

从[智能语音交互 · HarmonyOS Next SDK](https://help.aliyun.com/zh/isi/user-guide/nui-sdk-for-harmonyosnext) 下载 SDK 包（如 `V1.5.016.napi.*.tar.gz`），解压后将 `entry/libs/neonui.har` 复制到本目录并命名为 `neonui.har`。

```bash
# 在 flutter_aliyun_nui 仓库根目录执行；TAR 换成本机路径
TAR=~/Downloads/V1.5.016.napi.003.010_*.tar.gz
tar -xzf "$TAR" -O '*/entry/libs/neonui.har' > ohos/libs/neonui.har
```

未放置 HAR 时鸿蒙工程无法编译本插件；Android / iOS 不受影响。`neonui.har` 已在 `.gitignore`，勿提交到 Git。

插件 `ohos/src/main/resources/resfile/resources_cloud/` 已从 HAR 内资源同步一份，供初始化 `workspace` 使用。宿主 `entry` 若仍报缺少 workspace，按 `README_OHOS.md` 在宿主 `resfile` 再放一份。
