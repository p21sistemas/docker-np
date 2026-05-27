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
RUN apt-get -y install php8.3 php8.3-redis php8.3-fpm php8.3-common php8.3-curl \
php8.3-dev php8.3-mbstring php8.3-gd php8.3-redis php8.3-xml php8.3-zip \
php8.3-intl php8.3-mysql php8.3-exif php8.3-cli php8.3-soap php8.3-bcmath php8.3-imagick

## Customização OpenSSL: relaxa SECLEVEL e MinProtocol pra handshakes legados
## (CRA Nacional, Cenprot, BB, Aarin). Apenas append ao cnf default do Ubuntu 24.04.
RUN printf '\n[openssl_init]\nssl_conf = ssl_sect\n\n[ssl_sect]\nsystem_default = system_default_sect\n\n[system_default_sect]\nMinProtocol = TLSv1\nCipherString = DEFAULT:@SECLEVEL=1\n' >> /etc/ssl/openssl.cnf

## Customização ImageMagick: libera operações com PDF (necessário pra spatie/pdf-to-image
## em rotinas de Instrumento). Aplica em ambas paths possíveis (6 e 7) — falha silenciosa
## se a versão não estiver instalada.
RUN sed -i "s|PDF|XPS|g" /etc/ImageMagick-6/policy.xml 2>/dev/null || true
RUN sed -i "s|PDF|XPS|g" /etc/ImageMagick-7/policy.xml 2>/dev/null || true

## Baixar última versão do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

## Limpar
RUN rm -rf /tmp/pear \
&& apt-get purge -y --auto-remove \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD service php8.3-fpm start && nginx -g "daemon off;"