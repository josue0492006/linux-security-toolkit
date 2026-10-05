# 🛡️ Módulo 4: Fundamentos de Seguridad en AWS

## Comandos Clave (AWS CLI y Herramientas Cloud)

### `aws sts get-caller-identity`
* **¿Qué hace?:** Devuelve el ID de la cuenta, la ARN y el usuario o rol actualmente autenticado en la AWS CLI.
* **¿Cuándo se usa?:** Para validar las credenciales activas antes de ejecutar comandos de infraestructura en la nube.

### `aws iam list-access-keys --user-name nombre_usuario`
* **¿Qué hace?:** Lista las llaves de acceso asociadas a un usuario en AWS IAM.
* **¿Cuándo se usa?:** Durante auditorías de identidad para detectar credenciales antiguas o sin rotar.

### `aws ec2 describe-security-groups --filters Name=ip-permission.from-port,Values=22`
* **¿Qué hace?:** Busca todos los Security Groups que tienen abierto el puerto 22 (SSH).
* **¿Cuándo se usa?:** Para identificar reglas de firewall en la nube que expongan puertos sensibles hacia internet (`0.0.0.0/0`).

### `aws s3api get-bucket-encryption --bucket nombre_bucket`
* **¿Qué hace?:** Muestra la configuración de cifrado en reposo aplicada a un bucket de almacenamiento S3.
* **¿Cuándo se usa?:** Durante revisiones de cumplimiento de seguridad en datos almacenados en la nube.

### `prowler aws --profile default`
* **¿Qué hace?:** Ejecuta un escaneo automatizado sobre la cuenta de AWS evaluando cientos de controles de seguridad (CIS Benchmarks).
* **¿Cuándo se usa?:** Para generar reportes completos de vulnerabilidades en la infraestructura cloud.
