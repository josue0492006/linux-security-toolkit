#!/bin/bash
# ==============================================================================
# Script: harden_sshd.sh
# Descripción: Aplica directivas de seguridad en /etc/ssh/sshd_config
# Uso: sudo ./harden_sshd.sh
# ==============================================================================

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_CONFIG="/etc/ssh/sshd_config.bak_$(date +%F)"

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor, ejecuta este script con privilegios de root (sudo)."
  exit 1
fi

echo "[+] Creando copia de seguridad en $BACKUP_CONFIG..."
cp "$SSHD_CONFIG" "$BACKUP_CONFIG"

echo "[+] Aplicando reglas de hardening a SSH..."

# Desactivar acceso root por SSH
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"

# Desactivar autenticación por contraseña
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"

# Desactivar contraseñas vacías
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG"

# Limitar intentos máximos de autenticación
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG"

echo "[+] Reiniciando servicio SSH..."
systemctl restart sshd || service ssh restart

echo "[+] ¡Hardening SSH completado con éxito!"
