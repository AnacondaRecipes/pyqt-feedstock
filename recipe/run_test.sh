#!/bin/bash

if [[ "${PKG_NAME}" == pyqt ]]; then
  ${PYTHON} ${RECIPE_DIR}/check_imports_pyqt.py

  test -f ${PREFIX}/bin/pyuic6 || (echo "FATAL: Failed to find pyuic6" && exit 1)
  pyuic6 --version

  # Test OpenGL functionality
  if [[ "${target_platform}" == linux-* ]]; then
    # Check if OpenGL is available
    ${PYTHON} -c "from PyQt6.QtOpenGL import QOpenGLWidget; print('OpenGL support is available')" || echo "Warning: OpenGL support may not be available"
  fi

  # we don't have xvfb on our builders ... so we might ignore it ..
  DISPLAY=localhost:1.0 xvfb-run -a bash -c 'python pyqt_test.py' || true
else
  ${PYTHON} ${RECIPE_DIR}/check_imports_pyqtwebengine.py
fi
