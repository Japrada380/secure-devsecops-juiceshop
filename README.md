# Secure DevSecOps – OWASP Juice Shop

Implementación de una práctica DevSecOps sobre OWASP Juice Shop que integra controles automatizados de seguridad, una línea base de seguridad para AWS en Terraform, evaluación VAPT y artefactos de respuesta ante incidentes.

## Estado del proyecto

| Componente | Estado |
|---|:---:|
| Pipeline de GitHub Actions | ✅ |
| Semgrep SAST y reglas personalizadas | ✅ |
| Gitleaks | ✅ |
| Checkov para Terraform | ✅ |
| Trivy filesystem e imagen | ✅ |
| SBOM CycloneDX | ✅ |
| ZAP autenticado con JWT | ✅ |
| Break Glass con dos aprobaciones | ✅ |
| Línea base AWS en Terraform | ✅ Validación estática |
| Informe VAPT | ✅ |
| Respuesta ante incidentes | ✅ |

La ejecución validada del pipeline principal finalizó en menos de 15 minutos. El despliegue real de la infraestructura AWS no forma parte de esta evidencia porque requiere una cuenta y credenciales autorizadas.

## Arquitectura

```text
Push a main
    |
    v
GitHub Actions
    |
    +-- Semgrep (SAST y reglas personalizadas)
    +-- Gitleaks (secretos e historial Git)
    +-- Checkov (Terraform)
    +-- Trivy filesystem
    +-- SBOM CycloneDX
    +-- Docker build
    +-- Trivy image
    +-- OWASP ZAP autenticado
            |
            +-- usuario efímero
            +-- JWT Bearer
            +-- OpenAPI + spider + active scan
            +-- reporte HTML/JSON
            +-- issue para MEDIUM
            +-- bloqueo para HIGH/CRITICAL

Workflow manual Break Glass
    +-- registro auditable en issue
    +-- aprobación de Seguridad
    +-- aprobación de Operaciones
    +-- autorización final
```

## Controles del pipeline

El workflow [`.github/workflows/pipeline.yml`](.github/workflows/pipeline.yml) se ejecuta con cada `push` a `main`.

### Semgrep

- Ejecuta reglas estándar y las reglas locales de `.github/semgrep-rules/`.
- Incluye controles personalizados para uso de `eval` y contraseñas embebidas.
- Un error o hallazgo que incumpla el gate detiene el pipeline.

### Gitleaks

- Revisa secretos en el historial Git disponible.
- El checkout usa historial completo para evitar análisis parciales.
- No requiere licencia para un repositorio personal.

### Checkov y Terraform

- Analiza el directorio `terraform/`.
- La validación realizada obtuvo **212 controles aprobados, 0 fallidos y 9 omitidos**.
- Las omisiones corresponden a decisiones justificadas para el alcance de la línea base.

### Trivy y SBOM

- El escaneo del filesystem bloquea vulnerabilidades `HIGH` y `CRITICAL` con corrección disponible.
- El escaneo de la imagen bloquea vulnerabilidades `CRITICAL`.
- La imagen base está fijada en `bkimminich/juice-shop:v20.0.0`.
- Las excepciones temporales se documentan en `.trivyignore.yaml`, incluyen justificación y fecha de expiración.
- El SBOM se genera en formato CycloneDX y se publica como artefacto `cyclonedx-sbom`.

### ZAP autenticado

El pipeline:

1. Inicia Juice Shop en una red Docker aislada.
2. Crea un usuario efímero con contraseña aleatoria.
3. Obtiene un JWT real mediante el endpoint de login.
4. Extrae la definición OpenAPI de la imagen.
5. Inyecta `Authorization: Bearer <token>` en las solicitudes de ZAP.
6. Ejecuta importación OpenAPI, spider, passive scan y active scan.
7. Publica los reportes HTML y JSON durante 30 días.
8. Crea un issue cuando existen hallazgos `MEDIUM`.
9. Bloquea la ejecución ante hallazgos `HIGH`/`CRITICAL` o errores del escaneo.

La configuración está en [`.github/zap/automation.yaml`](.github/zap/automation.yaml).

## Break Glass

El workflow [`.github/workflows/break-glass.yml`](.github/workflows/break-glass.yml) se ejecuta exclusivamente de forma manual y exige:

1. Justificación y referencia de incidente o cambio de emergencia.
2. Registro automático de un issue para auditoría.
3. Aprobación en `break-glass-security-approval`.
4. Aprobación posterior en `break-glass-operations-approval`.
5. Autorización final únicamente después de ambas etapas.

Los entornos deben tener revisores distintos, `Prevent self-review` habilitado y el bypass administrativo deshabilitado. GitHub conserva la identidad de cada revisor en el registro de protección del deployment.

## Infraestructura como Código

La línea base se encuentra en `terraform/modules/security-baseline/` e incluye:

- IAM y política de contraseña.
- KMS para cifrado de evidencias y registros.
- S3 privado, cifrado, versionado, logging y controles de transporte seguro.
- CloudTrail y validación de archivos de log.
- AWS Config.
- GuardDuty.
- Security Hub.
- VPC, subredes y VPC Flow Logs.
- WAFv2 y logging con campos sensibles redactados.
- Secrets Manager.

Validación local sin credenciales AWS:

```powershell
cd terraform
terraform fmt -recursive -check
terraform init -backend=false
terraform validate
```

Análisis local con el entorno virtual utilizado en Windows:

```powershell
& "$env:LOCALAPPDATA\checkov-venv\Scripts\python.exe" `
  "$env:LOCALAPPDATA\checkov-venv\Scripts\checkov" `
  --directory . --framework terraform --quiet
```

`terraform plan` y `terraform apply` requieren credenciales AWS válidas y autorización para consultar o modificar recursos. No deben emplearse credenciales personales o inventadas únicamente para completar la prueba.

## Ejecución local de Juice Shop

Requisitos:

- Git
- Docker Desktop

```powershell
git clone https://github.com/Japrada380/secure-devsecops-juiceshop.git
cd secure-devsecops-juiceshop
docker build --tag juice-shop:local .
docker run --rm --publish 3000:3000 juice-shop:local
```

La aplicación queda disponible en `http://localhost:3000`.

El repositorio no utiliza `docker-compose.yml`; el pipeline administra directamente los contenedores y la red temporal de DAST.

## VAPT

Los entregables se encuentran en `vapt/report/`:

- `executive-summary.md`: resumen ejecutivo.
- `attack-surface.md`: superficie de ataque.
- `vulnerabilities.md`: vulnerabilidades, evidencia, impacto y recomendaciones.
- `README.md`: alcance y navegación del informe.

## Respuesta ante incidentes

Los artefactos se encuentran en `incident-response/` e incluyen:

- Resumen ejecutivo para dirección.
- Análisis de causa raíz.
- Enriquecimiento de indicadores de compromiso.
- Inteligencia de amenazas.
- Reglas Sigma.
- Mapeo MITRE ATT&CK.
- Playbook de contención con AWS CLI.
- Plan de remediación.
- Configuración de threat intelligence para GuardDuty.

## Estructura del repositorio

```text
.
|-- .github/
|   |-- semgrep-rules/
|   |-- workflows/
|   |   |-- pipeline.yml
|   |   `-- break-glass.yml
|   `-- zap/
|       `-- automation.yaml
|-- incident-response/
|-- terraform/
|   `-- modules/security-baseline/
|-- vapt/report/
|-- .trivyignore.yaml
|-- Dockerfile
`-- README.md
```

## Evidencias

Las principales evidencias verificables son:

- Historial de ejecuciones en GitHub Actions.
- Artefacto `cyclonedx-sbom`.
- Artefacto `zap-authenticated-report`.
- Issues `[DAST][MEDIUM]` generados por ZAP.
- Issue `[BREAK-GLASS]` y registro de las dos aprobaciones.
- Resultado local de `terraform validate`.
- Resultado Checkov: 212 aprobados, 0 fallidos y 9 omitidos.
- Informes VAPT y artefactos de respuesta ante incidentes versionados.

## Decisiones y limitaciones

- Juice Shop es deliberadamente vulnerable; las excepciones de Trivy son temporales, explícitas y limitadas a la imagen de entrenamiento fijada.
- La infraestructura se validó de manera estática. No se ejecutó `terraform apply` por ausencia de credenciales AWS autorizadas.
- Los issues DAST representan hallazgos MEDIUM de ejecuciones específicas y sirven como evidencia de seguimiento.
- El tiempo de espera de aprobadores humanos en Break Glass no representa tiempo de cómputo del pipeline principal.

## Uso de inteligencia artificial

Se utilizó inteligencia artificial como apoyo para revisar configuraciones, interpretar errores, estructurar documentación y proponer controles. Cada cambio fue validado mediante herramientas determinísticas, ejecuciones del pipeline o revisión humana. Las decisiones de aceptación de riesgo, aprobación de emergencias y eventual despliegue en AWS permanecen bajo responsabilidad humana.

## Autor

**Jhon Alex Prada Gomez**

Proyecto desarrollado como prueba técnica de Ingeniería de Ciberseguridad para Simon Movilidad.
