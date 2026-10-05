# 🐧 Cheatsheet Completa: Administrador de Sistemas Linux & Hardening (SysAdmin / Cloud)

---

## 🛡️ MÓDULO 1: LINUX HARDENING Y FUNDAMENTOS

### 📁 Bloque 1: Permisos de Archivos y Seguridad Octal
| Comando | Descripción / Uso |
| :--- | :--- |
| `ls -la /ruta/` | Muestra todos los archivos (incluidos ocultos `.`) con permisos octales y propietarios. |
| `chmod 700 ~/.ssh` | Otorga lectura, escritura y ejecución EXCLUSIVAMENTE al dueño (`rwx------`). |
| `chmod 600 ~/.ssh/authorized_keys` | Otorga lectura y escritura EXCLUSIVAMENTE al dueño (`rw-------`). |
| `chmod 644 ~/.ssh/id_ed25519.pub` | Lectura para todos, escritura solo para el dueño (`rw-r--r--`). |
| `chown -R usuario:grupo /directorio/` | Cambia el propietario y grupo de un directorio de forma recursiva. |
| `find / -perm -4000 2>/dev/null` | Audita el sistema buscando archivos con bit SUID activado (riesgo de elevación). |

### 🧩 Bloque 2: Administración de Servicios y Logs (Systemd)
| Comando | Descripción / Uso |
| :--- | :--- |
| `sudo systemctl status <servicio>` | Muestra si el servicio está activo, inactivo o fallido (`failed`). |
| `sudo systemctl start <servicio>` | Inicia un servicio en segundo plano. |
| `sudo systemctl stop <servicio>` | Detiene un servicio en ejecución. |
| `sudo systemctl restart <servicio>` | Reinicia el servicio (corta conexiones activas para aplicar cambios). |
| `sudo systemctl reload <servicio>` | Relee la configuración SIN cortar conexiones activas. |
| `sudo systemctl enable --now <servicio>` | Activa el arranque automático al encender la máquina Y lo inicia de inmediato. |
| `sudo systemctl disable --now <servicio>` | Desactiva el arranque automático Y lo detiene al instante. |
| `sudo journalctl -u <servicio> -n 30 --no-pager` | Muestra los últimos 30 registros de un servicio de forma limpia. |
| `sudo journalctl -u <servicio> -f` | Monitorea los registros del servicio en tiempo real (modo depuración). |

---

## 🌐 MÓDULO 2: REDES, SSH, FIREWALLS Y SEGURIDAD AVANZADA

### 📡 Bloque 1: Diagnóstico de Redes e Interfaces
| Comando | Descripción / Uso |
| :--- | :--- |
| `ip a` | Muestra las interfaces de red activas, MACs e IPs asignadas (v4/v6). |
| `ip r` | Muestra la tabla de enrutamiento y la puerta de enlace predeterminada (*default gateway*). |
| `sudo ss -tlpn` | Muestra los puertos **TCP** (`-t`) escuchando (`-l`), numéricos (`-n`), con PIDs (`-p`). |
| `sudo ss -ulpn` | Muestra los puertos **UDP** (`-u`) en escucha. |
| `ping -c 4 <IP/Dominio>` | Prueba la conectividad ICMP básica enviando 4 paquetes. |
| `nc -zv <IP> <puerto>` | Prueba si un puerto TCP específico está abierto en un host remoto (Netcat). |
| `curl -I <URL>` | Muestra la respuesta HTTP (headers/códigos de estado) de un servidor web. |

### 🔒 Bloque 2: SSH Hardening y Gestión de Llaves
| Comando | Descripción / Uso |
| :--- | :--- |
| `sudo sshd -t` | Audita la sintaxis de `/etc/ssh/sshd_config` antes de reiniciar (previene bloqueos). |
| `ssh-keygen -t ed25519 -C "comentario"` | Genera un par de llaves SSH modernas con algoritmo seguro Ed25519. |
| `ssh-copy-id -i ~/.ssh/id_ed25519.pub usuario@servidor` | Inyecta la llave pública en el servidor remoto de forma segura. |
| `ssh -p <puerto> -i ~/.ssh/llave usuario@servidor` | Se conecta por SSH especificando puerto personalizado y llave privada. |
| `sudo systemctl disable --now ssh.socket` | Libera el puerto 22 gestionado por Systemd Socket en Ubuntu 24.04+. |
| `sudo journalctl -u ssh -n 20 --no-pager` | Revisa bloqueos e intentos fallidos de autenticación SSH. |

### 🧱 Bloque 3: Cortafuegos (UFW / Firewalls)
| Comando | Descripción / Uso |
| :--- | :--- |
| `sudo ufw status verbose` | Muestra el estado del firewall y sus reglas activas de forma detallada. |
| `sudo ufw default deny incoming` | Política de seguridad: bloquea todo el tráfico entrante no autorizado. |
| `sudo ufw default allow outgoing` | Política de seguridad: permite todo el tráfico saliente. |
| `sudo ufw allow <puerto>/tcp` | Abre un puerto específico (ej. `sudo ufw allow 2222/tcp`). |
| `sudo ufw allow from <IP_cliente> to any port <puerto>` | Restringe el acceso a un puerto solo para una IP específica. |
| `sudo ufw reload` | Recarga las reglas del cortafuegos sin reiniciar el servicio. |
| `sudo ufw enable` / `sudo ufw disable` | Activa o desactiva el firewall UFW. |

### 📦 Bloque 4: Transferencia de Archivos y Sincronización (`scp` y `rsync`)
| Comando | Descripción / Uso |
| :--- | :--- |
| `scp -P <puerto> archivo.txt usuario@servidor:/ruta/` | Copia un archivo local hacia un servidor remoto vía SSH. |
| `scp -P <puerto> -r carpeta/ usuario@servidor:/ruta/` | Copia un directorio completo de manera recursiva hacia el servidor. |
| `rsync -avz -e "ssh -p <puerto>" origen/ usuario@servidor:destino/` | Sincroniza archivos/carpetas preservando permisos (`-a`), muestra progreso (`-v`) y comprime (`-z`). |
| `rsync -avz --delete origen/ destino/` | Mantiene el destino idéntico al origen, eliminando en destino lo que ya no existe en el origen. |
| `rsync -avz --dry-run origen/ destino/` | Muestra qué archivos se transferirían o borrarían sin realizar cambios reales (Modo prueba). |
| `rsync -avz --progress origen/ destino/` | Muestra la velocidad de transferencia y tiempo restante barra por barra. |

### 🔐 Bloque 5: Hardening Avanzado y Restricciones de Usuario
| Comando | Descripción / Uso |
| :--- | :--- |
| `sudo nano /etc/ssh/sshd_config` | Edita el archivo principal de política SSH para aplicar reglas restrictivas. |
| `AllowUsers usuario1 usuario2` | Directiva en `sshd_config` que aplica lista blanca estricta (bloquea a todo usuario no listado). |
| `PermitRootLogin no` | Directiva SSH que impide el acceso directo con la cuenta superusuario `root`. |
| `PasswordAuthentication no` | Fuerza el uso exclusivo de llaves SSH, deshabilitando el login por contraseña. |
| `MaxAuthTries 3` | Limita la cantidad de intentos fallidos de contraseña/llave por conexión antes de desconectar. |
| `ClientAliveInterval 300` | Envía un paquete de control cada 300 segundos para detectar y cerrar sesiones SSH inactivas. |

### 🔍 Bloque 6: Auditoría de Accesos, Monitoreo y Fail2ban
| Comando | Descripción / Uso |
| :--- | :--- |
| `sudo journalctl -u ssh -f` | Monitorea los intentos de autenticación SSH en tiempo real. |
| `sudo grep "Failed password" /var/log/auth.log` | Busca todos los intentos fallidos de contraseña en los registros históricos de acceso. |
| `sudo grep "Accepted" /var/log/auth.log` | Muestra el historial completo de inicios de sesión exitosos en el servidor. |
| `last -a` | Muestra el historial de los últimos usuarios que iniciaron sesión y sus direcciones IP de origen. |
| `sudo fail2ban-client status sshd` | Muestra las métricas del servicio Fail2ban y la lista de IPs actualmente bloqueadas por fuerza bruta. |
| `sudo fail2ban-client set sshd unbanip <IP>` | Desbloquea manualmente una dirección IP que fue baneada por Fail2ban. |
