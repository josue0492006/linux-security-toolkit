#!/bin/bash
# ==============================================================================
# Script: isolate_host.sh
# Descripción: Aísla el servidor de la red ante una sospecha de intrusión
# Uso: sudo ./isolate_host.sh
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor, ejecuta este script con privilegios de root (sudo)."
  exit 1
fi

echo "[!] ATENCIÓN: Iniciando protocolo de aislamiento de emergencia..."

# Bloquear todo el tráfico entrante y saliente excepto SSH activo
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Permitir tráfico local en interfaz loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permitir conexiones SSH existentes para no perder la sesión de control
iptables -A INPUT -p tcp --dport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

echo "[+] Servidor aislado. Todo el tráfico externo ha sido bloqueado."
