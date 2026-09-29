/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import BasicMessageChannel, { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import { ByteBuffer } from '@ohos/flutter_ohos/src/main/ets/util/ByteBuffer';


/** Error class for passing custom error details to Flutter via a thrown PlatformException. */
export class FlutterError implements Error {

  /** The error code. */
  public code: string;

  /** The error name. */
  public name: string;

  /** The error message. */
  public message: string;
  /** The error stack. */
  public stack?: string;

  constructor(code: string, name: string, message: string, stack?: string) {
    this.code = code;
    this.name = name;
    this.message = message;
    this.stack = stack;
  }
}

function wrapError(error: Error): Array<Object | null> {
  let errorList: Array<Object | null> = new Array<Object | null>(3);
  if (error instanceof FlutterError) {
    let err: FlutterError = error as FlutterError;
    errorList[0] = err.code;
    errorList[1] = err.name;
    errorList[2] = err.message;
  } else {
    errorList[0] = error.toString();
    errorList[1] = error.name;
    errorList[2] = "Cause: " + error.message + ", Stacktrace: " + error.stack;
  }
  return errorList;
}

/* Generated enum from Pigeon that represents data sent in messages.*/
export enum AudioState {
  STATE_OPEN,
  STATE_PAUSE,
  STATE_CLOSE
}

/* Generated enum Companion class from Pigeon that represents data sent 
   in messages.Do not delete otherwise enum type data transfer will be failed*/
export class AudioStateEnum {
  index: string | null = null;
  constructor(index: string) {
    this.index = index;
  }
}

/* Generated enum from Pigeon that represents data sent in messages.*/
export enum LogLevel {
  LOG_LEVEL_VERBOSE,
  LOG_LEVEL_DEBUG,
  LOG_LEVEL_INFO,
  LOG_LEVEL_WARNING,
  LOG_LEVEL_ERROR,
  LOG_LEVEL_NONE
}

/* Generated enum Companion class from Pigeon that represents data sent 
   in messages.Do not delete otherwise enum type data transfer will be failed*/
export class LogLevelEnum {
  index: string | null = null;
  constructor(index: string) {
    this.index = index;
  }
}

/* Generated enum from Pigeon that represents data sent in messages.*/
export enum VadMode {
  TYPE_UNKNOWN,
  TYPE_VAD,
  TYPE_P2T,
  TYPE_KWS,
  TYPE_PARALLEL,
  TYPE_KWS2PARALLEL,
  TYPE_AUTO_CONTINUAL,
  TYPE_KWS_CONTINUAL,
  TYPE_KWS2TALK,
  TYPE_ONLY_KWS
}

/* Generated enum Companion class from Pigeon that represents data sent 
   in messages.Do not delete otherwise enum type data transfer will be failed*/
export class VadModeEnum {
  index: string | null = null;
  constructor(index: string) {
    this.index = index;
  }
}

export class PigeonCodec extends StandardMessageCodec {
  static readonly INSTANCE: PigeonCodec = new PigeonCodec();

  getByte(n: number): number {
    let byteArray = new Uint8Array(1);
    byteArray[0] = n;
    return byteArray[0] as number;
  }
  private constructor() {
    super();
  }

  readValueOfType(type: number, buffer: ByteBuffer): ESObject {
    switch (type) {
      case this.getByte(129): {
        let value: Object = super.readValue(buffer);
        return value == null ? null : AudioState[value as number];
      }
      case this.getByte(130): {
        let value: Object = super.readValue(buffer);
        return value == null ? null : LogLevel[value as number];
      }
      case this.getByte(131): {
        let value: Object = super.readValue(buffer);
        return value == null ? null : VadMode[value as number];
      }
      default:
        return super.readValueOfType(type, buffer);
    }
  }

  writeValue(stream: ByteBuffer, value: ESObject): ESObject {
    if (value instanceof AudioStateEnum) {
      stream.writeUint8(this.getByte(129));
      this.writeValue(stream, value == null ? null : AudioState[value.index as string]);
    } else if (value instanceof LogLevelEnum) {
      stream.writeUint8(this.getByte(130));
      this.writeValue(stream, value == null ? null : LogLevel[value.index as string]);
    } else if (value instanceof VadModeEnum) {
      stream.writeUint8(this.getByte(131));
      this.writeValue(stream, value == null ? null : VadMode[value.index as string]);
    } else {
      super.writeValue(stream, value);
    }
  }
}


export interface Result<T> {
  success(result: T): void;

  error(error: Error): void;
}
/* Generated class from Pigeon that represents Flutter messages that can be called from ArkTS.*/
export class FlutterAliyunNuiCallback {
  binaryMessenger: BinaryMessenger;
  private messageChannelSuffix: string;

  constructor(binaryMessenger: BinaryMessenger, messageChannelSuffix: string = '') {
    this.binaryMessenger = binaryMessenger;
    this.messageChannelSuffix = messageChannelSuffix !== '' ? '.' + messageChannelSuffix : '';
  }

  /** The codec used by FlutterAliyunNuiCallback. */
  static getCodec(): MessageCodec<Object> {
    return PigeonCodec.INSTANCE;
  }

  onNuiAudioStateChanged(stateArg: AudioState, callback: Reply<void>) {
    const channelName: string = 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiCallback.onNuiAudioStateChanged' + this.messageChannelSuffix;
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, channelName, FlutterAliyunNuiCallback.getCodec());
    channel.send(
        [new AudioStateEnum(AudioState[stateArg as number])],
        channelReply => {
          if (Array.isArray(channelReply)) {
            let listReply: ESObject[] = channelReply as ESObject[];
            if (listReply.length > 1) {
              let arrFirst:string = listReply[0] as string;
              let arrSecond:string = listReply[1] as string;
              let arrThird:string = listReply[2] as string;
              let replyArr: ESObject = new FlutterError(arrFirst, arrSecond, arrThird);
              callback.reply(replyArr);
            } else {
              callback.reply();
            }
          } else {
            let connErr: ESObject = new FlutterError('channel-error', 'Unable to establish connection on channel: ' + channelName + '.', '');
            callback.reply(connErr);
          } 
        });
  }
  onNuiEventCallback(eventArg: string,resultCodeArg: number,kwsResultArg: string,asrResultArg: string, callback: Reply<void>) {
    const channelName: string = 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiCallback.onNuiEventCallback' + this.messageChannelSuffix;
    let channel: BasicMessageChannel<Object> = 
        new BasicMessageChannel<Object>(
            this.binaryMessenger, channelName, FlutterAliyunNuiCallback.getCodec());
    channel.send(
        [eventArg, resultCodeArg, kwsResultArg, asrResultArg],
        channelReply => {
          if (Array.isArray(channelReply)) {
            let listReply: ESObject[] = channelReply as ESObject[];
            if (listReply.length > 1) {
              let arrFirst:string = listReply[0] as string;
              let arrSecond:string = listReply[1] as string;
              let arrThird:string = listReply[2] as string;
              let replyArr: ESObject = new FlutterError(arrFirst, arrSecond, arrThird);
              callback.reply(replyArr);
            } else {
              callback.reply();
            }
          } else {
            let connErr: ESObject = new FlutterError('channel-error', 'Unable to establish connection on channel: ' + channelName + '.', '');
            callback.reply(connErr);
          } 
        });
  }
}
/* Generated abstract class from Pigeon that represents a handler of messages from Flutter.*/
export abstract class FlutterAliyunNuiHostApi {

  abstract initialize(params: Map<string, Object | undefined>, saveLog: boolean, logLevel: LogLevel): number;

  abstract setParams(params: Map<string, Object | undefined>): number;

  abstract startDialog(mode: VadMode, params: Map<string, Object | undefined>): number;

  abstract release(): number;

  abstract cancelDialog(): number;

  abstract stopDialog(): number;
  /** The codec used by FlutterAliyunNuiHostApi. */
  static getCodec(): MessageCodec<Object> {
    return PigeonCodec.INSTANCE;
  }
  /*Sets up an instance of `FlutterAliyunNuiHostApi` to handle messages through the `binaryMessenger`.*/
  static setup(binaryMessenger: BinaryMessenger, api: FlutterAliyunNuiHostApi | null, messageChannelSuffix: string = ''): void {
    const separatedMessageChannelSuffix: string = messageChannelSuffix !== '' ? '.' + messageChannelSuffix : '';
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.initialize' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              if (!(Array.isArray(message))) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected List.')));
                  return;
              }
              let args: Array<Object> = message as Array<Object>;
              if (args.length < 3) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected at least 3 argument(s).')));
                  return;
              }
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.initialize(args[0] as Map<string, Object | undefined>, args[1] as boolean, LogLevel[args[2] as string]);
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.setParams' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              if (!(Array.isArray(message))) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected List.')));
                  return;
              }
              let args: Array<Object> = message as Array<Object>;
              if (args.length < 1) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected at least 1 argument(s).')));
                  return;
              }
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.setParams(args[0] as Map<string, Object | undefined>);
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.startDialog' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              if (!(Array.isArray(message))) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected List.')));
                  return;
              }
              let args: Array<Object> = message as Array<Object>;
              if (args.length < 2) {
                  reply.reply(wrapError(new Error('Invalid Pigeon message: expected at least 2 argument(s).')));
                  return;
              }
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.startDialog(VadMode[args[0] as string], args[1] as Map<string, Object | undefined>);
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.release' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.release();
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.cancelDialog' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.cancelDialog();
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
    {
      let channel: BasicMessageChannel<Object> =
          new BasicMessageChannel(
              binaryMessenger, 'dev.flutter.pigeon.flutter_aliyun_nui.FlutterAliyunNuiHostApi.stopDialog' + separatedMessageChannelSuffix, FlutterAliyunNuiHostApi.getCodec());
      if (api != null) {
        channel.setMessageHandler({
            onMessage(message: Object, reply: Reply<Object>) {
              let res: Array<Object | null> = [];
              try {
                let output: number = api!.stopDialog();
                res.push(output);
              } catch (error) {
                let wrappedError: Array<Object | null> = wrapError(error);
                res = wrappedError;
              }
              reply.reply(res);
            } });
      } else {
        channel.setMessageHandler(null);
      }
    }
  }
}
