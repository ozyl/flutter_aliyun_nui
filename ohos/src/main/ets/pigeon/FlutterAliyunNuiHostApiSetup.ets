import BasicMessageChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { MessageHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { pigeonCodec } from './FlutterAliyunNuiPigeonCodec';
import { LogLevel, VadMode } from './FlutterAliyunNuiEnums';
import { pigeonMapToRecord } from './PigeonMapUtil';

export interface FlutterAliyunNuiHostApi {
  initialize(params: Record<string, Object>, saveLog: boolean, logLevel: LogLevel): number;
  setParams(params: Record<string, Object>): number;
  startDialog(mode: VadMode, params: Record<string, Object>): number;
  release(): number;
  cancelDialog(): number;
  stopDialog(): number;
}

function wrapResult(result: number): Object[] {
  return [result];
}

function wrapError(err: Error): Object[] {
  return [err.name, err.message, ''];
}

function bindHost(
  messenger: BinaryMessenger,
  name: string,
  handler: MessageHandler<Object> | null,
): void {
  const channel = new BasicMessageChannel<Object>(messenger, name, pigeonCodec);
  channel.setMessageHandler(handler);
}

export function setUpFlutterAliyunNuiHostApi(messenger: BinaryMessenger, api: FlutterAliyunNuiHostApi | null): void {
  if (api === null) {
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.initialize', null);
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.setParams', null);
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.startDialog', null);
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.release', null);
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.cancelDialog', null);
    bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.stopDialog', null);
    return;
  }

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.initialize', {
    onMessage: (message, reply) => {
      try {
        const args = message as Object[];
        reply.reply(wrapResult(
          api.initialize(pigeonMapToRecord(args[0] as Object), args[1] as boolean, args[2] as LogLevel),
        ));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.setParams', {
    onMessage: (message, reply) => {
      try {
        const args = message as Object[];
        reply.reply(wrapResult(api.setParams(pigeonMapToRecord(args[0] as Object))));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.startDialog', {
    onMessage: (message, reply) => {
      try {
        const args = message as Object[];
        reply.reply(wrapResult(api.startDialog(args[0] as VadMode, pigeonMapToRecord(args[1] as Object))));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.release', {
    onMessage: (_message, reply) => {
      try {
        reply.reply(wrapResult(api.release()));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.cancelDialog', {
    onMessage: (_message, reply) => {
      try {
        reply.reply(wrapResult(api.cancelDialog()));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });

  bindHost(messenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.stopDialog', {
    onMessage: (_message, reply) => {
      try {
        reply.reply(wrapResult(api.stopDialog()));
      } catch (e) {
        reply.reply(wrapError(e as Error));
      }
    },
  });
}
