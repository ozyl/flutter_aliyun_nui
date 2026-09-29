import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { ByteBuffer } from '@ohos/flutter_ohos/src/main/ets/util/ByteBuffer';
import Any from '@ohos/flutter_ohos/src/main/ets/plugin/common/Any';
import { AudioState, audioStateFromRaw, logLevelFromRaw, vadModeFromRaw } from './FlutterAliyunNuiEnums';

/**
 * Pigeon codec aligned with lib/pigeons/pigeon.dart (_PigeonCodec).
 */
export default class FlutterAliyunNuiPigeonCodec extends StandardMessageCodec {
  readValueOfType(type: number, buffer: ByteBuffer): Any {
    if (type === 129) {
      const raw = this.readValue(buffer) as number;
      return audioStateFromRaw(raw);
    }
    if (type === 130) {
      const raw = this.readValue(buffer) as number;
      return logLevelFromRaw(raw);
    }
    if (type === 131) {
      const raw = this.readValue(buffer) as number;
      return vadModeFromRaw(raw);
    }
    return super.readValueOfType(type, buffer);
  }

  writeValue(stream: ByteBuffer, value: Any): Any {
    if (value === AudioState.STATE_OPEN || value === AudioState.STATE_PAUSE || value === AudioState.STATE_CLOSE) {
      stream.writeInt8(129);
      return this.writeValue(stream, value as number);
    }
    return super.writeValue(stream, value);
  }
}

export const pigeonCodec = new FlutterAliyunNuiPigeonCodec();
