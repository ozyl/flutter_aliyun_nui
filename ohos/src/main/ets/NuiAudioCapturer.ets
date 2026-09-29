import { audio } from '@kit.AudioKit';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'NuiAudioCapturer';

/** 与 Android AudioRecord.read 一致：SDK 在 onNuiNeedAudioData 拉 PCM。 */
export class NuiAudioCapturer {
  private capturer: audio.AudioCapturer | null = null;
  private pending: Uint8Array = new Uint8Array(0);

  append(chunk: ArrayBuffer): void {
    const incoming = new Uint8Array(chunk);
    if (incoming.length === 0) {
      return;
    }
    const merged = new Uint8Array(this.pending.length + incoming.length);
    merged.set(this.pending, 0);
    merged.set(incoming, this.pending.length);
    this.pending = merged;
  }

  readInto(buffer: ArrayBuffer): number {
    const dst = new Uint8Array(buffer);
    const n = Math.min(dst.length, this.pending.length);
    if (n <= 0) {
      return 0;
    }
    dst.set(this.pending.subarray(0, n));
    if (n === this.pending.length) {
      this.pending = new Uint8Array(0);
    } else {
      this.pending = this.pending.subarray(n);
    }
    return n;
  }

  clearPending(): void {
    this.pending = new Uint8Array(0);
  }

  async start(): Promise<boolean> {
    if (this.capturer !== null) {
      return true;
    }
    const options: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW,
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0,
      },
    };
    this.capturer = await audio.createAudioCapturer(options);
    this.capturer.on('readData', (buffer: ArrayBuffer) => {
      this.append(buffer);
    });
    await this.capturer.start();
    Log.i(TAG, 'capturer started (pull mode)');
    return true;
  }

  async stop(): Promise<void> {
    const c = this.capturer;
    this.capturer = null;
    this.clearPending();
    if (c === null) {
      return;
    }
    try {
      await c.stop();
    } catch (_) {}
    try {
      await c.release();
    } catch (_) {}
    Log.i(TAG, 'capturer stopped');
  }
}
