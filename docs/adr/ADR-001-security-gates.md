# ADR-001: Gates de seguridad con tratamiento explícito de excepciones

- Estado: Aceptado
- Fecha: 2026-08-12

## Contexto

OWASP Juice Shop es deliberadamente vulnerable. Un pipeline que bloquee cualquier hallazgo sin contexto sería inutilizable; uno que ignore errores entregaría una falsa sensación de seguridad.

## Decisión

Ejecutar controles complementarios y aplicar gates según riesgo: Semgrep, Gitleaks y Checkov deben finalizar correctamente; Trivy bloquea según la política configurada; ZAP genera seguimiento para MEDIUM y bloquea HIGH/CRITICAL. Las excepciones deben ser específicas, justificadas y temporales.

## Consecuencias

- Los hallazgos relevantes interrumpen el flujo.
- Las excepciones quedan auditables.
- La imagen de entrenamiento puede utilizarse sin desactivar los controles completos.
- Los umbrales deben revisarse antes de usar el pipeline en producción.

