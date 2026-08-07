# Plan de Remediación

## Objetivo

Definir las acciones necesarias para erradicar la causa del incidente, fortalecer la postura de seguridad y reducir el riesgo de recurrencia.

---

# Prioridad P1 (Crítica)

## Gestión de Identidades

- Revocar todas las credenciales comprometidas.
- Rotar claves de acceso y secretos.
- Habilitar MFA para todas las cuentas privilegiadas.
- Eliminar permisos excesivos (AdministratorAccess).

**Responsable:** Equipo Cloud / Seguridad

**Tiempo estimado:** 24 horas

---

## Contención

- Aislar las instancias comprometidas.
- Detener tareas ECS maliciosas.
- Preservar evidencia forense.
- Verificar integridad de CloudTrail.

**Responsable:** Respuesta a Incidentes

**Tiempo estimado:** 24 horas

---

# Prioridad P2 (Alta)

## Monitoreo

- Fortalecer GuardDuty.
- Configurar alertas en Security Hub.
- Implementar reglas Sigma en el SIEM.
- Crear alertas para accesos anómalos a S3.

**Responsable:** SOC

**Tiempo estimado:** 7 días

---

## Hardening AWS

- Aplicar principio de mínimo privilegio.
- Revisar políticas IAM.
- Cifrar recursos con AWS KMS.
- Revisar configuraciones de S3.
- Activar AWS Config en todas las regiones.

**Responsable:** Cloud Security

**Tiempo estimado:** 2 semanas

---

# Prioridad P3 (Media)

## Gobierno y Cumplimiento

- Actualizar procedimientos de respuesta a incidentes.
- Capacitar administradores AWS.
- Revisar controles ISO 27001.
- Actualizar inventario de activos.
- Realizar ejercicios de simulación (Tabletop Exercise).

**Responsable:** CISO / Gestión de Riesgos

**Tiempo estimado:** 30 días

---

# Resultado Esperado

- Eliminación del acceso no autorizado.
- Fortalecimiento de los controles preventivos.
- Mejora en la capacidad de detección.
- Reducción del riesgo de nuevos incidentes.
- Cumplimiento de los requisitos regulatorios aplicables.