import 'package:pigeon/pigeon.dart'
    show
        ArkTSOptions,
        ConfigurePigeon,
        DartOptions,
        HostApi,
        KotlinOptions,
        PigeonOptions,
        SwiftOptions,
        FlutterApi;

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeons/pigeon.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/example/flutter_aliyun_nui/FlutterAliyunNuiHostApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.flutter_aliyun_nui'),
    swiftOut: 'ios/Classes/FlutterAliyunNuiHostApi.g.swift',
    swiftOptions: SwiftOptions(),
    arkTSOut:
        'ohos/src/main/ets/pigeon/FlutterAliyunNuiHostApi.g.ets',
    arkTSOptions: ArkTSOptions(),
    dartPackageName: 'flutter_aliyun_nui',
  ),
)
enum AudioState { stateOpen, statePause, stateClose }

enum LogLevel {
  logLevelVerbose,
  logLevelDebug,
  logLevelInfo,
  logLevelWarning,
  logLevelError,
  logLevelNone,
}

enum VadMode {
  typeUnknown,
  typeVad,
  typeP2t,
  typeKws,
  typeParallel,
  typeKws2Parallel,
  typeAutoContinual,
  typeKwsContinual,
  typeKws2Talk,
  typeOnlyKws,
}

// 2. 原生回调 Flutter 的接口 (Event Callback)
@FlutterApi()
abstract class FlutterAliyunNuiCallback {
  void onNuiAudioStateChanged(AudioState state);
  void onNuiEventCallback(
    String event,
    int resultCode,
    String kwsResult,
    String asrResult,
  );
}

@HostApi()
abstract class FlutterAliyunNuiHostApi {
  int initialize({
    required Map<String, Object?> params,
    required bool saveLog,
    required LogLevel logLevel,
  });

  int setParams(Map<String, Object?> params);

  int startDialog(VadMode mode, Map<String, Object?> params);

  int release();
  int cancelDialog();
  int stopDialog();
}
