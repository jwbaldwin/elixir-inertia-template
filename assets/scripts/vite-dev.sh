#!/usr/bin/env bash
set -euo pipefail

PORT=5173

pids="$(lsof -tiTCP:${PORT} -sTCP:LISTEN || true)"
if [ -n "$pids" ]; then
	printf '%s\n' "$pids" | xargs kill -9
fi

exec bun vite --config vite.config.mjs --strictPort
