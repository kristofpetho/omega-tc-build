#!/usr/bin/env bash

set -eo pipefail

# Function to show an informational message
function msg() {
    echo -e "\e[1;32m$@\e[0m"
}

# Build LLVM
msg "Building LLVM..."
./build-llvm.py \
	--branch "llvmorg-12.0.0" \
	--clang-vendor "Omega" \
	--defines CMAKE_C_FLAGS="-march=native -mtune=native" CMAKE_CXX_FLAGS="-march=native -mtune=native" \
	--targets "AArch64"

# Build binutils
msg "Building binutils..."
./build-binutils.py \
	--targets aarch64 \
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
rm -rf binutils-2.36.1 && rm -rf build && rm -rf llvm-project && rm -rf __pycache__ && rm install/.gitignore
