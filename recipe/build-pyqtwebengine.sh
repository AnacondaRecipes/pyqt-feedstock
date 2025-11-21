set -exou

pushd pyqt_webengine

SIP_ARGS="
  --qmake-setting QMAKE_CC=${CC_FOR_BUILD}
  --qmake-setting QMAKE_CXX=${CXX_FOR_BUILD}
  --qmake-setting QMAKE_LINK=${CXX_FOR_BUILD}
"

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

    SIP_ARGS="${SIP_ARGS}
      --qmake-setting QMAKE_AR_CMD=${USED_BUILD_PREFIX}/bin/${HOST}-gcc-ar
      --qmake-setting QMAKE_INCDIR_OPENGL=${PREFIX}/include
      --qmake-setting QMAKE_LIBDIR_OPENGL=${PREFIX}/lib
    "
fi

if [[ $(uname) == "Darwin" ]]; then
    # Use xcode-avoidance scripts
    export PATH=$PREFIX/bin/xc-avoidance:$PATH
fi

sip-build ${SIP_ARGS} \
--verbose \
--no-make

pushd build

CPATH=$PREFIX/include make -j$CPU_COUNT
make install
