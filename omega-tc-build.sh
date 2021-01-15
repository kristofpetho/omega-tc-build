#!/usr/bin/env bash

set -euo pipefail

# Function to show an informational message
function msg() {
    echo -e "\e[1;32m$@\e[0m"
}

# Build LLVM
msg "Building LLVM..."
./build-llvm.py \
	--clang-vendor "Omega" \
	--march native \
	--targets AArch64 \
	--use-good-revision

# Build binutils
msg "Building binutils..."
./build-binutils.py \
	--targets aarch64-linux-gnu \
	--march native

# Remove unused products
msg "Removing unused products..."
rm -fr install/include
rm -f install/lib/*.a install/lib/*.la

# Strip remaining products
msg "Stripping remaining products..."
for f in $(find install -type f -exec file {} \; | grep 'not stripped' | awk '{print $1}'); do
	strip ${f: : -1}
done

# Remove working directories
msg "Removing working directories..."
rm -rf binutils-2.35.1 && rm -rf build && rm -rf llvm-project && rm -rf __pycache__ && rm install/.gitignore
