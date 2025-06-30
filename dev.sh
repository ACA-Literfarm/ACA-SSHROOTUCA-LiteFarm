#!/usr/bin/env bash
set -eu

# Helper to run a command in a subdirectory and echo its context
run_in_dir() {
  local dir="$1"
  shift
  pushd "$dir" >/dev/null
  echo "[$dir] $*"
  "$@"
  popd >/dev/null
}

# Make sure the individual packages have their node_modules present
run_in_dir packages/api npm install --force 
run_in_dir packages/webapp npm install --force

# Ensure background processes are cleaned up when the script exits
cleanup() {
  echo "\nShutting down dev processes…"
  kill 0
}
trap cleanup EXIT INT TERM

echo "\nStarting development servers…"

# Start both dev servers concurrently
(
  run_in_dir packages/api npm run dev
) &

(
  run_in_dir packages/webapp npm run dev
) &

# Wait on background jobs so the script keeps running and streams logs
wait 