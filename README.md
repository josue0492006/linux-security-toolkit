# 🚀 NOC Junior & Linux Infrastructure Troubleshooting Cheat Sheet

> **Guía de referencia rápida y runbook operativo para Linux de producción (Ubuntu/Debian).**

Orientada al diagnóstico de incidentes **L1/NOC**, la mitigación inicial, la validación de servicios y el escalamiento estructurado.

**Objetivo:** diagnosticar problemas de servicios, logs, conectividad, puertos, recursos del sistema y permisos sin realizar cambios innecesarios en producción.

---

## 📚 Índice

1. [Servicios y control de demonios](#-1-servicios-y-control-de-demonios-systemd)
2. [Análisis de logs y registros](#-2-análisis-de-logs-y-registros-journalctl)
3. [Sockets, puertos y procesos](#-3-diagnóstico-de-sockets-puertos-y-procesos-ss-y-ps)
4. [Conectividad, DNS y red](#-4-conectividad-externa-dns-y-red-dig-nc-curl)
5. [Almacenamiento y recursos](#-5-almacenamiento-y-recursos-del-sistema-df-du-free-top)
6. [Permisos y ACL POSIX](#-6-permisos-de-archivos-y-acl-posix-setfacl-y-getfacl)
7. [Reporte de incidentes NOC](#-7-plantilla-estándar-para-reporte-de-incidentes-noc)
8. [Buenas prácticas operativas](#-8-buenas-prácticas-operativas)

---

## 🛠️ 1. Servicios y control de demonios (systemd)

Diagnóstico del estado de los servicios, administración de procesos gestionados por systemd y validación de la configuración de arranque.

### Consultar el estado de un servicio

```bash
systemctl status <servicio>.service
```

### Iniciar, detener o reiniciar un servicio

```bash
sudo systemctl start <servicio>.service
sudo systemctl stop <servicio>.service
sudo systemctl restart <servicio>.service
```

### Recargar la configuración de una aplicación

```bash
sudo systemctl reload <servicio>.service
```

### Recargar las unidades de systemd

```bash
sudo systemctl daemon-reload
```

### Verificar el estado y el inicio automático

```bash
systemctl is-active <servicio>.service
systemctl is-enabled <servicio>.service
```

### Identificar servicios fallidos

```bash
systemctl --failed
```

**Nota operativa:** `reload` depende de que el servicio admita esta operación. `daemon-reload` vuelve a leer las definiciones de las unidades de systemd, pero no reinicia automáticamente los servicios.

---

## 📜 2. Análisis de logs y registros (journalctl)

Inspección de registros para identificar errores de inicio, fallos de dependencias, excepciones y posibles causas de incidentes.

### Seguir los logs en tiempo real

```bash
journalctl -u <servicio>.service -f
```

### Consultar las últimas 50 líneas

```bash
journalctl -u <servicio>.service -n 50 --no-pager
```

### Mostrar errores y mensajes de mayor gravedad

```bash
journalctl -u <servicio>.service -p err..emerg
```

### Consultar los registros de la última hora

```bash
journalctl -u <servicio>.service --since "1 hour ago"
```

### Consultar un intervalo específico

```bash
journalctl -u <servicio>.service \
  --since "2026-10-24 00:00:00" \
  --until "2026-10-24 03:00:00"
```

### Consultar los mensajes del arranque actual

```bash
journalctl -b
```

### Consultar errores del kernel

```bash
journalctl -k -p err
```

**Nota operativa:** verifica la zona horaria del servidor antes de correlacionar marcas de tiempo con alertas externas. El acceso a determinados registros puede requerir privilegios adicionales.

---

## 🌐 3. Diagnóstico de sockets, puertos y procesos (ss y ps)

Identificación de puertos en escucha, procesos asociados y posibles conflictos como `EADDRINUSE` (dirección o puerto ya en uso).

### Listar sockets TCP en escucha

```bash
sudo ss -ltnp
```

### Listar sockets UDP

```bash
sudo ss -lunp
```

### Consultar todas las conexiones TCP

```bash
sudo ss -tanp
```

### Comprobar si el puerto TCP 8080 está en escucha

```bash
sudo ss -ltnp | grep ':8080'
```

### Buscar procesos por nombre

```bash
ps aux | grep '[n]ombre_proceso'
```

### Consultar información de un PID

```bash
ps -p <PID> -o pid,ppid,user,stat,%cpu,%mem,cmd
```

### Solicitar la terminación normal de un proceso

```bash
sudo kill -TERM <PID>
```

**Nota operativa:** utiliza `kill -9 <PID>` únicamente como último recurso si el proceso no responde a una terminación normal. Un proceso zombi ya ha terminado y no puede eliminarse mediante `kill -9`; normalmente hay que investigar su proceso padre.

---

## 🛰️ 4. Conectividad externa, DNS y red (dig, nc y curl)

Verificación de resolución DNS, conectividad TCP y respuesta de servicios web.

### Consultar la resolución DNS

```bash
dig <dominio.com>
```

### Consultar registros IPv4

```bash
dig +short A <dominio.com>
```

### Consultar registros IPv6

```bash
dig +short AAAA <dominio.com>
```

### Alternativa para consultar DNS

```bash
nslookup <dominio.com>
```

### Probar conectividad TCP con un puerto remoto

```bash
nc -zv <IP_o_dominio> <puerto>
```

Ejemplo para HTTPS:

```bash
nc -zv api.proveedor.com 443
```

### Consultar los encabezados HTTP

```bash
curl -I --connect-timeout 5 https://<dominio.com>
```

### Examinar los detalles de la conexión

```bash
curl -v --connect-timeout 5 https://<dominio.com>
```

### Probar una conexión TCP sin una petición HTTP

```bash
curl -v --connect-timeout 5 telnet://<IP_o_dominio>:<puerto>
```

**Nota operativa:** que un puerto responda no garantiza que la aplicación funcione correctamente. Distingue entre fallos de DNS, conectividad TCP, negociación TLS y respuestas HTTP. La disponibilidad de `dig` y `nc` depende de los paquetes instalados.

---

## 💾 5. Almacenamiento y recursos del sistema (df, du, free y top)

Diagnóstico de falta de espacio, consumo elevado de memoria y saturación de CPU.

### Consultar el espacio disponible

```bash
df -h
```

### Consultar el uso de inodos

```bash
df -i
```

### Identificar las entradas que más espacio ocupan en `/var/log`

```bash
sudo du -sh /var/log/* 2>/dev/null | sort -h
```

### Consultar RAM y swap

```bash
free -h
```

### Consultar procesos y consumo de recursos en tiempo real

```bash
top
```

Alternativa interactiva, si está instalada:

```bash
htop
```

### Consultar tiempo activo y carga promedio

```bash
uptime
```

### Identificar los procesos con mayor consumo de CPU

```bash
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head
```

### Identificar los procesos con mayor consumo de memoria

```bash
ps -eo pid,comm,%mem,%cpu --sort=-%mem | head
```

**Nota operativa:** una carga elevada no implica necesariamente falta de CPU; también puede relacionarse con procesos bloqueados por operaciones de entrada/salida. Comprueba los logs y las métricas de monitorización antes de intervenir.

---

## 🔒 6. Permisos de archivos y ACL POSIX (setfacl y getfacl)

Administración de permisos específicos para usuarios sin modificar el propietario ni el grupo principal de archivos y directorios.

### Consultar permisos y ACL

```bash
getfacl /ruta/al/directorio
```

### Conceder lectura y acceso a directorios para el contenido existente

```bash
sudo setfacl -R -m u:<usuario>:r-X /ruta/al/directorio
```

La `X` mayúscula concede ejecución únicamente a directorios y archivos que ya tengan algún permiso de ejecución.

### Establecer una ACL predeterminada para nuevas entradas

```bash
sudo setfacl -m d:u:<usuario>:r-X /ruta/al/directorio
```

### Consultar las ACL de un archivo específico

```bash
getfacl /ruta/al/directorio/archivo.log
```

### Eliminar ACL extendidas

```bash
sudo setfacl -b /ruta/al/directorio
```

**Precaución:** `setfacl -b` elimina las ACL extendidas existentes del objeto indicado y puede retirar permisos específicos de otros usuarios.

### Ejemplo práctico: usuario `analista`

Conceder permisos de lectura y acceso a directorios sobre el contenido existente:

```bash
sudo setfacl -R -m u:analista:r-X /var/log/app/
```

Configurar permisos ACL predeterminados para nuevas entradas:

```bash
sudo setfacl -m d:u:analista:r-X /var/log/app/
```

Verificar los permisos resultantes:

```bash
getfacl /var/log/app/
```

**Nota operativa:** las ACL predeterminadas se heredan al crear archivos y directorios dentro de la carpeta, pero los permisos efectivos también dependen de los permisos solicitados por el proceso creador y de la máscara ACL. Verifica las ACL efectivas de los archivos nuevos.

Estos comandos no modifican el propietario ni el grupo principal. La configuración recursiva puede cambiar los permisos ACL de numerosos objetos, por lo que debe revisarse antes de ejecutarse en producción.

---

## 📋 7. Plantilla estándar para reporte de incidentes NOC

Formato de documentación para registrar alertas, hallazgos, acciones de mitigación y resultados de validación.

```text
==================================================
              REPORTE DE INCIDENTE NOC
==================================================

Fecha/Hora: YYYY-MM-DD HH:MM UTC
Servidor/Host: <hostname>
Servicio afectado: <servicio>
Ticket/Incidente: <ID>
Severidad: ALTA / MEDIA / BAJA

1. ALERTA DETECTADA
   Descripción:
   [Ej.: puerto 8080 sin respuesta / HTTP 502]

2. DIAGNÓSTICO REALIZADO
   Hallazgos:
   [Describir evidencias, errores y métricas]

   Comandos ejecutados:
   [Indicar comandos y resultados relevantes]

3. CAUSA RAÍZ
   Estado:
   [Confirmada / Hipótesis pendiente de validación]

   Evidencia:
   [Describir la causa con evidencia verificable]

4. ACCIONES DE MITIGACIÓN
   - [Acción realizada]
   - [Resultado observado]
   - [Cambios efectuados, si corresponde]

5. VALIDACIÓN POSTERIOR
   Estado del servicio: [active / inactive / failed]
   Logs: [OK / ERROR / PENDIENTE]
   Conectividad: [OK / ERROR / PENDIENTE]
   Monitorización: [RESUELTA / ACTIVA]

6. ESCALAMIENTO Y SEGUIMIENTO
   Equipo receptor: [equipo / responsable]
   Pendientes: [acciones restantes]
   Evidencias: [logs / métricas / ticket relacionado]

==================================================
```

---

## ✅ 8. Buenas prácticas operativas

- **Diagnosticar antes de modificar:** recopila el estado del servicio, los logs y las métricas antes de reiniciar procesos.
- **Aplicar el principio de mínimo privilegio:** utiliza `sudo` solo cuando sea necesario y concede únicamente los permisos requeridos.
- **Evitar acciones destructivas:** no utilices `kill -9`, elimines registros ni cambies permisos recursivamente sin una justificación clara.
- **Validar después de intervenir:** confirma el estado del servicio, la conectividad y la ausencia de nuevos errores.
- **Documentar y escalar:** registra comandos, resultados, hora, impacto y acciones pendientes en el ticket.
- **Proteger la información:** elimina contraseñas, tokens, credenciales y otros secretos antes de compartir logs o capturas.
- **Respetar los procedimientos de cambio:** en producción, solicita autorización cuando corresponda y sigue el proceso de escalamiento de la organización.


