# A composição desta Imagem tem como base o repositório 
# https://github.com/phusion/baseimage-docker licença de uso MIT no repositório 
# original em 23/08/2024.

# Cabe agradecimento ao criador original "Phusion Holding B.V." pois além de disponibilizar
# os scripts necessários de forma gratuita o mesmo resolve 2 problemas complexos na crianção de conteineres
# docker, que é um conteiner com vários serviços, e também o controle do encerramento
# seguro de todos serviços, já que possibilita uma customização personalizada a isto de forma simples.

# Baixa a imagem do ubuntu basica
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C

# Esta copiando todos os arquivos que estão na raiz da imagem para a pasta em questão 
# esta pasta funciona como uma pasta temporaria, aqui por exemplo podem ser colocados script para
# serem executados posterior a imagem, ou durante a imagem
COPY . /docker_build

# Roda os arquivos de configuração e preparação do sistema
# Nesta parte para adicionar serviços extras junto da imagem, bastaria criar scripts adicionais para
# serem executados entre servicos.sh e limpeza.sh
RUN /docker_build/base.sh && \
	/docker_build/regiao.sh && \
	/docker_build/ferramentas.sh && \
	/docker_build/servicos.sh && \
	/docker_build/firebird/preparacao.sh && \
	/docker_build/firebird/instalacao.sh && \
    /docker_build/limpeza.sh

ENV DEBIAN_FRONTEND="teletype" \
    LANG="pt_BR.UTF-8" \
    LANGUAGE="pt_BR:pt" \
    LC_ALL="pt_BR.UTF-8"
