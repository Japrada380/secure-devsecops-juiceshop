# Reporte de uso de inteligencia artificial

## Herramientas y tareas específicas

Se utilizó ChatGPT/Codex como apoyo durante la prueba para:

- Revisar la estructura y los gates de los workflows de GitHub Actions.
- Interpretar fallos de Semgrep, Gitleaks, Checkov, Trivy y OWASP ZAP.
- Proponer y revisar configuraciones Terraform antes de validarlas con herramientas determinísticas.
- Organizar evidencias y consolidar el informe VAPT sin crear resultados inexistentes.
- Revisar comandos de contención AWS y distinguir acciones reversibles de operaciones destructivas.
- Estructurar el informe de respuesta a incidentes, el mapeo MITRE ATT&CK y las reglas Sigma.
- Preparar documentación, checklist y guion de sustentación.

Las propuestas de IA no se aceptaron automáticamente. Se contrastaron con ejecuciones reales, evidencia del repositorio, documentación de herramientas y revisión humana.

## Error de seguridad detectado y corregido

Una recomendación inicial de IA propuso usar:

```text
aws iam update-login-profile --password-reset-required
```

como si esa operación deshabilitara al usuario comprometido y revocara sus sesiones. La revisión técnica detectó que solo obliga a cambiar la contraseña en un login posterior: no inactiva access keys ni invalida todas las credenciales temporales.

El playbook se corrigió para preservar primero la configuración, aplicar una política temporal de denegación, inactivar cada access key, eliminar el login profile después de documentarlo y advertir que las sesiones derivadas requieren controles adicionales. También se añadieron precondiciones, aprobaciones y pasos de reversión.

## Tareas que no delegaría sin supervisión

No delegaría a una IA la ejecución de contención en producción, rotación o eliminación de credenciales, cambios IAM/KMS/SCP, aislamiento de cargas, borrado de datos, aceptación de riesgo, cálculo definitivo de impacto regulatorio ni atribución de un atacante. Estas acciones pueden interrumpir servicios, destruir evidencia, ampliar privilegios o generar obligaciones legales. Tampoco aceptaría automáticamente una PoC, una clasificación CVSS o un hallazgo de una herramienta: deben validarse contra el contexto, la evidencia y el comportamiento real. La IA puede acelerar análisis y documentación, pero la autorización, la cadena de custodia, las decisiones de negocio y la responsabilidad sobre cambios de seguridad deben permanecer bajo control humano competente.

