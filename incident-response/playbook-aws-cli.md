# Playbook seguro de contención con AWS CLI

## Propósito y advertencias

Este documento contiene comandos de referencia para un incidente autorizado. No debe ejecutarse como un script ni copiarse directamente a producción. Antes de cada acción se deben confirmar cuenta, región, recurso, impacto, aprobación, preservación de evidencia y mecanismo de reversión.

Los valores entre `<...>` son obligatorios y no deben sustituirse por identificadores inventados. Use un rol de respuesta a incidentes con privilegios controlados y registre las acciones en UTC.

## 1. Confirmar el contexto

```bash
aws sts get-caller-identity
aws configure get region
```

Deténgase si la cuenta o región no corresponden al incidente.

## 2. Preservar configuración de la identidad

```bash
aws iam get-user --user-name svc-monitoring
aws iam list-access-keys --user-name svc-monitoring
aws iam list-attached-user-policies --user-name svc-monitoring
aws iam list-user-policies --user-name svc-monitoring
aws iam list-groups-for-user --user-name svc-monitoring
```

Guarde las salidas en el repositorio forense autorizado y calcule sus hashes. No incluya secretos.

## 3. Aplicar denegación temporal

Cree y revise previamente un archivo `deny-all.json` con una política de denegación explícita. Después de aprobación:

```bash
aws iam put-user-policy \
  --user-name svc-monitoring \
  --policy-name IR-Temporary-Deny-All \
  --policy-document file://deny-all.json
```

Contenido de referencia para revisión:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "IncidentContainment",
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*"
  }]
}
```

Esta acción contiene nuevas solicitudes de la identidad, pero no sustituye la investigación de roles asumidos, credenciales derivadas o recursos ya comprometidos.

**Reversión:** retirar la política únicamente después de erradicación, rotación y aprobación:

```bash
aws iam delete-user-policy \
  --user-name svc-monitoring \
  --policy-name IR-Temporary-Deny-All
```

## 4. Inactivar access keys

Por cada identificador devuelto por `list-access-keys`:

```bash
aws iam update-access-key \
  --user-name svc-monitoring \
  --access-key-id <ACCESS_KEY_ID> \
  --status Inactive
```

No elimine las claves antes de preservar sus metadatos. La reversión (`--status Active`) requiere aprobación y normalmente debe evitarse; es preferible emitir credenciales nuevas tras el cierre.

## 5. Retirar acceso de consola

Después de documentar la existencia del perfil:

```bash
aws iam get-login-profile --user-name svc-monitoring
aws iam delete-login-profile --user-name svc-monitoring
```

Eliminar el perfil de login no revoca access keys ni todas las sesiones temporales. Para usuarios IAM, los tokens emitidos antes de una hora determinada pueden restringirse mediante una política temporal basada en `aws:TokenIssueTime`; su diseño debe revisarse específicamente para el entorno.

## 6. Retirar privilegios añadidos

Verifique primero la asociación:

```bash
aws iam list-attached-user-policies --user-name svc-monitoring
```

Si `AdministratorAccess` fue asociado por el atacante y la retirada está aprobada:

```bash
aws iam detach-user-policy \
  --user-name svc-monitoring \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

No revierta esta acción con privilegios administrativos. Recupere la función legítima mediante una política de mínimo privilegio revisada.

## 7. Preservar EC2 antes de aislar

Resuelva la región, los volúmenes y los grupos actuales:

```bash
aws ec2 describe-instances --instance-ids i-0abc1234def56789
```

Cree snapshots de cada volumen autorizado:

```bash
aws ec2 create-snapshot \
  --volume-id <VOLUME_ID> \
  --description "IR evidence <INCIDENT_ID> <UTC_TIMESTAMP>"
```

Registre los identificadores y espere confirmación de los snapshots antes de acciones destructivas.

## 8. Aislar EC2

Confirme que `<QUARANTINE_SG_ID>` existe en la misma VPC, que no permite tráfico no autorizado y que conserva el canal forense requerido:

```bash
aws ec2 modify-instance-attribute \
  --instance-id i-0abc1234def56789 \
  --groups <QUARANTINE_SG_ID>
```

**Reversión:** restaure únicamente los grupos registrados en el paso 7, después de recuperación aprobada:

```bash
aws ec2 modify-instance-attribute \
  --instance-id i-0abc1234def56789 \
  --groups <ORIGINAL_SG_ID_1> <ORIGINAL_SG_ID_2>
```

## 9. Investigar y detener tareas ECS

Liste clústeres, tareas y definiciones; preserve sus descripciones y logs. Solo después identifique tareas que usen el digest o definición maliciosa:

```bash
aws ecs list-clusters
aws ecs describe-task-definition --task-definition <TASK_DEFINITION_ARN>
aws ecs stop-task \
  --cluster <CLUSTER_ARN> \
  --task <TASK_ARN> \
  --reason "Authorized incident containment <INCIDENT_ID>"
```

Detener una tarea administrada por un servicio puede causar que ECS la recree. Antes de actuar, revise el servicio, desired count y mecanismo de despliegue.

## 10. Preservar logs

No use nombres genéricos ni descargue datos a estaciones no autorizadas. Copie desde el bucket y prefijo exactos a un destino forense aprobado:

```bash
aws s3 sync \
  s3://<SOURCE_LOG_BUCKET>/<PREFIX>/ \
  <AUTHORIZED_EVIDENCE_DESTINATION> \
  --no-follow-symlinks
```

Registre version IDs, object metadata y hashes cuando aplique. No modifique ni elimine la fuente.

## 11. Verificación posterior

- Confirmar que las claves estén inactivas y el login profile ausente.
- Confirmar que la política temporal de denegación esté aplicada.
- Revisar nuevos eventos asociados a la identidad, IP, roles y recursos.
- Confirmar que CloudTrail, GuardDuty, Config, DNS logs y VPC Flow Logs sigan operativos.
- Mantener una bitácora de comandos, resultados, aprobador y hora UTC.

