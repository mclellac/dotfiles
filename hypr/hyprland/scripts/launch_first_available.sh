#!/usr/bin/env bash
for cmd in "$@"; do
    eval "command -v ${cmd%% *}" >/dev/null 2>&1 || continue
    eval "LIBGL_ALWAYS_SOFTWARE=1 $cmd" &
    exit
done
exit 1
