# Imagen base con Nginx y ModSecurity v3
FROM owasp/modsecurity:nginx

# Copiar archivo de configuración de seguridad del sitio
COPY ./security.conf /etc/nginx/conf.d/security.conf

# Copiar configuración de ModSecurity
COPY ./modsec/modsecurity.conf /etc/nginx/modsec/modsecurity.conf
COPY ./modsec/unicode.mapping /etc/nginx/modsec/unicode.mapping

# Copiar OWASP CRS (Core Rule Set)
COPY ./modsec/crs /etc/nginx/modsec/crs

# Eliminar el sitio por defecto de Nginx
RUN rm -f /etc/nginx/conf.d/default.conf \
    && rm -f /etc/nginx/templates/conf.d/default.conf.template

# Exponer el puerto 80
EXPOSE 80

# Comando para ejecutar Nginx
CMD ["nginx", "-g", "daemon off;"]
