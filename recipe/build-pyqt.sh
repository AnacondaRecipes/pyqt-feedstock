#!/bin/bash
set -ex

pushd pyqt
cp LICENSE ..

export SIP_ARGS=""

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

    # TODO: Add --c_stdlib_version=${c_stdlib_version} once sip is updated.
    export SIP_ARGS="
      --qmake-setting QMAKE_LIBDIR=${PREFIX}/lib
      --qmake-setting QMAKE_INCDIR_OPENGL=${PREFIX}/include
    "
elif [[ $(uname) == "Darwin" ]]; then
    # Use xcode-avoidance scripts
    export PATH=$PREFIX/bin/xc-avoidance:$PATH

    # TODO: Add --minimum_macos_version=${c_stdlib_version} once sip is updated.
    export SIP_ARGS="
      --qmake-setting QMAKE_MAC_SDK=macosx${OSX_SDK_VER}
    "
fi

sip-build ${SIP_ARGS} \
--qmake=${PREFIX}/bin/qmake6 \
--verbose \
--confirm-license \
--no-make

pushd build

CPATH=$PREFIX/include make -j$CPU_COUNT
make install
