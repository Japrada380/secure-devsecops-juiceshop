# Matriz de cumplimiento - línea base Terraform

Fecha de evaluación: 12 de agosto de 2026  
Alcance: revisión estática del código en `terraform/modules/security-baseline/`. No se desplegaron recursos en una cuenta AWS real.

## Criterios de estado

- **PASS:** el control está modelado de forma verificable en Terraform.
- **PARTIAL:** existe una implementación relacionada, pero no cubre todo el requisito.
- **FAIL:** el requisito no está modelado actualmente.
- **N/A:** no aplica al alcance declarado o requiere evidencia de ejecución fuera del código.

## Tabla de cumplimiento

| # | Control técnico | CIS AWS v1.4 | ISO 27001:2022 | Ley 1581 | Estado | Evidencia / brecha |
|---:|---|---|---|---|---|---|
| 1 | Política de contraseñas IAM: 14 caracteres, complejidad, 90 días y 24 contraseñas | 1.8-1.11 | A.5.17, A.8.5 | Art. 17, seguridad | **PASS** | `iam.tf`: `minimum_password_length=14`, complejidad, `max_password_age=90`, `password_reuse_prevention=24`. |
| 2 | Roles ECS separados y acceso mínimo al secreto | 1.16, 1.22 | A.5.15, A.5.18, A.8.2 | Art. 4(g), acceso restringido | **PASS** | `iam.tf`: roles de ejecución/aplicación y policy limitada al secreto y CMK. |
| 3 | Ausencia de `AdministratorAccess` en roles de aplicación | 1.16 | A.5.15, A.8.2 | Art. 17 | **PASS** | No se asocia `AdministratorAccess`; ejecución usa policy administrada específica de ECS. |
| 4 | Gestión de claves root y MFA root | 1.4, 1.5 | A.5.16, A.8.5 | Art. 17 | **FAIL** | No existe control Terraform/Config que valide claves root inactivas o MFA root. |
| 5 | S3 de logs con Block Public Access, cifrado KMS y versionado | 2.1.1, 2.1.2, 2.1.4 | A.8.12, A.8.24 | Arts. 17 y 19 | **PASS** | `main.tf`: public access block, SSE-KMS, bucket key y versionado. |
| 6 | Denegación de transporte inseguro hacia S3 | 2.1.2 | A.8.20, A.8.24 | Art. 17 | **PASS** | Bucket policy `DenyInsecureTransport` para `aws:SecureTransport=false`. |
| 7 | Lifecycle Glacier a 180 días y Object Lock COMPLIANCE | 2.1.3 | A.5.33, A.8.13 | Arts. 12 y 17 | **FAIL** | Existe expiración/retención de versiones, pero no transición Glacier ni Object Lock. |
| 8 | VPC de tres capas sin IP pública automática | 5.2, 5.3 | A.8.20, A.8.22 | Art. 17 | **PASS** | `vpc.tf`: subredes public/app/data y `map_public_ip_on_launch=false`. |
| 9 | Distribución en dos AZ y NACL restrictiva para datos | 5.1, 5.2 | A.8.20, A.8.22 | Art. 17 | **FAIL** | Solo existe una subred por capa; no se declaran AZ ni NACL específicas. |
| 10 | Grupo de seguridad predeterminado sin reglas | 5.4 | A.8.20 | Art. 17 | **PASS** | `aws_default_security_group.default` sin ingress/egress permisivo. |
| 11 | VPC Flow Logs cifrados con retención | 3.9 | A.8.15, A.8.16 | Arts. 17 y 19 | **PARTIAL** | Se envían a CloudWatch con KMS y retención; falta entrega simultánea a S3. |
| 12 | RDS Multi-AZ, privado, cifrado, backups y parámetros SSL/logging | 2.3.x | A.8.13, A.8.20, A.8.24 | Arts. 17 y 19 | **FAIL** | No se modela una instancia RDS ni parameter group. |
| 13 | CMK por servicio y rotación anual | 3.8 | A.8.24 | Art. 17 | **PARTIAL** | Existen CMK separadas para logs y secretos con rotación; faltan CMK dedicadas para RDS/S3/ECS. |
| 14 | Secrets Manager con acceso por IAM y rotación de 30 días | 1.16 | A.5.17, A.8.24 | Art. 17 | **PARTIAL** | Secreto cifrado y acceso IAM; rotación solo se activa si se suministra Lambda compatible. |
| 15 | CloudTrail multirregión, validación y CloudWatch Logs | 3.1-3.7 | A.8.15, A.8.16 | Arts. 17 y 19 | **PASS** | `cloudtrail.tf`: multi-region, global events, validation, KMS y CloudWatch Logs. |
| 16 | Metric filters y alarmas para root, IAM, SG y DisableKeyRotation | 4.3-4.11 | A.8.15, A.8.16 | Art. 17 | **FAIL** | No existen `aws_cloudwatch_log_metric_filter` ni alarms para estos eventos. |
| 17 | AWS Config recorder y reglas administradas requeridas | 3.5 | A.5.36, A.8.9, A.8.16 | Art. 17 | **PARTIAL** | Recorder/delivery habilitados; faltan las seis reglas administradas indicadas por la rúbrica. |
| 18 | GuardDuty con S3 y Malware Protection | 4.1 | A.5.7, A.8.16 | Art. 17 | **PARTIAL** | Detector y features habilitados en una región; falta cobertura multirregión y SNS para HIGH+. |
| 19 | Security Hub con CIS v1.4 y FSBP | 4.1 | A.5.36, A.8.16 | Art. 17 | **PASS** | `securityhub.tf`: suscripciones CIS AWS Foundations v1.4 y FSBP. |
| 20 | WAF con reglas Common, Known Bad Inputs y SQLi | 5.4 | A.8.20, A.8.26 | Art. 17 | **PASS** | `waf.tf`: tres grupos administrados en WAF regional con métricas y logs. |
| 21 | Rate limit 1.000/5 min para autenticación | 5.4 | A.8.20, A.8.26 | Art. 17 | **FAIL** | No existe `rate_based_statement` con scope-down al endpoint de login. |
| 22 | Georrestricción CO/PE/US y estrategia para VPN | 5.4 | A.8.20, A.8.26 | Art. 17 | **FAIL** | No existe `geo_match_statement` ni mecanismo de excepciones. |
| 23 | Redacción del header Authorization en logs WAF | 3.7 | A.8.11, A.8.15 | Principios de acceso y seguridad | **PASS** | `waf.tf`: `redacted_fields` para `authorization`. |

## Resumen

| Estado | Cantidad |
|---|---:|
| PASS | 11 |
| PARTIAL | 5 |
| FAIL | 7 |
| N/A | 0 |

La matriz demuestra controles implementados y brechas pendientes; no representa certificación formal ni evidencia de operación en AWS. Los controles PARTIAL y FAIL forman parte del backlog descrito en `docs/CHALLENGES_NEXT_STEPS.md`.
