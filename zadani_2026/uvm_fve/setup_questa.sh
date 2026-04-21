#!/usr/bin/env bash

# --- remove old ModelSim environment completely ---
unset MTI_VCO_MODE
unset MODELSIM
unset MODELSIM_LIBS
unset MODELSIM_VER
unset MODELSIM_DIR
unset MODEL_TECH

# --- remove old ModelSim from PATH ---
PATH=$(echo "$PATH" | tr ':' '\n' | grep -v ModelSIM | paste -sd ':' -)

# --- setup Questa ---
export QUESTA_HOME=/mnt/data/tools/questa/questasim.2025
export QSIM_INI="$QUESTA_HOME/questa.ini"
export QSIM_VCO_MODE=64

export SALT_LICENSE_SERVER=17170@semik.fit.vutbr.cz
export PATH="$QUESTA_HOME/bin:$QUESTA_HOME/linux_x86_64:$PATH"

echo "Clean Questa 2025 environment loaded."
