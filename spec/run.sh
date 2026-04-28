#!/usr/bin/env bash
set -euo pipefail

XVFB_PID=""

cleanup() {
    if [[ -n "${XVFB_PID}" ]]; then
        kill "${XVFB_PID}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

if [[ -z "${DISPLAY:-}" ]]; then
    rm -f /tmp/.X99-lock
    /usr/bin/Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &
    XVFB_PID=$!
    export DISPLAY=:99

    for _ in {1..50}; do
        if [[ -S /tmp/.X11-unix/X99 ]]; then
            break
        fi
        sleep 0.1
    done
fi

bundle exec rake spec
