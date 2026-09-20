# 🛡️ Módulo 2: Seguridad de Redes, Firewalls y Zero Trust

## Comandos Clave

### `sudo ufw default deny incoming`
* **¿Qué hace?:** Aplica la política base de Zero Trust: bloquea todo el tráfico entrante al servidor por defecto.
* **¿Cuándo se usa?:** Al configurar un servidor nuevo desde cero antes de exponerlo a internet.

### `sudo ufw allow 22/tcp`
* **¿Qué hace?:** Permite conexiones entrantes exclusivamente al puerto 22 (SSH) usando el protocolo TCP.
* **¿Cuándo se usa?:** Inmediatamente después de aplicar el `deny incoming` para no perder el acceso remoto al servidor.

### `sudo ufw enable`
* **¿Qué hace?:** Enciende y activa el firewall UFW en el sistema operativo.
* **¿Cuándo se usa?:** Después de definir todas las reglas de acceso necesarias (SSH, HTTP, HTTPS).

### `ss -tulpn`
* **¿Qué hace?:** Muestra todos los sockets de red escuchando en el sistema, indicando el puerto, el protocolo y el proceso (PID) asociado.
* **¿Cuándo se usa?:** Para auditar qué servicios o aplicaciones están expuestas a la red y detectar puertos sospechosos.

### `sudo iptables -L -n -v`
* **¿Qué hace?:** Lista todas las reglas de red a nivel de kernel de Linux de forma detallada y numérica.
* **¿Cuándo se usa?:** Para auditorías avanzadas de red o cuando se requiere depurar el comportamiento del firewall.
