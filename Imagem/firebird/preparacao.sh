#!/bin/bash

# Carrega as constantes de configuração 
set -e
source /docker_build/constantes
set -x

# libs necessárias para o FB
$minimal_apt_get_install libicu74

$minimal_apt_get_install libncurses6 

$minimal_apt_get_install libtommath1

# links para bibliotecas devido a troca de versão
ln -s /usr/lib/x86_64-linux-gnu/libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0
ln -s /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
