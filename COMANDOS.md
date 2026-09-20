| Comando | Sintaxis / Ejemplo | ¿Qué hace? |
| :--- | :--- | :--- |
| **MÓDULO 1: LINUX HARDENING** | | |
| `visudo` | `sudo visudo` | Edita `/etc/sudoers` validando sintaxis para evitar bloqueos. |
| `chmod` (octal) | `chmod 600 .env` | Asigna permisos numéricos (600 = R/W solo al dueño). |
| `chmod` (letras) | `chmod u+x script.sh` | Agrega permiso de ejecución solo al dueño del archivo. |
| `chown -R` | `sudo chown -R dev:devs /app` | Cambia usuario y grupo propietario recursivamente. |
| `ls -la` | `ls -la /var/www` | Muestra archivos, permisos, dueños y elementos ocultos. |
| `grep` | `grep "Failed" /var/log/auth.log` | Filtra e imprime líneas que contienen un texto exacto. |
| `find` | `find / -perm -4000 2>/dev/null` | Busca archivos con permisos específicos (ej. SUID). |
| **MÓDULO 2: REDES, SSH Y FIREWALLS** | | |
| `ss -tulpn` | `sudo ss -tulpn` | Muestra puertos abiertos, sockets y procesos escuchando. |
| `ufw status` | `sudo ufw status numbered` | Revisa estado y reglas numeradas del firewall UFW. |
| `ufw allow` | `sudo ufw allow 22/tcp` | Abre un puerto TCP específico en el firewall local. |
| `ssh` | `ssh -i ~/.ssh/id_ed25519 user@ip` | Conecta de forma segura a un servidor remoto con llave. |
| `ssh-keygen` | `ssh-keygen -t ed25519 -C "nota"` | Genera un par de llaves criptográficas pública/privada. |
| `nc` | `nc -zv 192.168.1.1 80` | Escanea o prueba la conectividad directa a un puerto. |
| **MÓDULO 3: DOCKER & CONTAINER SECURITY** | | |
| `docker ps` | `docker ps -a` | Lista todos los contenedores en ejecución y detenidos. |
| `docker run` | `docker run -d --name web nginx` | Despliega un contenedor en segundo plano. |
| `docker exec` | `docker exec -it web bash` | Abre una consola interactiva dentro del contenedor. |
| `docker logs` | `docker logs -f web` | Muestra los registros y salidas en vivo del contenedor. |
| `trivy` | `trivy image nginx:latest` | Escanea imágenes de contenedores buscando vulnerabilidades. |
| **MÓDULO 4: MONITORING & SIEM (LOGS)** | | |
| `journalctl` | `journalctl -u ssh -f` | Monitorea logs del sistema/servicios en tiempo real. |
| `tail -f` | `tail -f /var/log/nginx/error.log` | Muestra las últimas líneas de un archivo de log continuo. |
| `w` / `last` | `last -n 10` | Muestra historial de inicios de sesión de usuarios. |
| `tcpdump` | `sudo tcpdump -i eth0 port 80` | Captura y analiza paquetes de red en directo. |
| **MÓDULO 5: CLOUD SECURITY (AWS / GCP)** | | |
| `aws configure` | `aws configure` | Configura credenciales y región para administrar la nube. |
| `aws s3 ls` | `aws s3 ls` | Lista los buckets de almacenamiento en tu cuenta AWS. |
| `aws iam` | `aws iam list-users` | Consulta usuarios y permisos dentro del entorno Cloud. |
| **MÓDULO 6: AUTOMATIZACIÓN & BLUE TEAM** | | |
| `crontab` | `crontab -e` | Programa scripts para ejecutarse automáticamente. |
| `systemctl` | `sudo systemctl restart ufw` | Administra estados de servicios (start, stop, status). |
