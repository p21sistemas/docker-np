FROM ubuntu:20.04

## Sem interação humana
ARG DEBIAN_FRONTEND=noninteractive

## Atualizando sistema operacional
RUN apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade

## Instalando pacotes essenciais
RUN apt-get -y install apt-utils software-properties-common curl bash-completion \
               vim git zip unzip supervisor locales

## Configurar fuso horário e locale
RUN ln -f -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN locale-gen pt_BR.UTF-8

## Instalar NGINX
RUN apt-get -y install nginx

## Adicionando repositório PHP
RUN add-apt-repository -y ppa:ondrej/php && apt-get update

## Instalando PHP e extensões
RUN apt-get -y install php7.4 php7.4-redis php7.4-fpm php7.4-common php7.4-curl \
php7.4-dev php7.4-mbstring php7.4-gd php7.4-json php7.4-redis php7.4-xml php7.4-zip \
php7.4-intl php7.4-mysql php7.4-exif php7.4-cli php7.4-soap

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php7.4-fpm start && nginx -g "daemon off;"