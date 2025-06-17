#!/bin/bash
set -ex

# Ensure OpenGL libraries are findable
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}:${PREFIX}/lib/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/lib64/pkgconfig:$BUILD_PREFIX/$BUILD/sysroot/usr/share/pkgconfig
export LD_LIBRARY_PATH=${PREFIX}/lib:${LD_LIBRARY_PATH:-}
export LIBRARY_PATH=${PREFIX}/lib:${LIBRARY_PATH:-}

pushd pyqt
cp LICENSE ..

if [[ $(uname) == "Linux" ]]; then
    USED_BUILD_PREFIX=${BUILD_PREFIX:-${PREFIX}}
    echo USED_BUILD_PREFIX=${BUILD_PREFIX}

    ln -s ${GXX} g++ || true
    ln -s ${GCC} gcc || true
    ln -s ${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar gcc-ar || true

    export LD=${GXX}
    export CC=${GCC}
    export CXX=${GXX}
    export PKG_CONFIG_EXECUTABLE=$(basename $(which pkg-config))

    chmod +x g++ gcc gcc-ar
    export PATH=${PWD}:${PATH}

    # Add sysroot paths for OpenGL and X11
    SYSROOT_FLAGS="-L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 -L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
    SYSROOT_INCLUDES="-I ${BUILD_PREFIX}/${HOST}/sysroot/usr/include"
    
    export CFLAGS="$SYSROOT_FLAGS $SYSROOT_INCLUDES $CFLAGS"
    export CXXFLAGS="$SYSROOT_FLAGS $SYSROOT_INCLUDES $CXXFLAGS"
    export LDFLAGS="$SYSROOT_FLAGS $LDFLAGS -L${PREFIX}/lib"

    # Ensure OpenGL headers are found
    export CPATH="${PREFIX}/include:${BUILD_PREFIX}/${HOST}/sysroot/usr/include:${CPATH:-}"
elif [[ $(uname) == "Darwin" ]]; then
    # Use xcode-avoidance scripts
    export PATH=$PREFIX/bin/xc-avoidance:$PATH
    
    # macOS OpenGL framework paths
    export CFLAGS="-I/System/Library/Frameworks/OpenGL.framework/Headers $CFLAGS"
    export CXXFLAGS="-I/System/Library/Frameworks/OpenGL.framework/Headers $CXXFLAGS"
    export LDFLAGS="-framework OpenGL $LDFLAGS"
fi

# Ensure qmake is found.
export PATH=${PREFIX}/lib/qt6/bin:${PATH}

sip-build \
--verbose \
--confirm-license \
--no-make

pushd build

CPATH=$PREFIX/include make -j$CPU_COUNT
make install
