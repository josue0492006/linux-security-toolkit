# Linux Security Toolkit 🛡️

Colección de scripts en Bash para ciberseguridad defensiva (Blue Team), auditoría de logs y aseguramiento de servidores Linux.

## 📋 Proyectos incluidos

### 1. Auditoría de SSH (`audit_ssh.sh`)
Script para analizar registros de autenticación en Linux (`/var/log/auth.log`), detectar intentos fallidos de inicio de sesión por fuerza bruta y consolidar las direcciones IP atacantes.

#### Uso:
```bash
chmod +x audit_ssh.sh
./audit_ssh.sh
