FROM ubuntu:24.04

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
RUN apt-get -y install php8.4 php8.4-redis php8.4-fpm php8.4-common php8.4-curl \
php8.4-dev php8.4-mbstring php8.4-gd php8.4-redis php8.4-xml php8.4-zip \
php8.4-intl php8.4-mysql php8.4-exif php8.4-cli php8.4-soap php8.4-bcmath php8.4-imagick

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
&& apt-get purge -y --auto-remove \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php8.4-fpm start && nginx -g "daemon off;"