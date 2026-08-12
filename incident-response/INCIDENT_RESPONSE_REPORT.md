# Informe consolidado de respuesta a incidentes

## 1. Resumen ejecutivo

El escenario analizado describe el uso no autorizado de credenciales asociadas a `svc-monitoring` en AWS. De acuerdo con los artefactos proporcionados, el actor elevó privilegios, accedió repetidamente a objetos de Amazon S3, realizó operaciones de descifrado con AWS KMS, registró una definición de tarea ECS maliciosa e intentó afectar CloudTrail. El intento contra CloudTrail fue bloqueado por una Service Control Policy (SCP), y GuardDuty reportó actividad compatible con exfiltración por DNS.

El impacto potencial es crítico por la posible exposición de información, el abuso de privilegios administrativos, la persistencia mediante contenedores y el intento de afectar evidencias de auditoría.

Este informe es un ejercicio documental basado en el escenario suministrado. No constituye una investigación forense ejecutada sobre una cuenta AWS real y no afirma validaciones externas que no estén documentadas.

## 2. Alcance y fuentes

Se consolidaron los artefactos existentes en `incident-response/`:

- Resumen ejecutivo para gerencia.
- Análisis de causa raíz.
- Inventario y enriquecimiento inicial de indicadores.
- Inteligencia de amenazas.
- Mapeo MITRE ATT&CK.
- Reglas Sigma.
- Playbook de contención mediante AWS CLI.
- Plan de remediación.
- Lista de IP para GuardDuty.

No se consultaron CloudTrail, GuardDuty, VPC Flow Logs, S3, KMS, ECS ni EC2 reales. Los nombres, cantidades y eventos se consideran hechos del escenario, no observaciones independientes realizadas durante esta consolidación.

## 3. Clasificación de la información

### 3.1 Hechos declarados por el escenario

- Uso de la identidad `svc-monitoring`.
- Inicio de sesión desde la IP `185.220.101.22`.
- Asignación de `AdministratorAccess`.
- Acceso repetido al bucket `fleetpay-prod-drivers`.
- Operaciones de descifrado con `prod-data-key`.
- Aproximadamente 49 GB de tráfico saliente cifrado.
- Registro del contenedor `docker.io/attacker/exfil:latest`.
- Intento de eliminación o interrupción de CloudTrail bloqueado por SCP.
- Detección de posible exfiltración DNS por GuardDuty.

### 3.2 Hipótesis que requieren validación

- El mecanismo exacto mediante el cual se comprometieron las credenciales.
- Si la IP observada fue operada directamente por el atacante o utilizada como nodo de salida/proxy.
- El contenido exacto y sensibilidad de los objetos consultados o extraídos.
- La persistencia o ejecución efectiva de la tarea ECS maliciosa.
- El alcance completo de recursos, regiones, identidades y sesiones afectados.
- La obligación concreta de notificación regulatoria.

## 4. Línea de tiempo lógica

| Fase | Actividad descrita | Fuente esperada para validación |
|---|---|---|
| Acceso inicial | Inicio de sesión con credenciales de `svc-monitoring` | CloudTrail `ConsoleLogin`, registros de identidad |
| Persistencia / manipulación | Creación o modificación del perfil de acceso | CloudTrail IAM |
| Escalamiento | Asociación de `AdministratorAccess` | CloudTrail `AttachUserPolicy` |
| Colección | Accesos repetidos a `fleetpay-prod-drivers` | Eventos de datos S3 en CloudTrail |
| Acceso a datos cifrados | Operaciones KMS sobre `prod-data-key` | CloudTrail KMS |
| Exfiltración | Tráfico cifrado saliente y actividad DNS anómala | VPC Flow Logs, DNS logs, GuardDuty |
| Persistencia adicional | Registro de tarea ECS maliciosa | CloudTrail ECS y definiciones de tarea |
| Evasión | Intento contra CloudTrail bloqueado por SCP | CloudTrail y AWS Organizations |

Las marcas `T+00:00` a `T+02:00` del material original delimitan una ventana relativa; no se inventan fechas u horas absolutas.

## 5. Indicadores y observables

| Indicador u observable | Tipo | Tratamiento |
|---|---|---|
| `185.220.101.22` | IP | Indicador del escenario; reputación externa no verificada |
| `svc-monitoring` | Identidad IAM | Preservar configuración, políticas, claves y actividad histórica |
| `AdministratorAccess` | Política IAM | Validar quién, cuándo y desde dónde la asoció |
| `fleetpay-prod-drivers` | Bucket S3 | Revisar eventos de datos y objetos afectados |
| `prod-data-key` | Clave KMS | Revisar `Decrypt`, principal, contexto y origen |
| `i-0abc1234def56789` | Instancia EC2 | Aislar solo después de resolver región, VPC y SG de cuarentena |
| `docker.io/attacker/exfil:latest` | Imagen | Preservar definición, digest y evidencia; bloquear su uso |

El archivo `guardduty-threat-intel-set.txt` contiene únicamente la IP del escenario y puede usarse como entrada documental. Antes de cargarlo en un entorno real debe validarse su vigencia, pertenencia y riesgo de falsos positivos.

## 6. Mapeo MITRE ATT&CK

| Técnica | Descripción aplicada al escenario | Confianza |
|---|---|---|
| T1078 — Valid Accounts | Uso de credenciales válidas comprometidas | Alta |
| T1098 — Account Manipulation | Manipulación de la identidad y sus privilegios | Alta |
| T1548 — Abuse Elevation Control Mechanism | Asociación de privilegios administrativos | Media; validar sub-técnica aplicable |
| T1530 — Data from Cloud Storage Object | Acceso masivo a objetos S3 | Alta |
| T1610 — Deploy Container | Registro de una definición de tarea maliciosa | Alta |
| T1562.008 — Impair Defenses: Disable or Modify Cloud Logs | Intento de afectar CloudTrail | Alta |
| T1048 — Exfiltration Over Alternative Protocol | Posible exfiltración mediante DNS | Media; requiere validar telemetría |
| T1041 — Exfiltration Over C2 Channel | Tráfico saliente cifrado descrito | Media; requiere confirmar canal C2 |

## 7. Gestión del incidente

### 7.1 Preparación

- Confirmar responsables, canal de coordinación y autoridad para cambios de emergencia.
- Habilitar retención y acceso restringido a CloudTrail, GuardDuty, Config, DNS y VPC Flow Logs.
- Preparar roles break-glass, grupos de seguridad de cuarentena y repositorios de evidencia.
- Sincronizar tiempos y documentar cada acción con responsable y marca temporal UTC.

### 7.2 Detección y análisis

- Exportar eventos originales antes de modificar identidades o recursos.
- Determinar región, cuenta, principal, claves, sesiones y recursos afectados.
- Correlacionar inicio de sesión, cambios IAM, S3, KMS, ECS, EC2 y flujo de red.
- Calcular el alcance de datos potencialmente expuestos sin asumir que todo acceso equivale a exfiltración confirmada.

### 7.3 Contención

- Denegar nuevas acciones de la identidad comprometida mediante un control temporal explícito.
- Inactivar access keys y eliminar el acceso de consola tras preservar su configuración.
- Revocar privilegios añadidos de forma no autorizada.
- Aislar cargas comprometidas con controles previamente validados.
- Detener tareas maliciosas después de preservar definiciones, logs y metadatos.
- Bloquear indicadores solo cuando el impacto operacional y los falsos positivos hayan sido evaluados.

Los comandos de referencia y sus precondiciones están en `playbook-aws-cli.md`. No deben copiarse a producción sin sustituir variables y obtener aprobación.

### 7.4 Erradicación

- Rotar secretos y credenciales relacionados.
- Eliminar persistencia no autorizada y políticas excesivas.
- Revisar relaciones de confianza, roles asumibles y recursos creados o modificados.
- Corregir el origen del compromiso cuando la investigación lo confirme.

### 7.5 Recuperación

- Restaurar servicios desde configuraciones verificadas.
- Rehabilitar accesos con identidades nuevas o saneadas y mínimo privilegio.
- Validar telemetría, cifrado, integridad de logs y alertas antes de cerrar la contención.
- Mantener monitoreo reforzado durante un período definido por el responsable del incidente.

### 7.6 Actividades posteriores

- Documentar cronología final, alcance, decisiones, evidencias y responsables.
- Evaluar obligaciones legales y regulatorias con Jurídica y Privacidad.
- Ajustar controles, detecciones y procedimientos a partir de las lecciones aprendidas.
- Realizar un ejercicio de mesa para verificar las mejoras.

## 8. Preservación de evidencia

Cada evidencia debe registrar:

- Fuente, cuenta, región y recurso.
- Hora de adquisición en UTC.
- Persona o rol responsable.
- Comando o método de adquisición.
- Ubicación de almacenamiento.
- Hash criptográfico cuando corresponda.
- Transferencias de custodia y controles de acceso.

Las copias deben almacenarse fuera del alcance de las identidades comprometidas, con cifrado, versionado y retención apropiada. No deben descargarse registros sensibles a un equipo no autorizado.

## 9. Remediación priorizada

| Prioridad | Acción | Responsable sugerido | Objetivo |
|---|---|---|---|
| P1 | Contener identidad, sesiones y cargas afectadas | IR / Cloud Security | Inmediato |
| P1 | Preservar evidencias y validar integridad de auditoría | IR / Forense | Inmediato |
| P1 | Determinar alcance de datos y exposición | IR / Datos / Privacidad | 24 horas |
| P2 | Rediseñar privilegios y aplicar MFA o identidades de carga | IAM / Cloud | 7 días |
| P2 | Alertar cambios IAM, picos S3, KMS y ECS anómalos | SOC | 7 días |
| P2 | Implementar respuesta automatizada con aprobaciones | SOC / Cloud | 14 días |
| P3 | Revisar gobierno, procedimientos y simulaciones | CISO / Riesgos | 30 días |

Los plazos son objetivos operativos del plan, no evidencia de que las acciones hayan sido completadas.

## 10. Criterios de cierre

El incidente solo debería cerrarse cuando:

- No existan sesiones o credenciales comprometidas activas.
- Se haya determinado y documentado el alcance razonable.
- La persistencia no autorizada haya sido removida.
- Los servicios se hayan recuperado de forma controlada.
- Las detecciones y registros funcionen correctamente.
- Jurídica y Privacidad hayan evaluado las obligaciones aplicables.
- Las acciones pendientes tengan responsable, fecha y seguimiento.

## 11. Anexos

- `ceo-executive-summary.md`: comunicación ejecutiva.
- `root-cause-analysis.md`: análisis causal e hipótesis.
- `ioc-enrichment.md`: inventario de indicadores.
- `threat-intelligence.md`: plan de enriquecimiento.
- `guardduty-threat-intel-set.txt`: lista de IP del escenario.
- `mitre-attack.md`: mapeo ATT&CK original.
- `sigma-rules.yml`: detecciones revisadas.
- `playbook-aws-cli.md`: contención controlada.
- `remediation-plan.md`: acciones de mejora.

