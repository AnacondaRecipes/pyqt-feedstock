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

    SYSROOT_FLAGS="-L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64 -L ${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
    
    export CFLAGS="$SYSROOT_FLAGS $CFLAGS"
    export CXXFLAGS="$SYSROOT_FLAGS $CXXFLAGS"
    export LDFLAGS="$SYSROOT_FLAGS $LDFLAGS -L${PREFIX}/lib"
elif [[ $(uname) == "Darwin" ]]; then
    # Use xcode-avoidance scripts
    export PATH=$PREFIX/bin/xc-avoidance:$PATH
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
