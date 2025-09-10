echo on

pushd pyqt_webengine

set "PATH=%cd%\jom;%LIBRARY_LIB%\qt6\bin;%LIBRARY_INC%;%PATH%"
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

call sip-build ^
     --verbose ^
     --qmake=%LIBRARY_BIN%\qmake6.exe ^
     --target-dir %SP_DIR% ^
     --no-make
if %ERRORLEVEL% neq 0 exit 1

pushd build

jom
if %ERRORLEVEL% neq 0 exit 1
jom install
if %ERRORLEVEL% neq 0 exit 1
