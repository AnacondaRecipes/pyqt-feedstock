#!/usr/bin/env bash

# ROOT=${TMPDIR}
ROOT=/tmp
OLD=${ROOT}/pyqt5old
NEW=${ROOT}/pyqt5new
VERBO=1000
if [[ 0 == 1 ]]; then
rm -rf ${OLD} ${NEW} || true
conda create -yp ${OLD} pyqt=5.9.2
conda create -yp ${NEW} pyqt=5.11.3 -c local
fi

# /opt/conda/bin/activate ${OLD}
DYLD_PRINT_LIBRARIES=1 PYTHONDEBUG=${VERBO} PYTHONVERBOSE=${VERBO} ${OLD}/bin/python -c "from PyQt5.QtWidgets import QApplication" 2>&1 | tee ${OLD}/import.log
sudo dtruss ${OLD}/bin/python -c "from PyQt5.QtWidgets import QApplication" 2>&1 | tee ${OLD}/dtruss.log

# /opt/conda/bin/activate ${NEW}
DYLD_PRINT_LIBRARIES=1 PYTHONDEBUG=${VERBO} PYTHONVERBOSE=${VERBO} ${NEW}/bin/python -c "from PyQt5.QtWidgets import QApplication" 2>&1 | tee ${NEW}/import.log
sudo dtruss ${NEW}/bin/python -c "from PyQt5.QtWidgets import QApplication" 2>&1 | tee ${NEW}/dtruss.log
