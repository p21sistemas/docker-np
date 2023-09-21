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
RUN apt-get -y install php8.2 php8.2-redis php8.2-fpm php8.2-common php8.2-curl \
php8.2-dev php8.2-mbstring php8.2-gd php8.2-json php8.2-redis php8.2-xml php8.2-zip \
php8.2-intl php8.2-mysql php8.2-exif php8.2-cli php8.2-soap

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
&& apt-get purge -y --auto-remove \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php8.2-fpm start && nginx -g "daemon off;"