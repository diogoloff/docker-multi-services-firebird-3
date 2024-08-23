#!/bin/bash
set -e
source /docker_build/constantes
set -x

apt-get clean
find /docker_build/ -not \( -name 'docker_build' -or -name 'constantes' -or -name 'limpeza.sh' \) -delete
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*

# clean up python bytecode
find / -mount -name *.pyc -delete
find / -mount -name *__pycache__* -delete

rm -f /etc/ssh/ssh_host_*

## Atualiza todos os pacotes instalados, e também acaba por limpar o o apt para  digamos o minimo necessário
## em caso de novas instalações será necessário realizar o apt-get update caso um pacote não seja encontrado
apt-get dist-upgrade -y --no-install-recommends -o Dpkg::Options::="--force-confold"
