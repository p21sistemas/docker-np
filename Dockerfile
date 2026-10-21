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

## Repetir downloads que falham (o PPA devolve 503 quando sobrecarregado)
RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries

## Adicionando repositório PHP
RUN add-apt-repository -y ppa:ondrej/php && apt-get update

## Instalando PHP e extensões
RUN apt-get -y install php8.0 php8.0-fpm php8.0-cli php8.0-common php8.0-curl \
php8.0-dev php8.0-mbstring php8.0-gd php8.0-redis php8.0-xml php8.0-zip \
php8.0-intl php8.0-mysql php8.0-soap php8.0-bcmath php8.0-imagick

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php8.0-fpm start && nginx -g "daemon off;"
