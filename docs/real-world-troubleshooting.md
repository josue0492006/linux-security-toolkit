# 🛠️ Real-World Troubleshooting Scenarios

Documentación técnica de **diagnóstico, análisis de causa raíz (Root Cause Analysis)** y resolución de fallos en entornos **Linux/Ubuntu**.

Estos escenarios están orientados a la administración de sistemas, **Cloud Security** y **Blue Team**, utilizando herramientas como `systemd`, `journalctl`, SSH, redes y UFW.

---

## 📋 Índice

1. [Critical Service Crash Investigation via System Logs](#1-critical-service-crash-investigation-via-system-logs)
2. [Service Failed to Start Due to Strict File Permissions](#2-service-failed-to-start-due-to-strict-file-permissions)
3. [Service Unreachable Over Private LAN](#3-service-unreachable-over-private-lan)
4. [SSH Key Authentication Refused](#4-ssh-key-authentication-refused)
5. [Emergency Rollback After Invalid SSH Configuration](#5-emergency-rollback-after-invalid-ssh-configuration)
6. [Port Binding Conflict on Ubuntu 2404](#6-port-binding-conflict-on-ubuntu-2404)
7. [Administrator Locked Out After Enabling UFW](#7-administrator-locked-out-after-enabling-ufw)
8. [SSH Connection Timeout Due to IP Blocking in UFW](#8-ssh-connection-timeout-due-to-ip-blocking-in-ufw)
9. [High System Load Due to SSH Brute Force Attacks](#9-high-system-load-due-to-ssh-brute-force-attacks)

---

# 1. Critical Service Crash Investigation via System Logs

**Categoría:** `Systemd Logs & Journald` — Módulo 1

### Síntoma

Un servicio crítico cayó durante la madrugada y el servidor sufrió una degradación temporal o un reinicio imprevisto.

### Diagnóstico

**1. Consultar el historial de arranques del sistema:**

```bash
sudo journalctl --list-boots
```

**2. Inspeccionar los registros del arranque anterior (`-1`) filtrando errores:**

```bash
sudo journalctl -b -1 -p err --no-pager
```

**3. Buscar eventos relacionados con errores, fallos o agotamiento de memoria:**

```bash
sudo journalctl -b -1 --no-pager | grep -iE "error|failed|out of memory"
```

### Causa raíz

Invocación del mecanismo **Out-Of-Memory (OOM) Killer** por parte del kernel Linux debido al agotamiento completo de la memoria RAM disponible.

### Solución

Ajustar el límite de recursos en la unidad del servicio dentro de:

```text
/etc/systemd/system/
```

o ampliar el espacio de intercambio (**swap**) para mitigar picos de consumo de memoria.

### Verificación

Comprobar el estado de la memoria RAM y swap:

```bash
free -h
```

---

# 2. Service Failed to Start Due to Strict File Permissions

**Categoría:** `Permisos POSIX & Systemd` — Módulo 1

### Síntoma

Un servicio personalizado no puede iniciar y `systemctl status` devuelve:

```text
(code=exited, status=203/EXEC)
```

### Diagnóstico

**1. Revisar los últimos logs generados por la unidad de systemd:**

```bash
sudo journalctl -u <nombre_servicio> -n 20 --no-pager
```

**2. Verificar los permisos y la propiedad del script o binario ejecutable:**

```bash
ls -l /usr/local/bin/script_servicio.sh
```

**3. Salida observada:**

```text
-rw-r--r-- 1 root root
```

El archivo no cuenta con permiso de ejecución.

### Causa raíz

El archivo indicado en `ExecStart` no tiene el bit de ejecución (`+x`) o pertenece a un usuario/grupo que no tiene los permisos necesarios.

### Solución

Otorgar permisos de ejecución:

```bash
sudo chmod +x /usr/local/bin/script_servicio.sh
```

Reiniciar el servicio:

```bash
sudo systemctl restart <nombre_servicio>
```

### Verificación

Confirmar que el servicio se encuentre activo:

```bash
systemctl is-active <nombre_servicio>
```

---

# 3. Service Unreachable Over Private LAN

**Categoría:** `Diagnóstico de Redes & Sockets` — Módulo 2 · Bloque 1

### Síntoma

Un servicio funciona correctamente en la máquina donde está instalado, pero otros equipos de la red local reciben:

```text
Connection refused
```

### Diagnóstico

**1. Verificar las interfaces de red y las IP asignadas:**

```bash
ip a
```

**2. Inspeccionar qué interfaz está utilizando el servicio:**

```bash
sudo ss -tlpn | grep :8080
```

**3. Salida observada:**

```text
LISTEN 0 128 127.0.0.1:8080
```

### Causa raíz

El servicio está vinculado exclusivamente a la interfaz de loopback:

```text
127.0.0.1
```

Por lo tanto, solamente acepta conexiones desde la propia máquina.

### Solución

Cambiar la dirección de escucha del servicio a:

```text
0.0.0.0
```

para aceptar conexiones en todas las interfaces, o utilizar específicamente la IP privada de la interfaz de red.

Posteriormente, recargar el servicio.

### Verificación

Probar la conectividad desde otro equipo:

```bash
nc -zv <IP_SERVIDOR> 8080
```

---

# 4. SSH Key Authentication Refused

**Categoría:** `Criptografía & SSH Hardening` — Módulo 2 · Bloque 2

### Síntoma

El cliente intenta conectarse mediante una llave privada `id_ed25519`, pero el servidor rechaza la conexión:

```text
Permission denied (publickey)
```

### Diagnóstico

**1. Consultar los registros del servicio SSH:**

```bash
sudo journalctl -u ssh -n 30 --no-pager
```

**2. Log observado:**

```text
Authentication refused: bad ownership or modes for directory /home/usuario/.ssh
```

### Causa raíz

SSH utiliza la política **StrictModes**. Si el directorio `.ssh` o el archivo `authorized_keys` tienen permisos demasiado abiertos, el demonio puede rechazar la autenticación por motivos de seguridad.

### Solución

Aplicar permisos estrictos:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Verificación

Intentar nuevamente la conexión:

```bash
ssh usuario@ip_servidor
```

---

# 5. Emergency Rollback After Invalid SSH Configuration

**Categoría:** `SSH Hardening & Syntax Validation` — Módulo 2 · Bloque 2

### Síntoma

Después de modificar `/etc/ssh/sshd_config`, se reinicia el servicio y aparece:

```text
Job for ssh.service failed
```

### Diagnóstico

**1. Inspeccionar el estado del servicio:**

```bash
sudo systemctl status ssh
```

**2. Validar la sintaxis antes de reiniciar o recargar SSH:**

```bash
sudo sshd -t
```

**3. Resultado observado:**

```text
/etc/ssh/sshd_config line 38: Bad configuration option: PermittRootLogin
```

### Causa raíz

Error tipográfico en la directiva:

```text
PermittRootLogin
```

cuando debería ser:

```text
PermitRootLogin
```

### Solución

**1. Corregir la configuración:**

```bash
sudo nano /etc/ssh/sshd_config
```

**2. Volver a validar la sintaxis:**

```bash
sudo sshd -t
```

Si no devuelve ningún error, continuar.

**3. Recargar SSH sin desconectar las sesiones activas:**

```bash
sudo systemctl reload ssh
```

### Verificación

```bash
systemctl is-active ssh
```

---

# 6. Port Binding Conflict on Ubuntu 24.04

**Categoría:** `Systemd Sockets & Redes` — Módulo 2 · Bloques 1/2

### Síntoma

Se configura:

```text
Port 2222
```

en `/etc/ssh/sshd_config`, pero SSH continúa escuchando únicamente en el puerto `22`.

### Diagnóstico

**1. Auditar los sockets y procesos que están escuchando:**

```bash
sudo ss -tlpn | grep ssh
```

**2. Resultado observado:**

El PID pertenece a `systemd` y no directamente al proceso `sshd`.

### Causa raíz

En Ubuntu 24.04+, la escucha de SSH puede estar gestionada mediante **systemd socket activation**, utilizando:

```text
ssh.socket
```

Esto puede hacer que el socket controle la escucha del puerto independientemente de la configuración esperada en `sshd_config`.

### Solución

Desactivar la gestión mediante socket:

```bash
sudo systemctl disable --now ssh.socket
```

Habilitar e iniciar el servicio SSH tradicional:

```bash
sudo systemctl enable --now ssh.service
```

### Verificación

Comprobar que `sshd` esté escuchando en el puerto personalizado:

```bash
sudo ss -tlpn | grep 2222
```

---

# 7. Administrator Locked Out After Enabling UFW

**Categoría:** `Cortafuegos & UFW` — Módulo 2 · Bloque 3

### Síntoma

Después de ejecutar:

```bash
sudo ufw enable
```

la sesión SSH se interrumpe o las conexiones posteriores son bloqueadas.

### Diagnóstico

Desde una consola física o de rescate:

```bash
sudo ufw status verbose
```

### Resultado observado

```text
Default: deny (incoming), allow (outgoing)
```

No existe una regla que permita la entrada por el puerto SSH.

### Causa raíz

Se aplicó la política:

```text
Default Deny
```

sin crear previamente una excepción para SSH.

### Solución

Permitir el puerto SSH:

```bash
sudo ufw allow 2222/tcp
```

Después habilitar UFW:

```bash
sudo ufw enable
```

### Verificación

```bash
sudo ufw status numbered
```

Confirmar que el puerto aparece como:

```text
ALLOW IN
```

---

# 8. SSH Connection Timeout Due to IP Blocking in UFW

**Categoría:** `Cortafuegos & Filtrado Avanzado` — Módulo 2 · Bloque 3

### Síntoma

Un equipo cliente específico no puede conectarse por SSH y la conexión termina con:

```text
Operation timed out
```

Mientras tanto, otros equipos sí pueden conectarse.

### Diagnóstico

Listar las reglas numeradas:

```bash
sudo ufw status numbered
```

### Resultado observado

Existe una regla:

```text
DENY IN
```

dirigida hacia la IP o segmento de red del cliente.

### Causa raíz

El firewall está bloqueando la conexión mediante una regla basada en IP o máscara de red.

### Solución

Eliminar la regla utilizando su número:

```bash
sudo ufw delete <numero_regla>
```

O permitir explícitamente la IP:

```bash
sudo ufw allow from <IP_CLIENTE> to any port 2222 proto tcp
```

### Verificación

Probar la conexión desde el equipo cliente:

```bash
nc -zv <IP_SERVIDOR> 2222
```

---

# 9. High System Load Due to SSH Brute Force Attacks

**Categoría:** `Seguridad, Monitoreo & Auditoría` — Módulo 2 · Bloque 4

### Síntoma

Se detecta lentitud en el servidor y una elevada cantidad de procesos SSH intentando autenticarse continuamente.

### Diagnóstico

**1. Inspeccionar intentos de autenticación fallidos en tiempo real:**

```bash
sudo journalctl -u ssh -f | grep "Failed password"
```

**2. Contar los intentos agrupados por dirección IP de origen:**

```bash
sudo journalctl -u ssh --no-pager | grep "Failed password" | awk '{print $(NF-2)}' | sort | uniq -c | sort -nr
```

### Causa raíz

Ataque automatizado de fuerza bruta dirigido al servicio SSH, normalmente contra el puerto predeterminado:

```text
22
```

### Solución

**1. Cambiar el puerto SSH por defecto:**

```text
2222
```

**2. Restringir los usuarios permitidos mediante `AllowUsers`:**

```text
AllowUsers usuario
```

**3. Deshabilitar la autenticación mediante contraseña:**

```text
PasswordAuthentication no
```

### Verificación

Monitorear nuevamente los eventos:

```bash
sudo journalctl -u ssh -f
```

y comprobar la reducción de intentos de autenticación fallidos.

---

## 🎯 Skills Practiced

Este laboratorio permitió practicar:

* 🐧 Administración de Linux/Ubuntu
* ⚙️ `systemd` y `systemctl`
* 📜 `journalctl` y análisis de logs
* 🔐 SSH y autenticación mediante llaves
* 🔒 Hardening y permisos POSIX
* 🌐 Diagnóstico de redes y sockets
* 🧱 UFW y reglas de firewall
* 🔎 Análisis de causa raíz (RCA)
* 🚨 Detección de intentos de fuerza bruta
* 🛡️ Troubleshooting orientado a Blue Team
* ☁️ Fundamentos aplicables a Cloud Security
