FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    apache2 \
    libapache2-mod-security2 \
    curl wget nano net-tools iproute2

RUN a2enmod security2 headers rewrite

COPY ./security.conf /etc/apache2/conf-available/security.conf
RUN a2enconf security.conf

COPY ./modsecurity.conf /etc/modsecurity/modsecurity.conf
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
