import { cn } from "@/lib/utils";

export type StatusBadgeVariant = "dashed" | "half";

export type StatusBadgeColor = "lime" | "amber" | "sky" | "rose" | "violet" | "zinc" | "indigo";

interface StatusBadgeProps {
  variant: StatusBadgeVariant;
  color?: StatusBadgeColor;
  orientation?: "vertical" | "horizontal";
  className?: string;
}

const STATUS_COLORS: Record<
  StatusBadgeColor,
  {
    fill: string;
    hex: string;
    hexLight: string;
  }
> = {
  lime: {
    fill: "bg-lime-500",
    hex: "#84cc16",
    hexLight: "#d9f99d",
  },
  amber: {
    fill: "bg-amber-500",
    hex: "#f59e0b",
    hexLight: "#fde68a",
  },
  sky: {
    fill: "bg-sky-500",
    hex: "#0ea5e9",
    hexLight: "#bae6fd",
  },
  rose: {
    fill: "bg-rose-500",
    hex: "#f43f5e",
    hexLight: "#fecdd3",
  },
  violet: {
    fill: "bg-violet-500",
    hex: "#8b5cf6",
    hexLight: "#ddd6fe",
  },
  zinc: {
    fill: "bg-zinc-400",
    hex: "#a1a1aa",
    hexLight: "#e4e4e7",
  },
  indigo: {
    fill: "bg-indigo-500",
    hex: "#6366f1",
    hexLight: "#c7d2fe",
  },
};

/* ── Variant: dashed ring + center dot ───────────────────────────────────── */

function DashedRing({ color }: { color: StatusBadgeColor }) {
  const c = STATUS_COLORS[color];

  return (
    <span aria-hidden="true" className="relative grid size-4 place-items-center">
      <svg className="absolute inset-0 size-full" viewBox="0 0 16 16">
        <circle
          cx="8"
          cy="8"
          r="7"
          fill="none"
          stroke={c.hex}
          strokeDasharray="3 3"
          strokeLinecap="round"
          strokeWidth="1.5"
        />
      </svg>
      <span className={cn("size-2 rounded-full", c.fill)} />
    </span>
  );
}

/* ── Variant: half-filled circle ────────────────────────────────────────── */

function HalfFill({
  color,
  orientation,
}: {
  color: StatusBadgeColor;
  orientation: "vertical" | "horizontal";
}) {
  const c = STATUS_COLORS[color];
  const darkHalfPath =
    orientation === "vertical" ? "M8 0 A8 8 0 0 0 8 16 L8 0 Z" : "M0 8 A8 8 0 0 1 16 8 L0 8 Z";
  const lightHalfPath =
    orientation === "vertical" ? "M8 0 A8 8 0 0 1 8 16 L8 0 Z" : "M0 8 A8 8 0 0 0 16 8 L0 8 Z";

  return (
    <svg aria-hidden="true" className="size-4" viewBox="0 0 16 16">
      <path d={darkHalfPath} fill={c.hex} />
      <path d={lightHalfPath} fill={c.hexLight} />
      <circle cx="8" cy="8" r="7.25" fill="none" stroke={c.hex} strokeWidth="1.5" />
    </svg>
  );
}

/* ── Public component ───────────────────────────────────────────────────── */

export function StatusBadge({
  variant,
  color = "lime",
  orientation = "vertical",
  className,
}: StatusBadgeProps) {
  return (
    <span className={cn("inline-flex items-center justify-center", className)}>
      {variant === "dashed" && <DashedRing color={color} />}
      {variant === "half" && <HalfFill color={color} orientation={orientation} />}
    </span>
  );
}
