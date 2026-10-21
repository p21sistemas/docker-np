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
RUN apt-get -y install php7.3 php7.3-fpm php7.3-cli php7.3-common php7.3-curl \
php7.3-dev php7.3-mbstring php7.3-gd php7.3-json php7.3-redis php7.3-xml php7.3-zip \
php7.3-intl php7.3-mysql php7.3-soap php7.3-bcmath php7.3-imagick

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php7.3-fpm start && nginx -g "daemon off;"
