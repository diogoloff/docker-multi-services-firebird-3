#!/bin/bash

# Carrega as constantes de configuração 
set -e
source /docker_build/constantes
set -x

## Previne que atualizações tentem executar o grub e lilo.
## Alguns itens que serão instalados podem forçar a reinicialização do boot, 
## porem no Docker isto é um problema, já que o boot é controlado de outra forma
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

## Ativa os repositórios do Ubuntu Universe, Multiverse, e deb-src.
if grep -E '^ID=' /etc/os-release | grep -q ubuntu; then
  sed -i 's/^#\s*\(deb.*main restricted\)$/\1/g' /etc/apt/sources.list
  sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
  sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list
fi

## Atualiza o sistema de pacotes
apt-get update

## Corrige alguns erros do APT que são apresentados devido a estrutura de pastas do conteiner ser diferente
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Faz com que a ferramenta 'ischroot' sempre retorne true.
## Previne que atualizações de initscripts quebrem /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## apt-utils corrige wanings apresentados ao gerar a imagem já que iremos instalar alguns pacotes a mais
$minimal_apt_get_install apt-utils
