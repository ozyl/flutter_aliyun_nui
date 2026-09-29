import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { Constants, NativeNui, INativeNuiCallback, AsrResult, KwsResult } from 'neonui';
import FlutterAliyunNuiCallback from './pigeon/FlutterAliyunNuiCallback';
import { setUpFlutterAliyunNuiHostApi, FlutterAliyunNuiHostApi } from './pigeon/FlutterAliyunNuiHostApiSetup';
import { AudioState, LogLevel, VadMode } from './pigeon/FlutterAliyunNuiEnums';
import { NuiAudioCapturer } from './NuiAudioCapturer';

const TAG = 'FlutterAliyunNuiPlugin';

export default class FlutterAliyunNuiPlugin
  implements FlutterPlugin, AbilityAware, FlutterAliyunNuiHostApi, INativeNuiCallback
{
  private callback: FlutterAliyunNuiCallback | null = null;
  private uiContext: common.UIAbilityContext | null = null;
  private nui: NativeNui | null = null;
  private capturer = new NuiAudioCapturer();

  getUniqueClassName(): string {
    return 'FlutterAliyunNuiPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.callback = new FlutterAliyunNuiCallback(binding.getBinaryMessenger());
    setUpFlutterAliyunNuiHostApi(binding.getBinaryMessenger(), this);
  }

  onDetachedFromEngine(_binding: FlutterPluginBinding): void {
    setUpFlutterAliyunNuiHostApi(_binding.getBinaryMessenger(), null);
    this.callback = null;
    this.releaseEngine();
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiContext = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.uiContext = null;
  }

  private ensureNui(): NativeNui {
    if (this.nui === null) {
      this.nui = new NativeNui(Constants.ModeType.MODE_DIALOG, 'asr');
    }
    return this.nui;
  }

  private releaseEngine(): void {
    try {
      this.nui?.release();
    } catch (_) {}
    this.nui = null;
    this.capturer.stop();
  }

  private mapLogLevel(level: LogLevel): number {
    return level as number;
  }

  private eventName(event: number): string {
    const table: Record<number, string> = {
      0: 'EVENT_VAD_START',
      1: 'EVENT_VAD_END',
      2: 'EVENT_ASR_PARTIAL_RESULT',
      3: 'EVENT_ASR_RESULT',
      4: 'EVENT_ASR_ERROR',
      5: 'EVENT_MIC_ERROR',
      23: 'EVENT_SENTENCE_END',
      31: 'EVENT_TRANSCRIBER_STARTED',
      32: 'EVENT_TRANSCRIBER_COMPLETE',
    };
    return table[event] ?? `EVENT_${event}`;
  }

  private mapVadMode(mode: VadMode): number {
    switch (mode) {
      case VadMode.TYPE_VAD:
        return Constants.VadMode.TYPE_VAD;
      case VadMode.TYPE_P2T:
        return Constants.VadMode.TYPE_P2T;
      case VadMode.TYPE_KWS:
        return Constants.VadMode.TYPE_KWS;
      default:
        return Constants.VadMode.TYPE_P2T;
    }
  }

  private enrichInitParams(params: Record<string, Object>): string {
    const ctx = this.uiContext;
    if (ctx !== null) {
      if (params['workspace'] === undefined || params['workspace'] === null) {
        params['workspace'] = `${ctx.resourceDir}/resources_cloud`;
      }
      if (params['debug_path'] === undefined || params['debug_path'] === null) {
        params['debug_path'] = ctx.filesDir;
      }
    }
    return JSON.stringify(params);
  }

  initialize(params: Record<string, Object>, saveLog: boolean, logLevel: LogLevel): number {
    const nui = this.ensureNui();
    const json = this.enrichInitParams(params);
    Log.i(TAG, `initialize ${json}`);
    return nui.initialize(this, json, this.mapLogLevel(logLevel), saveLog);
  }

  setParams(params: Record<string, Object>): number {
    return this.ensureNui().setParams(JSON.stringify(params));
  }

  startDialog(mode: VadMode, params: Record<string, Object>): number {
    return this.ensureNui().startDialog(this.mapVadMode(mode), JSON.stringify(params));
  }

  release(): number {
    const code = this.ensureNui().release();
    this.nui = null;
    return code;
  }

  cancelDialog(): number {
    return this.ensureNui().cancelDialog();
  }

  stopDialog(): number {
    return this.ensureNui().stopDialog();
  }

  onNuiEventCallback(
    event: number,
    resultCode: number,
    _arg2: number,
    kwsResult: KwsResult,
    asrResult: AsrResult,
  ): void {
    const eventName = this.eventName(event);
    const kwsJson = kwsResult ? JSON.stringify(kwsResult) : '{}';
    const asrJson = asrResult ? JSON.stringify(asrResult) : '{}';
    Log.i(TAG, `event=${eventName} code=${resultCode}`);
    this.callback?.onNuiEventCallback(eventName, resultCode, kwsJson, asrJson);
  }

  onNuiNeedAudioData(_buffer: ArrayBuffer): number {
    return 0;
  }

  onNuiAudioStateChanged(state: number): void {
    const nui = this.nui;
    if (state === Constants.AudioState.STATE_OPEN) {
      this.capturer.start((buffer) => {
        nui?.updateAudio(buffer, false);
      });
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_OPEN);
    } else if (state === Constants.AudioState.STATE_PAUSE) {
      this.capturer.stop();
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_PAUSE);
    } else if (state === Constants.AudioState.STATE_CLOSE) {
      this.capturer.stop();
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_CLOSE);
    }
  }

  onNuiAudioRMSChanged(_val: number): number {
    return 0;
  }

  onNuiLogTrackCallback(_level: Constants.LogLevel, _log: string): void {}
}
