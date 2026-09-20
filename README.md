# Linux Security Toolkit 🛡️

Toolkit modular de ciberseguridad defensiva (Blue Team) para auditoría de sistemas, hardening de servicios, control de red y respuesta ante incidentes en servidores Linux.

## 📁 Contenido del Repositorio

| Script | Categoría | Descripción |
| :--- | :--- | :--- |
| **`audit_ssh.sh`** | Auditoría & Logs | Analiza `auth.log` y detecta intentos de fuerza bruta SSH. |
| **`harden_sshd.sh`** | Hardening | Desactiva accesos inseguros (root, contraseñas) en el archivo `sshd_config`. |
| **`setup_ufw.sh`** | Cortafuegos | Configura políticas estricta de firewall mediante UFW bajo el modelo Zero Trust. |
| **`check_ports.sh`** | Monitoreo Red | Muestra los procesos y sockets en escucha activa en el sistema. |
| **`isolate_host.sh`** | Respuesta Incidentes | Aísla el host de la red en caso de sospecha de vulneración. |

## 🚀 Requisitos e Instalación

Para descargar e instalar las herramientas en un entorno Linux/WSL2:

```bash
git clone [https://github.com/TU_USUARIO/linux-security-toolkit.git](https://github.com/TU_USUARIO/linux-security-toolkit.git)
cd linux-security-toolkit
chmod +x *.sh
