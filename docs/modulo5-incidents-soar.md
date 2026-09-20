# 🛡️ Módulo 5: Respuesta a Incidentes y Automatización (SOAR)

## Comandos Clave

### `sudo kill -9 PID`
* **¿Qué hace?:** Envía la señal `SIGKILL` para finalizar de forma inmediata un proceso en ejecución.
* **¿Cuándo se usa?:** Durante la contención de un incidente para detener un proceso malicioso o malware detectado en memoria.

### `sudo ufw insert 1 deny from IP_ATACANTE to any`
* **¿Qué hace?:** Inserta una regla prioritaria en el firewall para bloquear todo el tráfico proveniente de una dirección IP específica.
* **¿Cuándo se usa?:** Para aislar inmediatamente a un atacante activo sin reiniciar el servicio de firewall.

### `last -a`
* **¿Qué hace?:** Muestra el historial completo de inicios de sesión en el sistema, especificando usuario, fecha, hora e IP de origen.
* **¿Cuándo se usa?:** Al iniciar el análisis forense tras confirmar un acceso no autorizado.

### `sudo lsof -i :PUERTO`
* **¿Qué hace?:** Muestra qué procesos y usuarios tienen abierto un puerto específico en la red.
* **¿Cuándo se usa?:** Para investigar conexiones de red no identificadas o sospechosas.

### `./isolate_host.sh` (Script propio)
* **¿Qué hace?:** Aplica reglas de firewall estrictas que cortan todo el tráfico entrante y saliente, dejando activa únicamente la conexión de administración.
* **¿Cuándo se usa?:** Al confirmar que un servidor ha sido comprometido y requiere aislamiento inmediato para contención.
