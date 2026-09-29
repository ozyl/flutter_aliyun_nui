import hilog from '@ohos.hilog';
import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
} from '@ohos/flutter_ohos';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { common } from '@kit.AbilityKit';
import {
  CommonUtils,
  Constants,
  NativeNui,
  INativeNuiCallback,
  AsrResult,
  KwsResult,
} from 'neonui';
import fs from '@ohos.file.fs';
import {
  AudioState,
  FlutterAliyunNuiCallback,
  FlutterAliyunNuiHostApi,
  LogLevel,
  VadMode,
} from './pigeon/FlutterAliyunNuiHostApi.g';
import { pigeonMapToRecord } from './pigeon/PigeonMapUtil';
import { NuiAudioCapturer } from './NuiAudioCapturer';

const TAG = 'FlutterAliyunNuiPlugin';
const HILOG_DOMAIN = 0xD001101;
const noopReply: Reply<void> = { reply: (_?: ESObject) => {} };

function logPlugin(msg: string): void {
  Log.i(TAG, msg);
  hilog.info(HILOG_DOMAIN, TAG, '%{public}s', msg);
}

export default class FlutterAliyunNuiPlugin
  extends FlutterAliyunNuiHostApi
  implements FlutterPlugin, AbilityAware, INativeNuiCallback
{
  private callback: FlutterAliyunNuiCallback | null = null;
  private uiContext: common.UIAbilityContext | null = null;
  private nui: NativeNui | null = null;
  private capturer = new NuiAudioCapturer();
  private pendingSetParamsJson: string | null = null;

  getUniqueClassName(): string {
    return 'FlutterAliyunNuiPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    logPlugin('onAttachedToEngine');
    this.callback = new FlutterAliyunNuiCallback(binding.getBinaryMessenger());
    FlutterAliyunNuiHostApi.setup(binding.getBinaryMessenger(), this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    FlutterAliyunNuiHostApi.setup(binding.getBinaryMessenger(), null);
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
    this.pendingSetParamsJson = null;
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

  /** V2.6.8 DialogEngine 必须从 workspace/nui.json 读 app_key；见 libneonui_log DialogEngineImpl:no appkey found。 */
  private prepareWorkspace(ctx: common.UIAbilityContext): string {
    const copied = CommonUtils.copyAssetsData(ctx);
    const workspace = `${ctx.filesDir}/resources_cloud`;
    const srcNui = `${ctx.resourceDir}/resources_cloud/nui.json`;
    const dstNui = `${workspace}/nui.json`;
    // ponytail: copyAssetsData 目标已存在时不再拷贝，须单独刷新 nui.json（否则 app_key 变更不生效）。
    try {
      fs.copyFileSync(srcNui, dstNui);
      // DialogEngineImpl 读 nls_config.key（不是 app_key），见 libneonui_log get_key is nullptr。
      const stat = fs.statSync(dstNui);
      const readBuf = new ArrayBuffer(stat.size);
      const readFd = fs.openSync(dstNui, fs.OpenMode.READ_ONLY);
      fs.readSync(readFd.fd, readBuf);
      fs.closeSync(readFd);
      const raw = String.fromCharCode(...new Uint8Array(readBuf));
      const parsed = JSON.parse(raw) as Record<string, ESObject>;
      const nls = (parsed['nls_config'] as Record<string, ESObject>) ?? {};
      if (nls['key'] === undefined || nls['key'] === null || String(nls['key']).length === 0) {
        nls['key'] = 'default';
      }
      if (nls['token'] === undefined || nls['token'] === null || String(nls['token']).length === 0) {
        nls['token'] = 'default';
      }
      if (nls['app_key'] === undefined || nls['app_key'] === null || String(nls['app_key']).length === 0) {
        nls['app_key'] = 'default';
      }
      parsed['nls_config'] = nls;
      const out = JSON.stringify(parsed);
      const outBytes = new Uint8Array(out.length);
      for (let i = 0; i < out.length; i++) {
        outBytes[i] = out.charCodeAt(i);
      }
      const writeFd = fs.openSync(dstNui, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(writeFd.fd, outBytes.buffer);
      fs.closeSync(writeFd);
    } catch (e) {
      logPlugin(`sync nui.json failed ${JSON.stringify(e)}`);
    }
    let nuiJsonOk = false;
    try {
      nuiJsonOk = fs.accessSync(dstNui, fs.AccessModeType.EXIST);
    } catch (_) {
      nuiJsonOk = false;
    }
    logPlugin(`copyAssetsData ok=${copied} workspace=${workspace} nui.json=${nuiJsonOk}`);
    return workspace;
  }

  private enrichInitParams(params: Record<string, Object>, saveLog: boolean): string {
    const ctx = this.uiContext;
    if (ctx !== null) {
      if (params['workspace'] === undefined || params['workspace'] === null) {
        params['workspace'] = this.prepareWorkspace(ctx);
      }
      if (saveLog && (params['debug_path'] === undefined || params['debug_path'] === null)) {
        params['debug_path'] = ctx.filesDir;
      }
    } else {
      Log.e(TAG, 'uiContext is null; workspace not set');
    }
    return JSON.stringify(params);
  }

  /** NUI 原生层要求部分开关为 string，Pigeon 可能传入 boolean。 */
  private coerceInitParams(params: Record<string, Object>): Record<string, Object> {
    const stringKeys = ['audio_update_manually', 'enable_recorder_by_user', 'save_wav', 'enable_reconnection'];
    const out: Record<string, Object> = {};
    const keys = Object.keys(params);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      let value = params[key];
      if (stringKeys.indexOf(key) >= 0 && typeof value === 'boolean') {
        value = value ? 'true' : 'false';
      }
      out[key] = value;
    }
    return out;
  }

  initialize(params: Map<string, Object | undefined>, saveLog: boolean, logLevel: LogLevel): number {
    logPlugin('initialize start');
    const nui = this.ensureNui();
    const record = pigeonMapToRecord(params);
    const json = this.enrichInitParams(this.coerceInitParams(record), saveLog);
    logPlugin(`initialize params ${json}`);
    const ret = nui.initialize(this, json, this.mapLogLevel(logLevel), saveLog);
    logPlugin(`initialize ret=${ret}`);
    if (ret === 0 && this.pendingSetParamsJson !== null) {
      const pending = this.pendingSetParamsJson;
      this.pendingSetParamsJson = null;
      const pendingRet = nui.setParams(pending);
      logPlugin(`setParams after initialize (deferred) ret=${pendingRet}`);
    }
    return ret;
  }

  setParams(params: Map<string, Object | undefined>): number {
    const record = pigeonMapToRecord(params);
    const json = JSON.stringify(record);
    logPlugin(`setParams ${json}`);
    if (this.nui === null) {
      this.pendingSetParamsJson = json;
      logPlugin('setParams deferred until initialize');
      return 0;
    }
    const ret = this.nui.setParams(json);
    logPlugin(`setParams ret=${ret}`);
    return ret;
  }

  startDialog(mode: VadMode, params: Map<string, Object | undefined>): number {
    const record = pigeonMapToRecord(params);
    return this.ensureNui().startDialog(this.mapVadMode(mode), JSON.stringify(record));
  }

  release(): number {
    logPlugin(`release hasInstance=${this.nui !== null}`);
    if (this.nui === null) {
      return 0;
    }
    const code = this.nui.release();
    this.nui = null;
    this.pendingSetParamsJson = null;
    logPlugin(`release ret=${code}`);
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
    this.callback?.onNuiEventCallback(eventName, resultCode, kwsJson, asrJson, noopReply);
  }

  onNuiNeedAudioData(buffer: ArrayBuffer): number {
    return this.capturer.readInto(buffer);
  }

  onNuiAudioStateChanged(state: number): void {
    if (state === Constants.AudioState.STATE_OPEN) {
      this.capturer.start();
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_OPEN, noopReply);
    } else if (state === Constants.AudioState.STATE_PAUSE) {
      this.capturer.stop();
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_PAUSE, noopReply);
    } else if (state === Constants.AudioState.STATE_CLOSE) {
      this.capturer.stop();
      this.callback?.onNuiAudioStateChanged(AudioState.STATE_CLOSE, noopReply);
    }
  }

  onNuiAudioRMSChanged(_val: number): number {
    return 0;
  }

  onNuiLogTrackCallback(_level: Constants.LogLevel, _log: string): void {}
}
