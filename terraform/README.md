# Línea base de seguridad AWS con Terraform

Este directorio define una línea base de seguridad para AWS mediante Terraform. El alcance del entregable es diseño, revisión estática y validación local; no requiere una cuenta AWS real ni contempla el despliegue de recursos.

## Estado de validación

Validado localmente el 12 de agosto de 2026 con:

- Terraform CLI `1.15.8`.
- AWS Provider `6.58.0`.
- `terraform fmt -check -recursive` sin diferencias.
- `terraform validate -no-color` con resultado satisfactorio.

No se ejecutaron `terraform plan` ni `terraform apply`, porque la configuración utiliza datos de identidad de AWS y esos comandos requieren credenciales autorizadas. Esta limitación no afecta la validación sintáctica y estructural del código.

La salida reproducible está disponible en `evidence/terraform-local-validation.txt`.

## Arquitectura

```text
Root module
└── modules/security-baseline
    ├── Red
    │   ├── VPC
    │   ├── Subred pública
    │   ├── Subred de aplicación
    │   ├── Subred de datos
    │   └── VPC Flow Logs
    ├── Identidad y secretos
    │   ├── Política de contraseñas IAM
    │   ├── Roles de aplicación y ejecución ECS
    │   ├── Secrets Manager
    │   └── Claves KMS con rotación
    ├── Auditoría y postura
    │   ├── S3 central de logs
    │   ├── CloudTrail multirregión
    │   ├── AWS Config
    │   ├── GuardDuty
    │   └── Security Hub
    └── Protección de aplicación
        ├── WAFv2
        ├── Reglas administradas AWS
        └── Logging con Authorization redactado
```

## Controles implementados

### Red

- VPC con DNS habilitado.
- Subredes separadas por nivel: pública, aplicación y datos.
- Asignación automática de IP pública deshabilitada.
- Grupo de seguridad predeterminado sin reglas permisivas.
- VPC Flow Logs para todo el tráfico, con retención configurable y cifrado KMS.

La línea base define segmentación, pero no crea recursos de cómputo, tablas de rutas, gateways ni conectividad externa.

### Identidad y acceso

- Política de contraseña IAM con longitud mínima de 14 caracteres, complejidad, caducidad y prevención de reutilización.
- Roles separados para ejecución de tareas ECS y aplicación.
- Acceso de mínimo privilegio al secreto de base de datos y su clave KMS.

### Protección de secretos y cifrado

- Secret Manager cifrado con una clave KMS dedicada.
- La versión inicial del secreto está deshabilitada por defecto para evitar almacenar credenciales en el estado Terraform.
- Rotación opcional cuando se proporciona una función Lambda compatible.
- Rotación automática habilitada en las claves KMS.

### Auditoría y monitoreo

- Bucket S3 privado para logs, con cifrado KMS, versionado, bloqueo de acceso público y denegación de transporte inseguro.
- CloudTrail multirregión con eventos globales, validación de integridad, eventos de administración y eventos de datos S3.
- Envío de CloudTrail a CloudWatch Logs y notificaciones SNS cifradas.
- AWS Config con registro de recursos soportados.
- GuardDuty con eventos S3, auditoría EKS y protección contra malware EBS.
- Security Hub con CIS AWS Foundations Benchmark y AWS Foundational Security Best Practices.

### Protección web

- WAFv2 regional con reglas administradas para amenazas comunes, entradas maliciosas conocidas e inyección SQL.
- Métricas, solicitudes muestreadas y registros habilitados.
- Campo `Authorization` redactado en los logs de WAF.

## Estructura

```text
terraform/
├── main.tf
├── outputs.tf
├── provider.tf
├── variables.tf
├── versions.tf
├── evidence/
│   └── terraform-local-validation.txt
└── modules/security-baseline/
    ├── cloudtrail.tf
    ├── config.tf
    ├── guardduty.tf
    ├── iam.tf
    ├── kms.tf
    ├── main.tf
    ├── outputs.tf
    ├── secrets.tf
    ├── securityhub.tf
    ├── variables.tf
    ├── vpc.tf
    └── waf.tf
```

## Reproducción de la validación local

Desde `terraform/`:

```powershell
terraform fmt -check -recursive
terraform validate -no-color
```

Resultado esperado de la segunda instrucción:

```text
Success! The configuration is valid.
```

`terraform validate` verifica la sintaxis y consistencia interna, pero no confirma permisos, disponibilidad regional, cuotas, costos ni creación exitosa de recursos en una cuenta AWS.

## Despliegue fuera del alcance

En un entorno AWS autorizado, el flujo posterior sería revisar identidad y región, configurar un backend remoto seguro, ejecutar `terraform plan` y someter el plan a aprobación antes de `terraform apply`. Ninguno de esos pasos fue necesario ni ejecutado para este entregable.

