export function formatDateTime(value: string | null | undefined) {
  if (!value) return "--";

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "--";

  const month = date.toLocaleString("en-US", { month: "long" });
  const day = date.getDate();
  const hour = date.getHours();
  const displayHour = hour % 12 || 12;
  const minutes = String(date.getMinutes()).padStart(2, "0");
  const seconds = String(date.getSeconds()).padStart(2, "0");
  const meridiem = hour < 12 ? "am" : "pm";

  return `${month} ${day}, ${date.getFullYear()} at ${displayHour}:${minutes}:${seconds}${meridiem}`;
}

export function formatCount(value: number | null | undefined) {
  if (value == null) return "--";
  return value.toLocaleString();
}

export function formatFileSize(sizeBytes: number) {
  if (sizeBytes < 1024) {
    return `${sizeBytes} B`;
  }

  const kilobytes = sizeBytes / 1024;

  if (kilobytes < 1024) {
    return `${kilobytes.toLocaleString(undefined, { maximumFractionDigits: 1 })} KB`;
  }

  return `${(kilobytes / 1024).toLocaleString(undefined, { maximumFractionDigits: 1 })} MB`;
}

export function formatList(values: string[] | null | undefined, fallback = "--") {
  if (!values || values.length === 0) return fallback;
  return values.join(", ");
}

export function formatConfidence(value: number | null | undefined) {
  if (value == null) return "--";
  return `${Math.round(value * 100)}%`;
}

export function confidenceVariant(value: number | null | undefined): ConfidenceVariant {
  if (value == null) return "secondary";
  if (value < 0.65) return "destructive";
  if (value < 0.8) return "outline";
  return "secondary";
}

type ConfidenceVariant = "secondary" | "destructive" | "outline";
