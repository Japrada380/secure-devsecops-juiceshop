# Respuesta a incidentes

Este directorio contiene el entregable consolidado del escenario de compromiso AWS. Es un ejercicio documental: no se ejecutaron comandos ni consultas contra una cuenta AWS real.

## Documento principal

- `INCIDENT_RESPONSE_REPORT.md`: informe maestro con alcance, hechos, hipótesis, cronología lógica, indicadores, MITRE ATT&CK, ciclo de respuesta, preservación, remediación y criterios de cierre.

## Artefactos operativos

- `playbook-aws-cli.md`: comandos de referencia con precondiciones, verificación y reversión. No es un script ejecutable.
- `sigma-rules.yml`: detecciones portables revisadas para IAM, CloudTrail, login sin MFA y ECS.
- `guardduty-threat-intel-set.txt`: IP incluida en el escenario; debe validarse antes de cargarla en un ambiente real.

## Documentos de soporte

- `ceo-executive-summary.md`: comunicación ejecutiva.
- `root-cause-analysis.md`: análisis de causa raíz original.
- `ioc-enrichment.md`: inventario inicial de indicadores.
- `threat-intelligence.md`: necesidades de enriquecimiento externo.
- `mitre-attack.md`: mapeo ATT&CK original.
- `remediation-plan.md`: plan de mejora original.

## Limitaciones

- Los datos provienen del escenario de la prueba técnica.
- No se verificó reputación externa de la IP.
- No se accedió a CloudTrail, GuardDuty, S3, KMS, ECS, EC2 ni VPC Flow Logs reales.
- Los comandos requieren autorización, variables reales y revisión humana antes de cualquier uso.
- La evaluación de notificación regulatoria corresponde a las áreas Jurídica y de Privacidad.

