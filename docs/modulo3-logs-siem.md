# 🛡️ Módulo 3: Auditoría de Logs, Monitoreo y SIEM

## Comandos Clave

### `sudo tail -f /var/log/auth.log` (o `/var/log/secure` en RHEL/CentOS)
* **¿Qué hace?:** Muestra en tiempo real los eventos de autenticación, inicios de sesión y elevaciones de privilegios (`sudo`).
* **¿Cuándo se usa?:** Durante la supervisión activa de accesos al servidor o para diagnosticar fallos de inicio de sesión.

### `grep "Failed password" /var/log/auth.log`
* **¿Qué hace?:** Filtra el archivo de logs para mostrar únicamente los intentos de inicio de sesión fallidos.
* **¿Cuándo se usa?:** Para detectar ataques de fuerza bruta dirigidos contra el servicio SSH.

### `journalctl -u sshd --since "1 hour ago"`
* **¿Qué hace?:** Muestra los registros del servicio SSH administrados por Systemd generados en la última hora.
* **¿Cuándo se usa?:** Para analizar la actividad reciente de un servicio específico durante la investigación de un incidente.

### `awk '{print $1}' /var/log/auth.log | sort | uniq -c | sort -nr`
* **¿Qué hace?:** Cuenta y ordena cuántas veces ha interactuado cada dirección IP en los registros de autenticación.
* **¿Cuándo se usa?:** Para identificar rápidamente las direcciones IP más agresivas que intentan autenticarse en el servidor.

### `sudo wazuh-agent -R` (o consulta en Dashboard de Wazuh)
* **¿Qué hace?:** Reinicia el agente del SIEM Wazuh para forzar el envío de telemetría y eventos al servidor central.
* **¿Cuándo se usa?:** Al integrar un nuevo servidor a la infraestructura de monitoreo del SOC.
