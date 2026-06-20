import { format, parseISO } from "date-fns";

export function formatInvitationDateTime(value: string | null) {
  if (!value) {
    return "--";
  }

  try {
    return format(parseISO(value), "MMM d, yyyy");
  } catch {
    return "--";
  }
}

export function formatInvitationLabel(value: string) {
  return value
    .split("_")
    .map((segment) => `${segment.charAt(0).toUpperCase()}${segment.slice(1)}`)
    .join(" ");
}
