#!/bin/bash
# ==============================================================================
# Script: setup_ufw.sh
# Descripción: Configura reglas estrictas en el Firewall UFW
# Uso: sudo ./setup_ufw.sh
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor, ejecuta este script con privilegios de root (sudo)."
  exit 1
fi

echo "[+] Restableciendo reglas predeterminadas de UFW..."
ufw --force reset

echo "[+] Estableciendo políticas por defecto (Bloquear entrada, Permitir salida)..."
ufw default deny incoming
ufw default allow outgoing

echo "[+] Permitiendo puertos esenciales..."
ufw allow 22/tcp comment 'SSH Management'
ufw allow 80/tcp comment 'HTTP Web'
ufw allow 443/tcp comment 'HTTPS Web'

echo "[+] Activando Firewall UFW..."
ufw --force enable

echo "[+] Estado actual del Firewall:"
ufw status verbose
