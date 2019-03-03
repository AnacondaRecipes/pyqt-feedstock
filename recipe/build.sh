#!/bin/bash

set -x
set -e # Abort on error.

# Doing this results in:
# Traceback (most recent call last):
#   File "<string>", line 1, in <module>
# ValueError: PyCapsule_GetPointer called with incorrect name
# .. from QtWebSockets/sipQtWebSocketscmodule.cpp
# mkdir -p ${SP_DIR}/PyQt5
# pushd ${SP_DIR}/PyQt5
#   ln -s ../sip.so sip.so
#   ln -s ../sip.pyi sip.pyi
# popd
# .. instead sip probably needs to be compiled with --sip-module=PyQt5.sip

declare -a _extra_modules
# Avoid Xcode
if [[ ${HOST} =~ .*darwin.* ]]; then
  PATH=${PREFIX}/bin/xc-avoidance:${PATH}
    _extra_modules+=(--enable)
    _extra_modules+=(QtMacExtras)
else
    _extra_modules+=(--enable)
    _extra_modules+=(QtX11Extras)
fi

# Dumb .. is this Qt or PyQt's fault? (or mine, more likely).
# The spec file could be bad, or PyQt could be missing the
# ability to set QMAKE_CXX
mkdir bin || true
pushd bin
  ln -s ${GXX} g++ || true
  ln -s ${GCC} gcc || true
popd
export PATH=${PWD}/bin:${PATH}

# We cannot use a 'normal' sip anymore since the sip used by PyQt > 5.11 must be
# built with --sip-module PyQt5.sip. This is really annoying. It is unclear whether
# a 'normal' sip can be installed and used alongside PyQt, either in tandem or not.
pushd sip
  ${PYTHON} configure.py    \
    --sysroot=${PREFIX}     \
    --sip-module PyQt5.sip
  make -j${CPU_COUNT}
  make install
popd

## Future:
#        --enable Qt3DAnimation \
#        --enable Qt3DCore \
#        --enable Qt3DExtras \
#        --enable Qt3DInput \
#        --enable Qt3DLogic \
#        --enable Qt3DRender \
#        --sip-module PyQt5.sip \

## START BUILD
$PYTHON configure.py \
        --verbose \
        --target-py-version ${PY_VER} \
        --concatenate \
        --confirm-license \
        --assume-shared \
        --enable QtWidgets \
        --enable QtGui \
        --enable QtCore \
        --enable QtHelp \
        --enable QtMultimediaWidgets \
        --enable QtNetwork \
        --enable QtXml \
        --enable QtXmlPatterns \
        --enable QtDBus \
        --enable QtWebSockets \
        --enable QtWebChannel \
        --enable QtWebEngineWidgets \
        --enable QtNfc \
        --enable QtWebEngineCore \
        --enable QtWebEngine \
        --enable QtOpenGL \
        --enable QtQml \
        --enable QtQuick \
        --enable QtQuickWidgets \
        --enable QtSql \
        --enable QtSvg \
        --enable QtDesigner \
        --enable QtPrintSupport \
        --enable QtSensors \
        --enable QtTest \
        --enable QtBluetooth \
        --enable QtLocation \
        --enable QtPositioning \
        --enable QtSerialPort \
        "${_extra_modules[@]}" \
        -q ${PREFIX}/bin/qmake
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

echo "TEST :: Running with vendored sip still present"
${PYTHON} -c "from PyQt5.QtWidgets import QApplication"

# These files will conflict with a 'normal' sip, so in-case we need a 'normal' sip
# we must make sure PyQt doesn't end up with them too.
pushd sip
  INCLUDEPY=$(${PYTHON} -c "import sys, sysconfig; sys.stdout.write(sysconfig.get_config_var('INCLUDEPY'))")
  rm ${INCLUDEPY}/sip.h
  rm ${PREFIX}/bin/sip
  rm ${SP_DIR}/sipdistutils.py
  rm ${SP_DIR}/sipconfig.py
popd

echo "TEST :: Running with vendored sip removed"
${PYTHON} -c "from PyQt5.QtWidgets import QApplication"
