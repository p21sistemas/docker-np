FROM ubuntu:24.04

## Sem interação humana
ARG DEBIAN_FRONTEND=noninteractive

## Repetir downloads que falham (o PPA devolve 503 quando sobrecarregado)
RUN echo 'Acquire::Retries "10";' > /etc/apt/apt.conf.d/80-retries

## Atualizando sistema operacional
RUN apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade

## Instalando pacotes essenciais
RUN apt-get -y install apt-utils software-properties-common curl gnupg bash-completion \
               vim nano git zip unzip supervisor locales tzdata

## Configurar fuso horário e locale
RUN ln -f -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN locale-gen pt_BR.UTF-8

## Instalar NGINX
#RUN apt-get -y install nginx

## Adicionando repositório PHP
RUN add-apt-repository -y ppa:ondrej/php && apt-get update

## Instalando PHP e extensões
RUN apt-get -y install php8.0 php8.0-fpm php8.0-cli php8.0-common php8.0-curl \
php8.0-dev php8.0-mbstring php8.0-gd php8.0-redis php8.0-xml php8.0-zip \
php8.0-intl php8.0-mysql php8.0-soap php8.0-bcmath php8.0-imagick php8.0-opcache php-pear

## Garantir que php/phpize/php-config apontem para o 8.0 (o php-pear pode puxar outra versão)
RUN update-alternatives --set php /usr/bin/php8.0 \
    && update-alternatives --set phpize /usr/bin/phpize8.0 \
    && update-alternatives --set php-config /usr/bin/php-config8.0

## Adicionando repositório da Microsoft (driver ODBC do SQL Server)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/prod.list \
      > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update

## Instalando driver ODBC 18 e ferramentas (sqlcmd/bcp)
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql18 mssql-tools18 unixodbc-dev
ENV PATH="${PATH}:/opt/mssql-tools18/bin"

## Instalando sqlsrv e pdo_sqlsrv (5.11.1 é a última versão compatível com PHP 8.0)
RUN pecl -d php_suffix=8.0 install sqlsrv-5.11.1 pdo_sqlsrv-5.11.1 \
    && printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini \
    && phpenmod -v 8.0 sqlsrv pdo_sqlsrv

## Instalando LibreOffice e unoconv (via apt, pip global é bloqueado pela PEP 668)
RUN apt-get -y install --no-install-recommends libreoffice unoconv

# Xdebug
RUN apt-get -y install php8.0-xdebug

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
    && apt-get purge -y --auto-remove \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.0/fpm/pool.d/www.conf \
    && sed -i 's|^;clear_env = no|clear_env = no|' /etc/php/8.0/fpm/pool.d/www.conf \
    && mkdir -p /run/php

CMD ["sh", "-c", "exec php-fpm8.0 -F"]


