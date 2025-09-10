if "%PKG_NAME%" == "pyqt" (
    %PYTHON% %RECIPE_DIR%/check_imports.py
    if errorlevel 1 exit 1

    if not exist %PREFIX%\\Scripts\\pyuic6.exe (echo "FATAL: Failed to find %PREFIX%\\Scripts\\pyuic6.exe" && exit 1)

    pyuic6 --version
    if errorlevel 1 exit 1
) else (
    %PYTHON% %RECIPE_DIR%/check_imports_pyqtwebengine.py
    if errorlevel 1 exit 1
)
