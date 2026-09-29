export enum AudioState {
  STATE_OPEN = 0,
  STATE_PAUSE = 1,
  STATE_CLOSE = 2,
}

export enum LogLevel {
  LOG_LEVEL_VERBOSE = 0,
  LOG_LEVEL_DEBUG = 1,
  LOG_LEVEL_INFO = 2,
  LOG_LEVEL_WARNING = 3,
  LOG_LEVEL_ERROR = 4,
  LOG_LEVEL_NONE = 5,
}

export enum VadMode {
  TYPE_UNKNOWN = 0,
  TYPE_VAD = 1,
  TYPE_P2T = 2,
  TYPE_KWS = 3,
  TYPE_PARALLEL = 4,
  TYPE_KWS2PARALLEL = 5,
  TYPE_AUTO_CONTINUAL = 6,
  TYPE_KWS_CONTINUAL = 7,
  TYPE_KWS2TALK = 8,
  TYPE_ONLY_KWS = 9,
}

export function audioStateFromRaw(raw: number): AudioState | undefined {
  if (raw === 0) return AudioState.STATE_OPEN;
  if (raw === 1) return AudioState.STATE_PAUSE;
  if (raw === 2) return AudioState.STATE_CLOSE;
  return undefined;
}

export function logLevelFromRaw(raw: number): LogLevel | undefined {
  const values = [
    LogLevel.LOG_LEVEL_VERBOSE,
    LogLevel.LOG_LEVEL_DEBUG,
    LogLevel.LOG_LEVEL_INFO,
    LogLevel.LOG_LEVEL_WARNING,
    LogLevel.LOG_LEVEL_ERROR,
    LogLevel.LOG_LEVEL_NONE,
  ];
  return values[raw];
}

export function vadModeFromRaw(raw: number): VadMode | undefined {
  const values = [
    VadMode.TYPE_UNKNOWN,
    VadMode.TYPE_VAD,
    VadMode.TYPE_P2T,
    VadMode.TYPE_KWS,
    VadMode.TYPE_PARALLEL,
    VadMode.TYPE_KWS2PARALLEL,
    VadMode.TYPE_AUTO_CONTINUAL,
    VadMode.TYPE_KWS_CONTINUAL,
    VadMode.TYPE_KWS2TALK,
    VadMode.TYPE_ONLY_KWS,
  ];
  return values[raw];
}
