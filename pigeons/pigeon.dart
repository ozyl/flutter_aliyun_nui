import 'package:pigeon/pigeon.dart'
    show
        ConfigurePigeon,
        DartOptions,
        HostApi,
        KotlinOptions,
        PigeonOptions,
        SwiftOptions,
        FlutterApi,
        Uint8List;

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeons/pigeon.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/example/flutter_aliyun_nui/FlutterAliyunNuiHostApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.flutter_aliyun_nui'),
    swiftOut: 'ios/Classes/FlutterAliyunNuiHostApi.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'flutter_aliyun_nui',
  ),
)
enum AudioState { stateOpen, statePause, stateClose }

class AsrResult {
  bool finish;
  int resultCode;
  String asrResult;
  String allResponse;

  AsrResult({
    required this.finish,
    required this.resultCode,
    required this.asrResult,
    required this.allResponse,
  });
}

enum LogLevel {
  logLevelVerbose,
  logLevelDebug,
  logLevelInfo,
  logLevelWarning,
  logLevelError,
  logLevelNone,
}

enum VadMode {
  typeUnknown(-1),
  typeVad(0),
  typeP2t(1),
  typeKws(2),
  typeParallel(3),
  typeKws2Parallel(4),
  typeAutoContinual(5),
  typeKwsContinual(6),
  typeKws2Talk(7),
  typeOnlyKws(8);

  final int value;
  const VadMode(this.value);
}

// 2. 原生回调 Flutter 的接口 (Event Callback)
@FlutterApi()
abstract class FlutterAliyunNuiCallback {
  int onNuiNeedAudioData(Uint8List buffer, int length);
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
  int resumeDialog();
  int stopDialog();
}
