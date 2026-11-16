#!/bin/bash
# Build everything locally: binaries for both architectures and the source package.
# Usage: ./build.sh <tmux_version> <build_version>
set -euo pipefail
./build_debian.sh "$1" "$2" all
./build_src.sh "$1" "$2"
