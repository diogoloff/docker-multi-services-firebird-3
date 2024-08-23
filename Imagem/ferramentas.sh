#!/bin/bash

# Carrega as constantes de configuração 
set -e
source /docker_build/constantes
set -x

# Obrigatorios
# Instala suporte a HTTPS para o APT.
# Instala o software-properties-common este cara gerencia de forma organizada repositórios e chaves se for instalar SSH é necessário
# runit gerenciamento e controle de serviços simplificado
# psmisc para permitir o gerenciamento do kill por arvore de processos
$minimal_apt_get_install apt-transport-https ca-certificates software-properties-common runit psmisc

# Opcionais
# curl para permitir donwloads via http
# tar para permitir descompactar arquivos
# nano editor de texto
$minimal_apt_get_install curl tar nano

## script simplifica o apt para instalar pacotes de forma limpa
cp /docker_build/bin/apt_install_clean /sbin/apt_install_clean
