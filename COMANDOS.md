# 📖 Guía de Comandos Básicos de Linux

Manual de referencia rápida para administración de sistemas y operaciones en terminal.

| Comando | Sintaxis / Ejemplo | ¿Qué hace? |
| :--- | :--- | :--- |
| **`mkdir`** | `mkdir mi_carpeta` | Crea una nueva carpeta vacía. |
| **`mkdir -p`** | `mkdir -p proyectos/bash/logs` | Crea carpetas anidadas de un solo golpe. |
| **`ls -la`** | `ls -la` | Muestra lista detallada de archivos con permisos y ocultos. |
| **`cd`** | `cd /var/log` | Entra a un directorio específico. |
| **`rm -rf`** | `rm -rf carpeta_vieja` | Elimina carpetas/archivos de forma recursiva y forzada. |
| **`chmod`** | `chmod +x script.sh` | Otorga permisos de ejecución a un archivo `.sh`. |
| **`grep`** | `grep "Failed" auth.log` | Filtra e imprime líneas que coincidan con un texto. |
| **`nano`** | `nano script.sh` | Abre el editor de texto básico en la terminal. |
### Ejemplos de reglas dentro de /etc/sudoers (vía visudo)

| Caso de Uso | Regla de Ejemplo | Descripción |
| :--- | :--- | :--- |
| **Comando específico** | `sofia ALL=(ALL) /usr/bin/systemctl restart nginx` | Permite ejecutar solo el reinicio de Nginx con sudo. |
| **Sin contraseña** | `ana ALL=(ALL) NOPASSWD: /usr/bin/apt update` | Ejecuta el comando especificado sin pedir contraseña. |
| **Grupo de usuarios** | `%devs ALL=(ALL) /usr/bin/docker` | Aplica la regla a todos los usuarios del grupo `devs` (`%`). |
