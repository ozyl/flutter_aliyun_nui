import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { pigeonCodec } from './FlutterAliyunNuiPigeonCodec';
import { AudioState } from './FlutterAliyunNuiEnums';

export default class FlutterAliyunNuiCallback {
  private messenger: BinaryMessenger;

  constructor(messenger: BinaryMessenger) {
    this.messenger = messenger;
  }

  onNuiAudioStateChanged(state: AudioState): void {
    const channel = new BasicMessageChannel<Object>(
      this.messenger,
      'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiCallback.onNuiAudioStateChanged',
      pigeonCodec,
    );
    channel.send([state], () => {});
  }

  onNuiEventCallback(
    event: string,
    resultCode: number,
    kwsResult: string,
    asrResult: string,
  ): void {
    const channel = new BasicMessageChannel<Object>(
      this.messenger,
      'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiCallback.onNuiEventCallback',
      pigeonCodec,
    );
    channel.send([event, resultCode, kwsResult, asrResult], () => {});
  }
}
