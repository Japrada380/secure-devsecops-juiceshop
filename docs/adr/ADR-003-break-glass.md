# ADR-003: Break Glass con aprobaciones secuenciales y registro auditable

- Estado: Aceptado
- Fecha: 2026-08-12

## Contexto

Los accesos de emergencia deben ser excepcionales, trazables y resistentes a la autoaprobación. Una sola persona no debería solicitar, aprobar y ejecutar una acción crítica sin control adicional.

## Decisión

Implementar un workflow manual que exige razón y referencia, crea un issue de auditoría y pasa por entornos protegidos de Seguridad y Operaciones antes de autorizar la etapa final.

## Consecuencias

- Se conserva identidad, motivo y secuencia de aprobación.
- La demostración utiliza dos cuentas para representar roles separados.
- En producción deben existir revisores organizacionalmente independientes, cuentas individuales y `Prevent self-review`.
- El tiempo de espera humano no forma parte del tiempo computacional del pipeline principal.

