#!/bin/bash

## Este arquivo corrige questões relacionadas a idioma e fuso horario para o padrão BR
## No docker a questão de idioma e fuso horario não são possivel de modificar no conteiner
## mesmo que em tempo de execução seja possivel, quando o mesmo é reiniciado as configurações
## são todas perdidas voltando ao padrão da imagem

# Carrega as constantes de configuração 
set -e
source /docker_build/constantes
set -x

## Instala e configura o pacote de idioma pt_BR
$minimal_apt_get_install language-pack-pt

locale-gen pt_BR
update-locale LANG=pt_BR.UTF-8 LC_CTYPE=pt_BR.UTF-8
echo -n pt_BR.UTF-8 > /etc/container_environment/LANG
echo -n pt_BR.UTF-8 > /etc/container_environment/LC_CTYPE

## Instala e corrige o fuso horario
$minimal_apt_get_install tzdata
ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
