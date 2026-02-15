echo on

pushd pyqt
copy LICENSE ..

set "PATH=%LIBRARY_LIB%\qt6\bin;%LIBRARY_INC%;%PATH%"

call sip-build ^
    --verbose ^
    --confirm-license ^
    --qmake=%LIBRARY_BIN%\qmake6.exe ^
    --disable QtNfc ^
    --no-dbus-python ^
    --target-dir %SP_DIR% ^
    --no-make
if %ERRORLEVEL% neq 0 exit 1

pushd build

nmake
if %ERRORLEVEL% neq 0 exit 1
nmake install
if %ERRORLEVEL% neq 0 exit 1

popd
popd