set -exou

pushd pyqt_webengine

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
    export LDFLAGS="$SYSROOT_FLAGS $LDFLAGS"
fi

if [[ $(uname) == "Darwin" ]]; then
    # Use xcode-avoidance scripts
    export PATH=$PREFIX/bin/xc-avoidance:$PATH
    
    ## Fix Qt version compatibility issue (6.7.3 -> 6.7.2)
    #echo "Creating Qt version compatibility symlinks (6.7.3 -> 6.7.2)"
    #QT_MODULES=("Quick" "QmlModels" "OpenGL" "Gui" "WebChannel" "Qml" "Network" "Core" "WebChannelQuick" "PrintSupport" "Widgets")
    #
    #for module in "${QT_MODULES[@]}"; do
    #    source_lib="${PREFIX}/lib/libQt6${module}.6.7.3.dylib"
    #    target_lib="${PREFIX}/lib/libQt6${module}.6.7.2.dylib"
    #    
    #    if [ -f "${source_lib}" ] && [ ! -f "${target_lib}" ]; then
    #        echo "Creating symlink: ${target_lib} -> $(basename ${source_lib})"
    #        ln -sf "$(basename ${source_lib})" "${target_lib}"
    #    elif [ ! -f "${source_lib}" ]; then
    #        generic_lib="${PREFIX}/lib/libQt6${module}.dylib"
    #        if [ -f "${generic_lib}" ] && [ ! -f "${target_lib}" ]; then
    #            echo "Creating symlink from generic: ${target_lib} -> $(basename ${generic_lib})"
    #            ln -sf "$(basename ${generic_lib})" "${target_lib}"
    #        else
    #            echo "Warning: Cannot find source library for ${module}"
    #        fi
    #    fi
    #done
fi

# Ensure qmake is found.
export PATH=${PREFIX}/lib/qt6/bin:${PATH}

sip-build \
--verbose \
--no-make

pushd build

# For some reason SIP does not add the QtPrintSupport headers
cat QtWebEngineWidgets/Makefile | sed -r 's|INCPATH       =(.*)|INCPATH       =\1 -I'$PREFIX/include/qt/QtPrintSupport'|' > QtWebEngineWidgets/Makefile.temp
rm QtWebEngineWidgets/Makefile
mv QtWebEngineWidgets/Makefile.temp QtWebEngineWidgets/Makefile

CPATH=$PREFIX/include make -j$CPU_COUNT
make install
