#!/bin/bash

# Script para reparar permisos en la carpeta personal del alumno

# Obtener el directorio actual (debe ser la carpeta del alumno)
DIR_ACTUAL=$(pwd)

# Confirmar que estamos en el home del alumno (seguridad extra)
if [[ "$DIR_ACTUAL" != /home/WEBS_ALUMNOS/* ]]; then
    echo "Error: Este script solo debe ejecutarse desde tu carpeta personal."
    exit 1
fi

# Reparar permisos de carpetas (directorios)
find . -type d -exec chmod 755 {} \;

# Reparar permisos de archivos
find . -type f -exec chmod 644 {} \;

echo "Permisos reparados exitosamente en $(pwd)."
