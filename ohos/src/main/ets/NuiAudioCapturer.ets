import { audio } from '@kit.AudioKit';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';

const TAG = 'NuiAudioCapturer';
const SAMPLE_RATE = 16000;

export type AudioPush = (buffer: ArrayBuffer) => void;

export class NuiAudioCapturer {
  private capturer: audio.AudioCapturer | null = null;
  private push: AudioPush | null = null;

  async start(onPush: AudioPush): Promise<boolean> {
    this.push = onPush;
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
      this.push?.(buffer);
    });
    await this.capturer.start();
    Log.i(TAG, 'capturer started');
    return true;
  }

  async stop(): Promise<void> {
    const c = this.capturer;
    this.capturer = null;
    this.push = null;
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
