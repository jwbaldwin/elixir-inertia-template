import {
  StatusBadge,
  type StatusBadgeColor,
  type StatusBadgeVariant,
} from "@/components/ui/status-badge";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";

interface StatusConfig {
  color: StatusBadgeColor;
  text: string;
}

interface StatusProps {
  status?: string | null;
  text?: string;
  variant?: StatusBadgeVariant;
}

export const appStatusConfig = {
  accepted: { color: "lime", text: "Accepted" },
  active: { color: "sky", text: "Active" },
  awaiting_response: { color: "amber", text: "Awaiting response" },
  cancelled: { color: "zinc", text: "Cancelled" },
  complete: { color: "lime", text: "Complete" },
  completed: { color: "lime", text: "Completed" },
  delivered: { color: "lime", text: "Delivered" },
  disabled: { color: "zinc", text: "Disabled" },
  document_analysis: { color: "indigo", text: "Analyze documents" },
  document_detection: { color: "sky", text: "Detect documents" },
  document_splitting: { color: "indigo", text: "Split documents" },
  draft: { color: "zinc", text: "Draft" },
  failed: { color: "rose", text: "Failed" },
  needs_review: { color: "amber", text: "Needs review" },
  pending: { color: "zinc", text: "Pending" },
  processing: { color: "sky", text: "Processing" },
  queued: { color: "sky", text: "Queued" },
  received: { color: "lime", text: "Received" },
  rejected: { color: "rose", text: "Rejected" },
  responded: { color: "lime", text: "Responded" },
  review_ready: { color: "lime", text: "Review ready" },
  running: { color: "sky", text: "Running" },
  sent: { color: "sky", text: "Sent" },
} satisfies Record<string, StatusConfig>;

export function Status({ status, text, variant = "half" }: StatusProps) {
  const config = status ? appStatusConfig[status as keyof typeof appStatusConfig] : undefined;
  const label = config?.text ?? text;
  const badge = <StatusBadge variant={variant} color={config?.color ?? "zinc"} />;

  if (!label) {
    return badge;
  }

  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <span className="inline-flex">{badge}</span>
      </TooltipTrigger>
      <TooltipContent>
        <p>{label}</p>
      </TooltipContent>
    </Tooltip>
  );
}
