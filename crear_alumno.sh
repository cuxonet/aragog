#!/bin/bash

# Verificar ejecución como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root o con sudo."
    exit 1
fi

# Función para encontrar el siguiente puerto disponible a partir de 8080
buscar_puerto_libre() {
    puerto=8080
    while sudo lsof -i TCP:$puerto -sTCP:LISTEN >/dev/null 2>&1; do
        puerto=$((puerto+1))
    done
    echo $puerto
}

# Pedir datos del alumno
read -p "Nombre completo del alumno: " nombre_alumno
read -p "UO del alumno (ejemplo UO308677): " uo

# Elegir tipo de servidor
echo "Seleccione tipo de servidor:"
echo "1) Apache"
echo "2) Nginx"
read -p "Opción (1 o 2): " opcion

if [ "$opcion" == "1" ]; then
    servidor="apache"
    sufijo="A"
    imagen="apache_seguro"
    dockerfile_path="/vagrant/apache"
elif [ "$opcion" == "2" ]; then
    servidor="nginx"
    sufijo="N"
    imagen="nginx_seguro"
    dockerfile_path="/vagrant/nginx"
else
    echo "Opción inválida."
    exit 1
fi

# Definir usuario y carpeta
usuario="${uo}${sufijo}"
carpeta="/home/WEBS_ALUMNOS/${usuario}"

# Crear carpeta del alumno
echo "Creando carpeta $carpeta..."
mkdir -p "$carpeta"
chown root:root "$carpeta"
chmod 755 "$carpeta"

# Crear usuario SSH
echo "Creando usuario SSH $usuario..."
password=$(openssl rand -base64 12)
useradd -d "$carpeta" -s /bin/bash "$usuario"
echo "${usuario}:${password}" | chpasswd

# Ajustar permisos de la carpeta para el alumno
chown "$usuario":"$usuario" "$carpeta"

# Establecer umask 022 automático para ese usuario
echo "Configurando umask 022 para $usuario..."
su - "$usuario" -c 'echo "umask 022" >> ~/.bashrc'

# Copiar el script reparar_permisos.sh a la carpeta del alumno
echo "Copiando script de reparación de permisos..."
cp /vagrant/reparar_permisos.sh "$carpeta/"
chown "$usuario":"$usuario" "$carpeta/reparar_permisos.sh"
chmod 700 "$carpeta/reparar_permisos.sh"

# Buscar puerto disponible
puerto_libre=$(buscar_puerto_libre)

# Verificar si la imagen de Docker ya existe
if ! docker image inspect "$imagen" >/dev/null 2>&1; then
    echo "La imagen $imagen no existe. Construyéndola ahora..."
    docker build -t "$imagen" "$dockerfile_path"
else
    echo "La imagen $imagen ya existe. Usándola."
fi

# Crear contenedor Docker
echo "Desplegando contenedor Docker para $usuario en puerto $puerto_libre..."

if [ "$servidor" == "apache" ]; then
    docker run -d --name "${usuario}_web" -p "${puerto_libre}:80" -v "$carpeta":/var/www/html "$imagen"
else
    docker run -d --name "${usuario}_web" -p "${puerto_libre}:80" -v "$carpeta":/usr/share/nginx/html "$imagen"
fi

# Mostrar credenciales de acceso
echo "-----------------------------------------------"
echo "Alumno creado correctamente."
echo "Nombre completo: $nombre_alumno"
echo "Usuario SSH: $usuario"
echo "Contraseña SSH: $password"
echo "Servidor Web: $servidor"
echo "Carpeta asignada: $carpeta"
echo "Puerto asignado: $puerto_libre"
echo "-----------------------------------------------"
