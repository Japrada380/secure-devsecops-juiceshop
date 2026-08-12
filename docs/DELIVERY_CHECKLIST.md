# Checklist final de entrega

## Identificación

- Repositorio: `https://github.com/Japrada380/secure-devsecops-juiceshop`
- Rama de entrega: `main`
- Proyecto: Secure DevSecOps — OWASP Juice Shop
- Autor: Jhon Alex Prada Gomez
- Fecha de revisión: 12 de agosto de 2026

## 1. Repositorio y documentación

- [x] Código publicado en la rama `main`.
- [x] README principal con arquitectura, controles, ejecución y limitaciones.
- [x] Enlaces Markdown locales comprobados sin rutas rotas.
- [x] Credenciales y secretos excluidos del repositorio.
- [x] Gitleaks ejecutado antes de los commits.
- [ ] Confirmar que el último pipeline de `main` finalice en verde.
- [ ] Abrir el repositorio en una ventana privada y comprobar acceso a los entregables.

## 2. Pipeline DevSecOps

- [x] Workflow principal en `.github/workflows/pipeline.yml`.
- [x] Acciones fijadas a referencias inmutables.
- [x] Semgrep SAST y reglas locales.
- [x] Gitleaks para detección de secretos.
- [x] Checkov para Terraform.
- [x] Trivy para filesystem e imagen.
- [x] SBOM en formato CycloneDX.
- [x] Construcción de imagen Docker.
- [x] OWASP ZAP autenticado con JWT.
- [x] Publicación de artefactos de seguridad.
- [x] Gates de seguridad documentados.
- [x] Pipeline #45 de VAPT: exitoso.
- [x] Pipeline #46 de Terraform: exitoso.
- [ ] Pipeline #47 de Respuesta a Incidentes: en ejecución durante esta revisión; confirmar resultado final.

## 3. Break Glass

- [x] Workflow manual separado.
- [x] Justificación e identificador de incidente/cambio.
- [x] Registro auditable mediante issue.
- [x] Aprobación de Seguridad.
- [x] Aprobación de Operaciones.
- [x] Ejecución manual #16 completada exitosamente.
- [ ] Confirmar visualmente que los entornos conservan revisores distintos y `Prevent self-review`.

## 4. VAPT

- [x] Informe consolidado en `vapt/VAPT_Report.md`.
- [x] Resumen ejecutivo, alcance, metodología y superficie de ataque.
- [x] V-01 SQL Injection confirmada.
- [x] V-07 Missing Rate Limiting confirmada.
- [x] V-09 IDOR confirmada.
- [x] XSS reflejado confirmado como hallazgo adicional.
- [x] JWT, Mass Assignment, Logging PII y Stored XSS documentados como no reproducibles.
- [x] Gitleaks documentado con resultado `no leaks found`.
- [x] Evidencias organizadas por `burp`, `gitleaks`, `logs` y `screenshots`.
- [x] PoC existentes conservadas sin alteración técnica.

## 5. Terraform

- [x] Módulo `security-baseline` documentado.
- [x] VPC, subredes y Flow Logs.
- [x] IAM, KMS y Secrets Manager.
- [x] S3 de logs, CloudTrail y AWS Config.
- [x] GuardDuty y Security Hub.
- [x] WAFv2 con logging y redacción de `Authorization`.
- [x] `terraform fmt -check -recursive` aprobado.
- [x] `terraform validate -no-color` aprobado.
- [x] Evidencia local en `terraform/evidence/terraform-local-validation.txt`.
- [x] Ausencia de `plan` y `apply` explicada: no se requiere una cuenta AWS real.
- [x] No se generaron recursos ni costos en AWS.

## 6. Respuesta a Incidentes

- [x] Informe maestro en `incident-response/INCIDENT_RESPONSE_REPORT.md`.
- [x] Hechos del escenario separados de hipótesis.
- [x] Línea de tiempo lógica y fuentes esperadas.
- [x] Inventario de IoC y observables.
- [x] Mapeo MITRE ATT&CK.
- [x] Ciclo de preparación, detección, contención, erradicación, recuperación y lecciones aprendidas.
- [x] Requisitos de preservación y cadena de custodia.
- [x] Playbook AWS CLI con precondiciones y reversión.
- [x] Reglas Sigma corregidas.
- [x] Plan de remediación priorizado.
- [x] Limitación explícita: no se ejecutaron acciones en AWS.

## 7. Evidencias que conviene mostrar en la sustentación

- [ ] Última ejecución verde del pipeline principal.
- [ ] Lista de jobs y artefactos del pipeline.
- [ ] Ejecución verde de Break Glass y sus dos aprobaciones.
- [ ] Resumen consolidado del VAPT.
- [ ] Capturas de SQLi, rate limiting y XSS reflejado.
- [ ] Evidencia HTTP de IDOR.
- [ ] Evidencia `no leaks found` de Gitleaks.
- [ ] Resultado `Success! The configuration is valid.` de Terraform.
- [ ] Diagrama textual y controles del módulo Terraform.
- [ ] Informe maestro y playbook seguro de Respuesta a Incidentes.

## 8. Comprobación previa al envío

Ejecutar sin incluir los respaldos locales:

```powershell
git status
git log -5 --oneline
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform validate -no-color
gitleaks detect --source . --no-git
```

Confirmar que:

- Los únicos archivos sin seguimiento sean respaldos locales conocidos.
- El último commit corresponda al entregable final.
- El pipeline de ese commit esté verde.
- No haya secretos en capturas, logs, reportes ni historial que se vaya a compartir.
- El enlace del repositorio y los permisos de acceso funcionen para el evaluador.

## 9. Estado de cierre

El contenido técnico y documental está completo. Quedan como verificaciones humanas finales el resultado verde del pipeline #47, la configuración visual de los entornos Break Glass y la accesibilidad pública del repositorio.

