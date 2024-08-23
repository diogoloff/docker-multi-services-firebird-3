#!/bin/bash

## Este arquivo instala um sistema de controle de serviços customizado baseado no runit, que é um controle minimalista e robusto para serviços
## em sistemas linux compactos.
## Ele é composto em resumo:
## 		/etc/my_init.d pasta onde os scripts para rodar os serviços ficarão é uma analogia ao /etc/init.d
##      /etc/my_init.pre_shutdown.d pasta onde ficam scripts que dependendo da aplicação precisam ser executados antes de a mesma ser derrubada
##      /etc/my_init.post_shutdown.d pasta onde ficam scripts que dependendo da aplicação precisam ser executados após a mesma ser derrubada
##
##
## No geral se analisarmos a /etc/init.d os arquivos padrão de inicialização de serviços ainda estarão lá
## porem ao iniciarmos o conteiner iremos procurar nesta pasta customizada os scripts que são resumidos a basicamente iniciar a aplicação
## coisa que se fizermos com service NomeServico start diretamente na inicialização do container iremos acabar atribuindo PID 1 para o primeiro
## serviço e isto não queremos pois justamente não podemos ter um serviço especifico da nossa aplicação atrelado a isto já que iremos utilizar
## este conteiner para rodar mais de um serviço, se isto acontece, temos um problema relacionado ao Kill ao encerrar o conteiner onde o mesmo
## não irá encerrar todos os serviços corretamente o que poderá causar problemas indesejados como até corrupção de dados.
##
## Neste momento do encerramento que entra os demais scripts nas pastas como /etc/my_init.pre_shutdown.d /etc/my_init.post_shutdown.d onde
## permitirá uma cutomização maior no sinal que queremos levar a cada aplicação que será encerrada no ato de finalização do conteiner

## Instalando e criando o sistema de inicialização
cp /docker_build/bin/my_init /sbin/
mkdir -p /etc/my_init.d
mkdir -p /etc/my_init.pre_shutdown.d
mkdir -p /etc/my_init.post_shutdown.d
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## This tool runs a command as another user and sets $HOME.
cp /docker_build/bin/setuser /sbin/setuser

## Como iremos trabalhar com mais de um serviço também é ideal termos o sistema de log ativo, syslog e logrotate.
/docker_build/syslog-ng/syslog-ng.sh
