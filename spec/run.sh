#!/usr/bin/env bash
set -euo pipefail

XVFB_PID=""

cleanup() {
    if [[ -n "${XVFB_PID}" ]]; then
        kill "${XVFB_PID}" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT

DISPLAY_VALUE="${DISPLAY:-:99}"
DISPLAY_NUM="$(printf '%s' "${DISPLAY_VALUE}" | sed -E 's/^:([0-9]+).*/\1/')"
if [[ -z "${DISPLAY_NUM}" ]]; then
    DISPLAY_NUM="99"
fi

DISPLAY_SOCKET="/tmp/.X11-unix/X${DISPLAY_NUM}"

if [[ ! -S "${DISPLAY_SOCKET}" ]]; then
    rm -f "/tmp/.X${DISPLAY_NUM}-lock"
    /usr/bin/Xvfb ":${DISPLAY_NUM}" -screen 0 1024x768x24 >/dev/null 2>&1 &
    XVFB_PID=$!

    for _ in {1..50}; do
        if [[ -S "${DISPLAY_SOCKET}" ]]; then
            break
        fi
        sleep 0.1
    done
fi

if [[ ! -S "${DISPLAY_SOCKET}" ]]; then
    echo "Failed to start Xvfb for DISPLAY=:${DISPLAY_NUM}" >&2
    exit 1
fi

export DISPLAY=":${DISPLAY_NUM}"

bundle exec rake spec
