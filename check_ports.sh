#!/bin/bash
# ==============================================================================
# Script: check_ports.sh
# Descripción: Lista los servicios y procesos en escucha activa en la red
# Uso: ./check_ports.sh
# ==============================================================================

echo "=========================================="
echo "    AUDITORÍA DE SERVICIOS EN ESCUCHA     "
echo "=========================================="

if command -v ss &> /dev/null; then
    echo "[+] Puertos TCP/UDP abiertos y sus procesos (usando ss):"
    echo "--------------------------------------------------------"
    ss -tulpn | grep LISTEN
elif command -v netstat &> /dev/null; then
    echo "[+] Puertos TCP/UDP abiertos (usando netstat):"
    echo "--------------------------------------------------------"
    netstat -tulpn | grep LISTEN
else
    echo "[-] Error: Se requiere 'ss' o 'netstat' para ejecutar esta auditoría."
fi

echo "=========================================="
