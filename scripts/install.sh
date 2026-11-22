#!/usr/bin/env sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo=$(CDPATH= cd -- "$script_dir/.." && pwd)
bin_dir=${HOME:?HOME must be set}/bin

if [ ! -d "$bin_dir" ];
then
  mkdir -p "$bin_dir"
fi

ln -sf "$repo/entrypoint" "$bin_dir/claude-box"
ln -sf "$repo/entrypoint" "$bin_dir/codex-box"
