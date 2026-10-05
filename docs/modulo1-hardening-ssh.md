# 🛡️ Módulo 1: Hardening de Linux, Permisos y SSH

Guía de referencia rápida sobre gestión de usuarios, permisos de archivos, llaves criptográficas y endurecimiento del servicio SSH.

---

## 1. Permisos de Archivos y Seguridad Local

### `chmod 600 ~/.ssh/id_ed25519`
* **¿Qué hace?:** Asigna permisos de lectura y escritura exclusivamente al propietario del archivo (`rw-------`).
* **¿Cuándo se usa?:** Inmediatamente después de crear o mover una **llave privada SSH**. SSH bloquea la conexión por seguridad si la llave privada tiene permisos abiertos.

### `chmod 644 ~/.ssh/authorized_keys`
* **¿Qué hace?:** Otorga lectura y escritura al propietario, y solo lectura a los demás usuarios (`rw-r--r--`).
* **¿Cuándo se usa?:** Para asegurar archivos de configuración pública, como el archivo que contiene las llaves públicas autorizadas para conectar al servidor.

### `chmod 700 ~/.ssh`
* **¿Qué hace?:** Permite lectura, escritura y acceso (ejecución) solo al dueño del directorio (`rwx------`).
* **¿Cuándo se usa?:** Al crear la carpeta oculta `.ssh` en el directorio de cualquier usuario para evitar que otros usuarios del sistema exploren su contenido.

### `chmod +x script.sh`
* **¿Qué hace?:** Otorga permisos de ejecución al archivo indicado.
* **¿Cuándo se usa?:** Antes de intentar ejecutar un script recién creado en Bash (ejemplo: `./harden_sshd.sh`).

---

## 2. Gestión de Llaves Criptográficas SSH

### `ssh-keygen -t ed25519 -C "comentario"`
* **¿Qué hace?:** Genera un par de llaves criptográficas (una privada y una pública) usando el algoritmo moderno ED25519.
* **¿Cuándo se usa?:** En tu máquina local cuando vas a configurar acceso seguro a un servidor o a plataformas como GitHub.

### `ssh-copy-id usuario@ip_servidor`
* **¿Qué hace?:** Automatiza el copiado de tu llave pública al archivo `~/.ssh/authorized_keys` del servidor remoto.
* **¿Cuándo se usa?:** Para habilitar el inicio de sesión mediante llaves en un servidor nuevo antes de desactivar las contraseñas.

---

## 3. Configuración y Auditoría de SSH (`sshd_config`)

### `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%Y%m%d)`
* **¿Qué hace?:** Crea una copia de respaldo del archivo de configuración de SSH añadiendo la fecha actual al nombre.
* **¿Cuándo se usa?:** Siempre **antes** de modificar un archivo de configuración crítico en producción.

### `grep -E "PermitRootLogin|PasswordAuthentication|PermitEmptyPasswords|MaxAuthTries" /etc/ssh/sshd_config`
* **¿Qué hace?:** Filtra y muestra en pantalla únicamente las directivas de seguridad más importantes del archivo.
* **¿Cuándo se usa?:** Para auditar rápidamente el estado de seguridad del servidor sin leer las más de 100 líneas del archivo completo.

### `sshd -t`
* **¿Qué hace?:** Revisa la sintaxis del archivo `/etc/ssh/sshd_config` en busca de errores.
* **¿Cuándo se usa?:** **Antes** de reiniciar el servicio SSH. Si hay un error de sintaxis y reinicias, quedarás bloqueado fuera del servidor.

### `systemctl restart sshd` / `service ssh restart`
* **¿Qué hace?:** Reinicia el demonio de SSH para aplicar los nuevos cambios de configuración.
* **¿Cuándo se usa?:** Después de modificar `sshd_config` y haber verificado con `sshd -t` que no existen errores.

---

## 4. Automatización con Bash

### `sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config`
* **¿Qué hace?:** Busca la línea de autenticación por contraseña dentro del archivo y la reemplaza por `PasswordAuthentication no`.
* **¿Cuándo se usa?:** Dentro de scripts de automatización (como `harden_sshd.sh`) para aplicar el endurecimiento sin abrir un editor de texto interactivo como `nano`.
