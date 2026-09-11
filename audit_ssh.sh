#!/bin/bash

# ==============================================================================
# Script: audit_ssh.sh
# Objetivo: Auditar logs de autenticación para identificar intentos de fuerza bruta
# Fase 1: Linux Security Hardening
# ==============================================================================

# 1. Definición de variables
LOG_FILE="/var/log/auth.log"
UMBRAL_INTENTOS=3

# 2. Encabezado del reporte
echo "=================================================="
echo "    REPORTE DE AUDITORÍA DE SEGURIDAD SSH         "
echo "    Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================="
echo ""

# 3. Validación de existencia del archivo de log
if [ ! -f "$LOG_FILE" ]; then
    LOG_FILE="/var/log/secure"
    if [ ! -f "$LOG_FILE" ]; then
        echo "[ERROR] No se encontró un archivo de registros de autenticación válido."
        exit 1
    fi
fi

# 4. Procesamiento de logs y extracción de IPs
echo "[+] Analizando intentos fallidos de autenticación en: $LOG_FILE"
echo ""
printf "%-10s | %-15s\n" "INTENTOS" "DIRECCIÓN IP"
echo "--------------------------------------------------"

# Filtrado de eventos con expresión regular para extraer IPs
grep "Failed password" "$LOG_FILE" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq -c | sort -nr | while read -r CONTEO IP; do
    if [ "$CONTEO" -ge "$UMBRAL_INTENTOS" ]; then
        printf "%-10s | %-15s\n" "$CONTEO" "$IP"
    fi
done

echo ""
echo "=================================================="
echo "[+] Análisis completado."
