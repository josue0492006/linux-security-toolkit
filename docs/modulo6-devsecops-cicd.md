# 🛡️ Módulo 6: DevSecOps y CI/CD con GitHub Actions

## Comandos Clave (Seguridad en Pipeline e IaC)

### `checkov -d .`
* **¿Qué hace?:** Escanea archivos de Infraestructura como Código (Terraform, CloudFormation, Kubernetes) en busca de fallos de seguridad.
* **¿Cuándo se usa?:** Antes de desplegar infraestructura a producción para evitar configuraciones inseguras.

### `trivy image nombre_imagen:tag`
* **¿Qué hace?:** Escanea imágenes de contenedores Docker buscando vulnerabilidades conocidas (CVEs) en dependencias y sistema operativo.
* **¿Cuándo se usa?:** Dentro del pipeline de integración continua (CI/CD) antes de publicar un contenedor a un registro.

### `git secrets --scan`
* **¿Qué hace?:** Examina el historial de Git y los archivos locales para detectar claves de API, contraseñas o tokens expuestos por accidente.
* **¿Cuándo se usa?:** Como gancho local (*pre-commit hook*) antes de realizar un `git push` al repositorio público.

### `shellcheck script.sh`
* **¿Qué hace?:** Realiza un análisis estático de scripts en Bash para detectar errores de sintaxis, variables no declaradas o riesgos de seguridad.
* **¿Cuándo se usa?:** Durante la fase de desarrollo y pruebas de automatizaciones en Bash.
