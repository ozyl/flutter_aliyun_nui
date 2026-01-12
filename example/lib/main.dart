import 'package:flutter/material.dart';
import 'package:flutter_aliyun_nui/flutter_aliyun_nui.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements FlutterAliyunNuiCallback {
  final _plugin = FlutterAliyunNui.instance;
  final TextEditingController _apiTokenController = TextEditingController(
    text: 'sk-e870ef7dd5d94f8bb6874bbe0100c9b5',
  );
  String _status = '未初始化';
  String _result = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initPlugin() async {
    if (_apiTokenController.text.isEmpty) {
      setState(() {
        _status = '请输入 API Token';
      });
      return;
    }

    try {
      var status = await Permission.microphone.request();
      if (status.isDenied) {
        setState(() {
          _status = '获取音频权限失败';
        });
        return;
      }
      if (_isInitialized) {
        setState(() {
          _status = '已初始化';
        });
        return;
      }
      _plugin.release();
      // 初始化（需要根据实际的阿里云 SDK 文档调整参数）
      final result = await _plugin.initialize(
        params: {
          'device_id': "empty_device_id",

          'url': 'wss://dashscope.aliyuncs.com/api-ws/v1/inference',
          'service_mode': ServiceMode.fullCloud,
        },
        saveLog: false,
        logLevel: LogLevel.logLevelInfo,
      );

      // 设置回调
      _plugin.setCallback(this);
      await _plugin.setParams({
        'nls_config': {
          // 添加对话参数
          'sr_format': 'opus',
          'model': 'fun-asr-realtime-2025-11-07',
          'sample_rate': 16000,
          'semantic_punctuation_enabled': true,
        },
        'service_type': ServiceType.kServiceTypeSpeechTranscriber,
      });

      setState(() {
        if (result == 0) {
          _status = '初始化成功';
          _isInitialized = true;
        } else {
          _status = '初始化失败: $result';
        }
      });
    } catch (e) {
      setState(() {
        _status = '初始化异常: $e';
      });
    }
  }

  Future<void> _startDialog() async {
    await _initPlugin();
    if (!_isInitialized) {
      return;
    }
    try {
      final result = await _plugin.startDialog(VadMode.typeP2t, {
        'apikey': _apiTokenController.text,
      });
      setState(() {
        _status = result == 0 ? '对话已启动' : '启动失败: $result';
      });
    } catch (e) {
      setState(() {
        _status = '启动异常: $e';
      });
    }
  }

  Future<void> _stopDialog() async {
    if (!_isInitialized) {
      setState(() {
        _status = '未初始化';
      });
      return;
    }
    try {
      final result = await _plugin.stopDialog();
      setState(() {
        _status = result == 0 ? '对话已停止' : '停止失败: $result';
      });
    } catch (e) {
      setState(() {
        _status = '停止异常: $e';
      });
    }
  }

  // ========== 实现 FlutterAliyunNuiCallback 接口 ==========

  @override
  void onNuiAudioStateChanged(AudioState state) {
    setState(() {
      _status = '音频状态: $state';
    });
    print('音频状态变化: $state');
  }

  @override
  void onNuiEventCallback(
    String event,
    int resultCode,
    String kwsResult,
    String asrResult,
  ) {
    final eventEnum = NuiCallbackEvent.values.firstWhere(
      (element) => element.name == event,
    );
    print('事件回调: event=$event, resultCode=$resultCode');
    print('关键词识别结果: $kwsResult');
    print('语音识别结果: $asrResult');

    setState(() {
      _result =
          '事件: $event\n'
          '结果码: $resultCode\n'
          '关键词: $kwsResult\n'
          'ASR: $asrResult';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('实时语音识别')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "输入 API Token"),
                controller: _apiTokenController,
              ),
              const SizedBox(height: 10),
              Text(
                '状态: $_status',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _initPlugin, child: const Text('初始化')),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _startDialog,
                child: const Text('开始对话'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _stopDialog, child: const Text('停止对话')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await _plugin.cancelDialog();
                        setState(() {
                          _status = result == 0 ? '对话已取消' : '取消失败: $result';
                        });
                      },
                      child: const Text('取消对话'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '识别结果:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_result.isEmpty ? '暂无结果' : _result),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
