# Cheat Sheet: Administración de Sudoers con `visudo`

## Conceptos Clave
- **`visudo`**: Herramienta obligatoria para editar `/etc/sudoers`. Valida la sintaxis antes de guardar para evitar bloqueos del sistema.
- **Principio de Menor Privilegio**: Asignar permisos únicamente para los comandos necesarios en lugar de dar acceso root completo.

## Plantilla Base
`USUARIO DÓNDE=(COMO_QUIÉN) [OPCIONES:] /ruta/del/comando`

## Ejemplos Comunes
1. **Permiso a un comando específico para un usuario:**
   `sofia ALL=(ALL) /usr/bin/systemctl restart nginx`

2. **Permiso sin requerir contraseña (para automatizaciones):**
   `ana ALL=(ALL) NOPASSWD: /usr/bin/apt update`

3. **Permiso para todo un grupo (usa el prefijo `%`):**
   `%devs ALL=(ALL) /usr/bin/docker`
