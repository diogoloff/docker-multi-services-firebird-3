#!/bin/bash

# Carrega as constantes de configuração 
set -e
source /docker_build/constantes
set -x

FIREBIRD_BUILD_PATH=/docker_build/firebird

# baixando o firebird para a pasta /tmp
curl -L ${FB_URL} | tar -zxC /docker_build
cp $FIREBIRD_BUILD_PATH/install.sh /docker_build/${FB_DIR}/install.sh
cd /docker_build/${FB_DIR}
chmod +x install.sh
./install.sh -silent
cd /

cp $FIREBIRD_BUILD_PATH/firebird.init /etc/my_init.d/20_firebird.init
cp $FIREBIRD_BUILD_PATH/firebird.shutdown /etc/my_init.pre_shutdown.d/80_firebird.shutdown
