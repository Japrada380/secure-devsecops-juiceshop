# ADR-002: Validar Terraform sin desplegar en una cuenta AWS real

- Estado: Aceptado para el entorno de evaluación
- Fecha: 2026-08-12

## Contexto

La prueba no requiere una cuenta AWS real. Usar credenciales personales o crear recursos solo para demostrar el módulo introduce costos, riesgos de permisos y posibles exposiciones.

## Decisión

Realizar formato, validación y análisis estático de Terraform localmente y en CI. No ejecutar `apply`. Documentar que `plan` y el despliegue quedan pendientes de una cuenta sandbox autorizada y una revisión formal.

## Consecuencias

- No se crean recursos ni costos.
- La sintaxis y consistencia interna quedan verificadas.
- No se validan permisos, cuotas, disponibilidad regional ni comportamiento en ejecución.
- Producción requiere backend remoto, plan revisado y aprobación.

