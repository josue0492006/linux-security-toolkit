# 🛡️ Real-World Troubleshooting Scenarios

> **Linux • Systemd • SSH • Networking • UFW • Logs • Blue Team**

Colección de escenarios prácticos de **troubleshooting, análisis de logs y Root Cause Analysis (RCA)** en entornos Linux/Ubuntu.

El objetivo es practicar la identificación de fallos, análisis de evidencia, aplicación de correcciones y verificación del resultado utilizando herramientas nativas de Linux.

---

## 📌 Overview

| Área             | Tecnologías / Herramientas            |
| ---------------- | ------------------------------------- |
| 🐧 Sistema       | Linux / Ubuntu                        |
| ⚙️ Servicios     | systemd / systemctl                   |
| 📜 Logs          | journalctl / Journald                 |
| 🔐 Acceso remoto | SSH                                   |
| 🌐 Redes         | IP / Sockets / Netcat                 |
| 🧱 Firewall      | UFW                                   |
| 🔎 Diagnóstico   | ss / grep / awk                       |
| 🛡️ Seguridad    | SSH Hardening / Brute Force Detection |
| 🧠 Metodología   | Root Cause Analysis                   |

---

## 🗂️ Scenarios

|  # | Scenario                             | Área                  |
| -: | ------------------------------------ | --------------------- |
| 01 | Critical Service Crash Investigation | Systemd / Logs        |
| 02 | Service Failed to Start              | Permissions / Systemd |
| 03 | Service Unreachable Over Private LAN | Networking / Sockets  |
| 04 | SSH Key Authentication Refused       | SSH / Hardening       |
| 05 | Invalid SSH Configuration            | SSH / Validation      |
| 06 | SSH Port Binding Conflict            | Systemd / Networking  |
| 07 | Administrator Locked Out After UFW   | Firewall / SSH        |
| 08 | SSH Timeout Due to IP Blocking       | Firewall / Networking |
| 09 | SSH Brute Force Detection            | Security / Monitoring |

---

# 🔎 Troubleshooting Methodology

Los escenarios siguen una metodología basada en cinco etapas:

```text
┌──────────────┐
│   SYMPTOM    │
└──────┬───────┘
       ↓
┌──────────────┐
│ INVESTIGATION│
└──────┬───────┘
       ↓
┌──────────────┐
│  ROOT CAUSE  │
└──────┬───────┘
       ↓
┌──────────────┐
│ REMEDIATION  │
└──────┬───────┘
       ↓
┌──────────────┐
│ VERIFICATION │
└──────────────┘
```

La idea es **no aplicar cambios a ciegas**: primero se recopila evidencia, después se identifica la causa y finalmente se valida la solución.

---

# 01 · Critical Service Crash Investigation

> **Category:** `Systemd Logs & Journald`
> **Focus:** Service failure investigation

### 🔴 Symptom

Un servicio crítico cayó durante la madrugada y el servidor sufrió una degradación temporal o un reinicio imprevisto.

### 🔎 Investigation

**1. Consultar el historial de arranques:**

```bash
sudo journalctl --list-boots
```

**2. Revisar los errores del arranque anterior:**

```bash
sudo journalctl -b -1 -p err --no-pager
```

**3. Buscar eventos relacionados con errores, fallos o memoria:**

```bash
sudo journalctl -b -1 --no-pager | grep -iE "error|failed|out of memory"
```

### 🎯 Root Cause

Invocación del mecanismo **Out-Of-Memory (OOM) Killer** por parte del kernel Linux debido al agotamiento completo de la memoria RAM disponible.

### 🛠️ Remediation

Ajustar los límites de recursos del servicio en:

```text
/etc/systemd/system/
```

o ampliar el espacio de intercambio (**swap**) para mitigar picos de memoria.

### ✅ Verification

```bash
free -h
```

Comprobar el estado de la memoria RAM y del espacio swap.

---

# 02 · Service Failed to Start

> **Category:** `POSIX Permissions & Systemd`
> **Focus:** File permissions / executable configuration

### 🔴 Symptom

Un servicio personalizado no puede iniciar y `systemctl status` muestra:

```text
(code=exited, status=203/EXEC)
```

### 🔎 Investigation

**1. Revisar los logs del servicio:**

```bash
sudo journalctl -u <nombre_servicio> -n 20 --no-pager
```

**2. Comprobar permisos y propiedad del ejecutable:**

```bash
ls -l /usr/local/bin/script_servicio.sh
```

**3. Resultado observado:**

```text
-rw-r--r-- 1 root root
```

El archivo no tiene permiso de ejecución.

### 🎯 Root Cause

El archivo utilizado por `ExecStart` no cuenta con el bit de ejecución (`+x`) o pertenece a un usuario/grupo sin acceso adecuado.

### 🛠️ Remediation

Otorgar permiso de ejecución:

```bash
sudo chmod +x /usr/local/bin/script_servicio.sh
```

Reiniciar el servicio:

```bash
sudo systemctl restart <nombre_servicio>
```

### ✅ Verification

```bash
systemctl is-active <nombre_servicio>
```

El resultado esperado es:

```text
active
```

---

# 03 · Service Unreachable Over Private LAN

> **Category:** `Networking & Sockets`
> **Focus:** Network binding

### 🔴 Symptom

El servicio funciona localmente, pero otros equipos de la red reciben:

```text
Connection refused
```

### 🔎 Investigation

**1. Revisar las interfaces de red:**

```bash
ip a
```

**2. Comprobar qué dirección está utilizando el servicio:**

```bash
sudo ss -tlpn | grep :8080
```

**3. Resultado observado:**

```text
LISTEN 0 128 127.0.0.1:8080
```

### 🎯 Root Cause

El servicio está vinculado exclusivamente a:

```text
127.0.0.1
```

Esto corresponde a la interfaz **loopback**, por lo que el servicio solamente acepta conexiones desde la propia máquina.

### 🛠️ Remediation

Cambiar la dirección de escucha a:

```text
0.0.0.0
```

o utilizar la IP privada específica de la interfaz de red.

Posteriormente, recargar el servicio.

### ✅ Verification

Desde otro equipo:

```bash
nc -zv <IP_SERVIDOR> 8080
```

---

# 04 · SSH Key Authentication Refused

> **Category:** `SSH & Hardening`
> **Focus:** Public-key authentication

### 🔴 Symptom

El cliente intenta conectarse mediante `id_ed25519`, pero el servidor responde:

```text
Permission denied (publickey)
```

### 🔎 Investigation

Consultar los logs de SSH:

```bash
sudo journalctl -u ssh -n 30 --no-pager
```

### 📋 Evidence

```text
Authentication refused: bad ownership or modes for directory /home/usuario/.ssh
```

### 🎯 Root Cause

SSH aplica la política **StrictModes**.

Los permisos demasiado abiertos en `.ssh` o `authorized_keys` pueden provocar que el servidor rechace la autenticación.

### 🛠️ Remediation

Aplicar permisos estrictos:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### ✅ Verification

```bash
ssh usuario@ip_servidor
```

---

# 05 · Emergency Rollback After Invalid SSH Configuration

> **Category:** `SSH Hardening & Syntax Validation`
> **Focus:** Safe configuration changes

### 🔴 Symptom

Después de modificar:

```text
/etc/ssh/sshd_config
```

el servicio devuelve:

```text
Job for ssh.service failed
```

### 🔎 Investigation

**1. Revisar el estado del servicio:**

```bash
sudo systemctl status ssh
```

**2. Validar la configuración:**

```bash
sudo sshd -t
```

### 📋 Evidence

```text
/etc/ssh/sshd_config line 38: Bad configuration option: PermittRootLogin
```

### 🎯 Root Cause

Error tipográfico:

```text
PermittRootLogin
```

en lugar de:

```text
PermitRootLogin
```

### 🛠️ Remediation

Editar la configuración:

```bash
sudo nano /etc/ssh/sshd_config
```

Validar nuevamente:

```bash
sudo sshd -t
```

Si no existen errores, recargar SSH:

```bash
sudo systemctl reload ssh
```

### ✅ Verification

```bash
systemctl is-active ssh
```

---

# 06 · SSH Port Binding Conflict

> **Category:** `Systemd Sockets & Networking`
> **Focus:** Socket activation

### 🔴 Symptom

Se configura:

```text
Port 2222
```

en:

```text
/etc/ssh/sshd_config
```

pero SSH continúa escuchando en el puerto `22`.

### 🔎 Investigation

Comprobar los procesos y sockets:

```bash
sudo ss -tlpn | grep ssh
```

El proceso observado pertenece a `systemd` y no directamente a `sshd`.

### 🎯 Root Cause

La escucha del puerto está gestionada mediante:

```text
ssh.socket
```

utilizando **systemd socket activation**.

### 🛠️ Remediation

Desactivar el socket:

```bash
sudo systemctl disable --now ssh.socket
```

Habilitar el servicio SSH:

```bash
sudo systemctl enable --now ssh.service
```

### ✅ Verification

```bash
sudo ss -tlpn | grep 2222
```

Comprobar que `sshd` está escuchando en el puerto personalizado.

---

# 07 · Administrator Locked Out After Enabling UFW

> **Category:** `Firewall & UFW`
> **Focus:** Firewall rule management

### 🔴 Symptom

Después de ejecutar:

```bash
sudo ufw enable
```

la sesión SSH se interrumpe o las conexiones posteriores son bloqueadas.

### 🔎 Investigation

Desde una consola física o de rescate:

```bash
sudo ufw status verbose
```

### 📋 Evidence

```text
Default: deny (incoming), allow (outgoing)
```

No existe una regla que permita el acceso al puerto SSH.

### 🎯 Root Cause

Se aplicó una política:

```text
Default Deny
```

sin crear previamente una excepción para SSH.

### 🛠️ Remediation

Permitir el puerto SSH:

```bash
sudo ufw allow 2222/tcp
```

Después habilitar UFW:

```bash
sudo ufw enable
```

### ✅ Verification

```bash
sudo ufw status numbered
```

Confirmar que el puerto aparece como:

```text
ALLOW IN
```

---

# 08 · SSH Connection Timeout Due to IP Blocking

> **Category:** `Firewall & Advanced Filtering`
> **Focus:** IP-based filtering

### 🔴 Symptom

Un equipo específico no puede conectarse por SSH y obtiene:

```text
Operation timed out
```

Mientras otros equipos mantienen acceso.

### 🔎 Investigation

Listar las reglas de UFW:

```bash
sudo ufw status numbered
```

### 📋 Evidence

Existe una regla:

```text
DENY IN
```

dirigida a la IP o segmento de red del cliente.

### 🎯 Root Cause

Una regla del firewall está bloqueando la conexión mediante una dirección IP o máscara de red.

### 🛠️ Remediation

Eliminar la regla:

```bash
sudo ufw delete <numero_regla>
```

O permitir explícitamente la IP:

```bash
sudo ufw allow from <IP_CLIENTE> to any port 2222 proto tcp
```

### ✅ Verification

Probar la conexión desde el cliente:

```bash
nc -zv <IP_SERVIDOR> 2222
```

---

# 09 · SSH Brute Force Detection

> **Category:** `Security, Monitoring & Auditing`
> **Focus:** Authentication monitoring

### 🔴 Symptom

El servidor presenta lentitud y una cantidad elevada de intentos de autenticación SSH.

### 🔎 Investigation

**1. Monitorizar intentos fallidos en tiempo real:**

```bash
sudo journalctl -u ssh -f | grep "Failed password"
```

**2. Contabilizar intentos por IP de origen:**

```bash
sudo journalctl -u ssh --no-pager | \
grep "Failed password" | \
awk '{print $(NF-2)}' | \
sort | uniq -c | sort -nr
```

### 🎯 Root Cause

Ataque automatizado de **fuerza bruta** dirigido al servicio SSH.

El objetivo habitual es el puerto predeterminado:

```text
22
```

### 🛠️ Remediation

**1. Utilizar un puerto SSH no estándar:**

```text
2222
```

**2. Restringir usuarios mediante `AllowUsers`:**

```text
AllowUsers usuario
```

**3. Deshabilitar autenticación mediante contraseña:**

```text
PasswordAuthentication no
```

### ✅ Verification

Monitorizar nuevamente los eventos:

```bash
sudo journalctl -u ssh -f
```

Comprobar la evolución de los intentos de autenticación fallidos.

---

# 🧠 Skills Practiced

Este laboratorio permitió practicar diferentes áreas relacionadas con **Linux Administration, Blue Team y Cloud Security**:

```text
Linux Administration
        │
        ├── systemd / systemctl
        ├── Journald / journalctl
        └── POSIX Permissions
        │
        ▼
Network Troubleshooting
        │
        ├── ip
        ├── ss
        └── nc
        │
        ▼
Secure Remote Access
        │
        ├── SSH
        ├── Public-Key Authentication
        └── SSH Hardening
        │
        ▼
Network Security
        │
        └── UFW
        │
        ▼
Blue Team
        │
        ├── Log Analysis
        ├── Incident Detection
        ├── Brute Force Detection
        └── Root Cause Analysis
```

---

# 📚 Key Takeaways

### `systemctl`

Permite administrar servicios y comprobar su estado:

```bash
systemctl status <servicio>
systemctl start <servicio>
systemctl stop <servicio>
systemctl restart <servicio>
```

### `journalctl`

Permite investigar eventos y errores registrados por systemd:

```bash
journalctl -u <servicio>
```

### `ss`

Permite identificar puertos y sockets en escucha:

```bash
sudo ss -tlpn
```

### `ufw`

Permite administrar reglas básicas del firewall:

```bash
sudo ufw status
```

### `sshd -t`

Permite validar la configuración de SSH antes de aplicar cambios:

```bash
sudo sshd -t
```

---

# 🛡️ Blue Team Perspective

Estos ejercicios siguen una idea fundamental del trabajo defensivo:

> **Detect → Investigate → Identify → Remediate → Verify**

La herramienta por sí sola no es el objetivo.

El objetivo es aprender a utilizar **evidencia técnica** para determinar qué ocurrió, encontrar la causa raíz y aplicar una corrección controlada.

---

## 📈 Progress

| Área                    | Estado |
| ----------------------- | :----: |
| Linux Administration    |    ✅   |
| Systemd                 |    ✅   |
| Journald / Logs         |    ✅   |
| POSIX Permissions       |    ✅   |
| SSH                     |    ✅   |
| SSH Hardening           |    ✅   |
| Network Troubleshooting |    ✅   |
| UFW                     |    ✅   |
| Brute Force Detection   |    ✅   |
| Root Cause Analysis     |    ✅   |

---

> **Lab Status:** Completed
> **Focus:** Linux Administration / Blue Team / Cloud Security
> **Environment:** Ubuntu / Linux
> **Methodology:** Troubleshooting + Root Cause Analysis
