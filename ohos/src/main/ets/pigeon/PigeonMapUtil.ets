/** Pigeon / StandardMessageCodec 在鸿蒙侧解码 Map 为 ES Map，需转成可 JSON.stringify 的 plain object。 */
export function pigeonMapToRecord(value: Object | null | undefined): Record<string, Object> {
  const out: Record<string, Object> = {};
  if (value === null || value === undefined) {
    return out;
  }
  if (value instanceof Map) {
    value.forEach((v: Object, k: Object) => {
      out[String(k)] = pigeonNormalizeValue(v);
    });
    return out;
  }
  const keys = Object.keys(value as Record<string, Object>);
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    out[key] = pigeonNormalizeValue((value as Record<string, Object>)[key]);
  }
  return out;
}

function pigeonNormalizeValue(value: Object): Object {
  if (value === null || value === undefined) {
    return value as Object;
  }
  if (value instanceof Map) {
    return pigeonMapToRecord(value);
  }
  if (Array.isArray(value)) {
    return value.map((item: Object) => pigeonNormalizeValue(item));
  }
  return value;
}
