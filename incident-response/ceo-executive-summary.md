# Resumen Ejecutivo para la Gerencia

## ¿Qué ocurrió?

Se identificó un acceso no autorizado al entorno AWS de FleetSec mediante el uso de credenciales comprometidas pertenecientes a una cuenta de servicio. Posteriormente, el atacante escaló privilegios, accedió a información almacenada en Amazon S3, registró un contenedor malicioso e intentó eliminar los registros de auditoría de CloudTrail. Este último intento fue bloqueado por una Service Control Policy (SCP).

---

## Impacto para el negocio

El incidente comprometió la confidencialidad de la información almacenada en el entorno productivo y evidencia debilidades en la gestión de identidades y privilegios.

Principales impactos:

- Acceso no autorizado a recursos críticos de AWS.
- Escalamiento de privilegios sobre una cuenta de servicio.
- Extracción masiva de información desde Amazon S3.
- Riesgo de exposición de datos personales.
- Intento de eliminación de evidencias (anti-forensics).

---

## Impacto regulatorio

Debido a la posible exposición de datos personales, la organización debe evaluar las obligaciones de reporte establecidas por la Ley 1581 de 2012 y los lineamientos de la Superintendencia de Industria y Comercio (SIC).

---

## Acciones inmediatas recomendadas

1. Revocar las credenciales comprometidas.
2. Rotar credenciales, llaves y secretos de AWS.
3. Preservar toda la evidencia forense.
4. Completar la investigación del incidente.
5. Informar a las áreas de Tecnología, Jurídica, Cumplimiento y Alta Dirección.

---

## Evaluación Ejecutiva del Riesgo

**Nivel de Riesgo: CRÍTICO**

Se recomienda mantener las acciones de contención hasta completar la investigación forense y validar que el entorno sea seguro antes de restablecer completamente la operación.