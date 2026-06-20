import * as React from "react";
import { Avatar as AvatarPrimitive } from "radix-ui";

import { cn } from "@/lib/utils";

interface AvatarSquare {
  x: number;
  y: number;
  fill: string;
  opacity: number;
}

interface AvatarModel {
  angle: number;
  end: string;
  squares: AvatarSquare[];
  start: string;
}

interface AvatarProps extends React.ComponentProps<typeof AvatarPrimitive.Root> {
  seed: string;
}

const VIEWBOX_SIZE = 100;
const GRID_SIZE = 24;
const CELL_SIZE = VIEWBOX_SIZE / GRID_SIZE;
const SQUARE_SIZE = CELL_SIZE * 0.7;
const SQUARE_OFFSET = (CELL_SIZE - SQUARE_SIZE) / 2;
const BAYER_4X4 = [
  [0, 8, 2, 10],
  [12, 4, 14, 6],
  [3, 11, 1, 9],
  [15, 7, 13, 5],
].map((row) => row.map((value) => value / 16));
const HUE_PALETTE = [328, 308, 278, 250, 222, 192, 152, 128, 104, 84, 56];

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function oklch(lightness: number, chroma: number, hue: number) {
  return `oklch(${(lightness * 100).toFixed(1)}% ${chroma.toFixed(3)} ${hue.toFixed(1)})`;
}

export function hashAvatarSeed(seed: string) {
  let hash = 2166136261;

  for (let index = 0; index < seed.length; index += 1) {
    hash ^= seed.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }

  return hash >>> 0;
}

export function buildAvatarModel(seed: string): AvatarModel {
  const safeSeed = seed.trim() || "anonymous";
  const hash = hashAvatarSeed(safeSeed);
  const baseHue = HUE_PALETTE[hash % HUE_PALETTE.length];
  const hue = baseHue + (((hash >> 8) % 7) - 3) * 2;
  const angle = 210 + (hash % 120);
  const radians = (angle * Math.PI) / 180;
  const directionX = Math.cos(radians);
  const directionY = Math.sin(radians);
  const focusX = 0.2 + ((hash >> 4) % 45) / 100;
  const focusY = 0.22 + ((hash >> 10) % 45) / 100;
  const lightDetail = oklch(0.93, 0.09, hue);
  const darkDetail = oklch(0.39, 0.15, hue);
  const squares: AvatarSquare[] = [];

  for (let row = 0; row < GRID_SIZE; row += 1) {
    for (let column = 0; column < GRID_SIZE; column += 1) {
      const normalizedX = (column + 0.5) / GRID_SIZE;
      const normalizedY = (row + 0.5) / GRID_SIZE;
      const gradientT = clamp(
        ((normalizedX - 0.5) * directionX + (normalizedY - 0.5) * directionY) * 0.95 + 0.5,
        0,
        1,
      );
      const distanceFromFocus = Math.hypot(normalizedX - focusX, normalizedY - focusY);
      const clusterT = clamp(1 - distanceFromFocus / 0.78, 0, 1);
      const density = clamp(gradientT * 0.62 + clusterT * 0.56 - 0.08, 0, 1);
      const threshold = BAYER_4X4[row % 4][column % 4];

      if (density <= threshold) {
        continue;
      }

      squares.push({
        x: column * CELL_SIZE + SQUARE_OFFSET,
        y: row * CELL_SIZE + SQUARE_OFFSET,
        fill: gradientT > 0.52 ? darkDetail : lightDetail,
        opacity: Number(clamp(0.45 + (density - threshold) * 0.75, 0.45, 0.95).toFixed(3)),
      });
    }
  }

  return {
    angle,
    start: oklch(0.84, 0.22, hue),
    end: oklch(0.54, 0.18, hue),
    squares,
  };
}

function AvatarRoot({ className, ...props }: React.ComponentProps<typeof AvatarPrimitive.Root>) {
  return (
    <AvatarPrimitive.Root
      data-slot="avatar"
      className={cn("relative flex size-10 shrink-0 overflow-hidden rounded-full", className)}
      {...props}
    />
  );
}

function AvatarImage({ className, ...props }: React.ComponentProps<typeof AvatarPrimitive.Image>) {
  return (
    <AvatarPrimitive.Image
      data-slot="avatar-image"
      className={cn("aspect-square size-full", className)}
      {...props}
    />
  );
}

function AvatarFallback({
  className,
  ...props
}: React.ComponentProps<typeof AvatarPrimitive.Fallback>) {
  return (
    <AvatarPrimitive.Fallback
      data-slot="avatar-fallback"
      className={cn(
        "flex size-full items-center justify-center rounded-full bg-muted text-muted-foreground",
        className,
      )}
      {...props}
    />
  );
}

function Avatar({ className, seed, ...props }: AvatarProps) {
  const instanceId = React.useId().replace(/:/g, "");
  const model = buildAvatarModel(seed);
  const gradientId = `${instanceId}-gradient`;
  const clipId = `${instanceId}-clip`;

  return (
    <AvatarRoot className={className} {...props}>
      <svg
        aria-hidden="true"
        className="h-full w-full"
        viewBox={`0 0 ${VIEWBOX_SIZE} ${VIEWBOX_SIZE}`}
      >
        <defs>
          <clipPath id={clipId}>
            <circle cx="50" cy="50" r="50" />
          </clipPath>
          <linearGradient
            id={gradientId}
            x1="0%"
            y1="0%"
            x2="100%"
            y2="100%"
            gradientTransform={`rotate(${model.angle} 0.5 0.5)`}
          >
            <stop offset="0%" stopColor={model.start} />
            <stop offset="100%" stopColor={model.end} />
          </linearGradient>
        </defs>

        <g clipPath={`url(#${clipId})`}>
          <rect width={VIEWBOX_SIZE} height={VIEWBOX_SIZE} fill={`url(#${gradientId})`} />

          {model.squares.map((square) => (
            <rect
              key={`${square.x}-${square.y}`}
              x={square.x}
              y={square.y}
              width={SQUARE_SIZE}
              height={SQUARE_SIZE}
              fill={square.fill}
              opacity={square.opacity}
              rx="0.35"
            />
          ))}
        </g>
      </svg>
    </AvatarRoot>
  );
}

export { Avatar, AvatarFallback, AvatarImage };
