# Guía completa de explicación y sustentación

## Secure DevSecOps — OWASP Juice Shop

**Repositorio:** [Japrada380/secure-devsecops-juiceshop](https://github.com/Japrada380/secure-devsecops-juiceshop)  
**Commit de referencia:** [`7c56705`](https://github.com/Japrada380/secure-devsecops-juiceshop/commit/7c56705)  
**Autor:** Jhon Alex Prada Gomez

## 1. Explicación del proyecto en una frase

Este proyecto demuestra cómo integrar controles preventivos, detectivos y de respuesta en un ciclo DevSecOps aplicado a OWASP Juice Shop: analiza código, secretos, infraestructura y contenedores; genera inventario de componentes; ejecuta pruebas dinámicas autenticadas; documenta vulnerabilidades; diseña controles AWS con Terraform y consolida un escenario de respuesta a incidentes.

## 2. Problema que resuelve

Un pipeline tradicional suele comprobar solamente que la aplicación compile o funcione. Este proyecto añade controles para responder preguntas de seguridad antes de entregar software:

- ¿El código contiene patrones inseguros?
- ¿Se filtró una contraseña, token o clave?
- ¿La infraestructura como código tiene configuraciones débiles?
- ¿Las dependencias o la imagen contienen vulnerabilidades conocidas?
- ¿Qué componentes exactos forman el software?
- ¿La aplicación presenta vulnerabilidades cuando está funcionando?
- ¿Cómo se controla un acceso de emergencia?
- ¿Cómo se documentan, priorizan y responden incidentes y hallazgos?

## 3. Arquitectura y flujo completo

```text
Desarrollador
    |
    | git push a main
    v
GitHub Actions
    |
    +-- Semgrep -------- patrones inseguros en código
    +-- Gitleaks ------- secretos y credenciales expuestas
    +-- Checkov -------- configuración insegura de Terraform
    +-- Trivy FS ------- vulnerabilidades y secretos en el repositorio
    +-- CycloneDX ------ inventario SBOM
    +-- Docker Build --- imagen reproducible de Juice Shop
    +-- Trivy Image ---- vulnerabilidades de la imagen final
    +-- OWASP ZAP ------ DAST autenticado con JWT
            |
            +-- crea usuario efímero
            +-- obtiene JWT válido
            +-- importa OpenAPI
            +-- spider + active scan
            +-- publica HTML/JSON
            +-- crea issue para MEDIUM
            +-- bloquea HIGH/CRITICAL

Workflow Break Glass separado
    +-- solicitud manual
    +-- issue auditable
    +-- aprobación Seguridad
    +-- aprobación Operaciones
    +-- autorización final

Entregables complementarios
    +-- VAPT con evidencia
    +-- baseline AWS con Terraform
    +-- respuesta a incidentes
```

## 4. Cómo funciona cada control

### 4.1 Semgrep — SAST

**Qué hace:** analiza el código sin ejecutarlo y compara su estructura con reglas de seguridad.

**Qué puede detectar:**

- Uso de funciones peligrosas como `eval`.
- Contraseñas o valores sensibles embebidos, según reglas locales.
- Patrones de inyección o validación insuficiente cubiertos por los rulesets configurados.
- Errores de programación detectables por análisis estático.

**Ventajas:**

- Detecta problemas temprano.
- Es rápido y automatizable.
- Permite reglas propias adaptadas al proyecto.
- Entrega ubicación precisa del patrón encontrado.

**Limitación:** no confirma por sí solo que una vulnerabilidad sea explotable en ejecución y puede producir falsos positivos o negativos.

**Dónde mostrarlo:**

- [Workflow principal — commit de referencia](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/.github/workflows/pipeline.yml)
- [Reglas Semgrep del repositorio](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/.github/semgrep-rules)

### 4.2 Gitleaks — detección de secretos

**Qué hace:** busca patrones compatibles con tokens, claves API, contraseñas y otros secretos.

**Qué detecta:** credenciales incluidas accidentalmente en archivos o historial Git cubierto por el análisis.

**Ventajas:**

- Previene filtraciones antes de publicar cambios.
- Se ejecuta en el pipeline y en el hook local de pre-commit.
- Permite convertir la ausencia de secretos en evidencia verificable.

**Resultado VAPT:** `no leaks found` en el análisis local conservado.

**Limitación:** un resultado limpio cubre el alcance y reglas del análisis; no garantiza que no exista información sensible fuera de él.

**Dónde mostrarlo:**

- [Evidencia Gitleaks](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/vapt/evidence/gitleaks)
- [Configuración del hook](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/.githooks)

### 4.3 Checkov — seguridad de IaC

**Qué hace:** revisa archivos Terraform contra políticas y buenas prácticas de seguridad.

**Qué puede detectar:**

- Almacenamiento sin cifrado.
- Recursos públicos.
- Logging deshabilitado.
- Políticas demasiado permisivas.
- Configuraciones que incumplen controles conocidos.

**Ventajas:** detecta fallos antes de crear infraestructura, ofrece IDs de controles y facilita gates automatizados.

**Resultado documentado:** 212 controles aprobados, 0 fallidos y 9 omitidos con justificación para el alcance.

**Limitación:** la revisión estática no comprueba permisos, cuotas, costos ni comportamiento real en una cuenta AWS.

**Dónde mostrarlo:**

- [Módulo Terraform](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/terraform)
- [Documentación Terraform](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/terraform/README.md)

### 4.4 Trivy — filesystem e imagen

**Qué hace:** revisa el repositorio y la imagen final para identificar vulnerabilidades conocidas, secretos y problemas de configuración según el modo utilizado.

**Dos momentos de control:**

1. Antes de construir: análisis del filesystem.
2. Después de construir: análisis de la imagen que realmente se ejecutaría.

**Ventajas:** cubre dependencias transitivas y paquetes del sistema operativo, prioriza por severidad e integra gates.

**Decisión del proyecto:** Juice Shop es deliberadamente vulnerable. Las excepciones necesarias se mantienen limitadas, justificadas y con fecha de expiración.

**Dónde mostrarlo:**

- [Excepciones Trivy documentadas](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/.trivyignore.yaml)
- [Dockerfile](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/Dockerfile)

### 4.5 SBOM CycloneDX

**Qué hace:** genera un inventario legible por máquinas de los componentes del software.

**Ventajas:**

- Mejora trazabilidad de dependencias.
- Ayuda a responder rápidamente ante una CVE nueva.
- Facilita auditoría y gestión de cadena de suministro.
- Puede alimentar otras plataformas de gestión de vulnerabilidades.

**Artefacto del pipeline:** `cyclonedx-sbom`.

**Limitación:** un SBOM inventaría componentes, pero no garantiza que todos sean seguros ni reemplaza el análisis de vulnerabilidades.

### 4.6 Docker

**Qué hace:** empaqueta la versión fijada de OWASP Juice Shop en una imagen reproducible.

**Ventajas:** consistencia entre local y CI, aislamiento y facilidad para levantar un entorno temporal de DAST.

**Decisión relevante:** la imagen base está fijada en una versión concreta para evitar cambios inesperados.

### 4.7 OWASP ZAP — DAST autenticado

**Qué hace:** prueba la aplicación mientras está funcionando, enviando solicitudes y observando respuestas.

**Flujo implementado:**

1. Crea una red Docker aislada.
2. Inicia Juice Shop.
3. Crea un usuario efímero con contraseña aleatoria.
4. Obtiene un JWT real.
5. Extrae la definición OpenAPI.
6. Inyecta `Authorization: Bearer <token>`.
7. Ejecuta importación OpenAPI, spider, passive scan y active scan.
8. Publica reportes HTML y JSON.
9. Crea un issue para hallazgos `MEDIUM`.
10. Bloquea ante `HIGH`, `CRITICAL` o error del scan.

**Ventajas:** alcanza rutas autenticadas, evalúa comportamiento real y entrega evidencia reproducible.

**Limitaciones:** no garantiza cobertura total de lógica de negocio; algunos flujos necesitan pruebas manuales.

**Dónde mostrarlo:**

- [Configuración de automatización ZAP](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/.github/zap/automation.yaml)
- [Issues DAST](https://github.com/Japrada380/secure-devsecops-juiceshop/issues?q=is%3Aissue+DAST)

## 5. Gates y tratamiento de resultados

Un gate de seguridad convierte un análisis en una decisión automática:

- Si el control pasa, el pipeline continúa.
- Si la herramienta falla de forma inesperada, el pipeline no presenta un falso éxito.
- Si el riesgo supera el umbral, el pipeline se bloquea.
- Los resultados se conservan como artefactos o issues para trazabilidad.

En este proyecto:

- Semgrep, Gitleaks, Checkov y Trivy aplican criterios definidos en el workflow.
- ZAP crea seguimiento para `MEDIUM`.
- ZAP bloquea `HIGH` y `CRITICAL`.
- Las excepciones de la aplicación vulnerable son explícitas, no silenciosas.

## 6. Break Glass

### Qué es

Es un procedimiento excepcional para autorizar acciones de emergencia sin convertir la excepción en el camino normal de operación.

### Cómo funciona

1. Se ejecuta manualmente.
2. Exige justificación y referencia de incidente/cambio.
3. Crea un issue como registro auditable.
4. Espera aprobación del entorno de Seguridad.
5. Espera aprobación del entorno de Operaciones.
6. Autoriza la etapa final solo después de ambas.

### Por qué utiliza dos usuarios

Simula separación de funciones: quien aprueba Seguridad no debe representar el mismo rol que Operaciones. En producción serían personas o equipos distintos. Para la prueba pueden ser dos cuentas controladas, siempre que se explique como simulación y que no se compartan credenciales.

### Ventajas

- Doble control humano.
- Trazabilidad del motivo y aprobadores.
- Evita autoaprobación cuando `Prevent self-review` está activo.
- Reduce el riesgo de abuso unilateral.

**Dónde mostrarlo:**

- [Workflow Break Glass](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/.github/workflows/break-glass.yml)
- [Ejecuciones Break Glass](https://github.com/Japrada380/secure-devsecops-juiceshop/actions/workflows/break-glass.yml)
- [Issues de auditoría](https://github.com/Japrada380/secure-devsecops-juiceshop/issues?q=is%3Aissue+BREAK-GLASS)

**No hacer en el video:** no iniciar otra ejecución; mostrar la ejecución #16 ya completada y sus aprobaciones.

## 7. VAPT

### Propósito

Validar manualmente vulnerabilidades y conservar evidencia de solicitudes, respuestas, logs y capturas. El informe diferencia hallazgos confirmados, pruebas no reproducibles y controles sin detecciones.

### Hallazgos confirmados

| Hallazgo | Evidencia principal | Impacto |
|---|---|---|
| SQL Injection | Login respondió `200` y permitió acceso administrativo | Bypass de autenticación y acceso privilegiado |
| Missing Rate Limiting | 30 intentos, todos `401`, sin `429` o bloqueo | Facilita fuerza bruta y credential stuffing |
| IDOR | Acceso a carrito con `UserId` ajeno | Exposición de recursos de otro usuario |
| XSS reflejado | Ejecución de `alert` en búsqueda | Código en el navegador de la víctima |

### Pruebas no reproducibles

- JWT: la alteración produjo `401 invalid signature`.
- Mass Assignment: la API rechazó autenticación antes de procesar el cuerpo.
- Logging PII: el log capturado no demostró exposición de PII.
- Stored XSS: el payload no se ejecutó.

### Resultado de Gitleaks

No se identificaron secretos en el análisis local conservado.

### Ventaja metodológica

No se presenta como vulnerabilidad algo que la evidencia no demuestra. Una prueba no reproducible tampoco se convierte en garantía de ausencia.

**Dónde mostrarlo:**

- [Informe VAPT](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/vapt/VAPT_Report.md)
- [Evidencias VAPT](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/vapt/evidence)

## 8. Terraform

### Propósito

Diseñar una línea base AWS segura como código, revisable y reproducible.

### Controles principales

- VPC con DNS y subredes separadas por nivel.
- No asignación automática de IP pública.
- Grupo de seguridad predeterminado restrictivo.
- VPC Flow Logs cifrados.
- Política de contraseñas IAM.
- Roles separados para ejecución y aplicación ECS.
- Acceso mínimo al secreto de base de datos.
- KMS con rotación para logs y secretos.
- S3 privado, cifrado, versionado y transporte seguro.
- CloudTrail multirregión con validación de logs.
- AWS Config.
- GuardDuty.
- Security Hub con CIS y FSBP.
- WAFv2 con reglas administradas y logging.
- Redacción del header `Authorization` en logs de WAF.
- Secret version inicial deshabilitada para evitar secretos en el estado.

### Por qué no se usó AWS real

El alcance no requiere una cuenta. `terraform validate` comprueba sintaxis y coherencia; `plan` y `apply` necesitan credenciales autorizadas, consultan servicios y pueden generar costos.

### Validación realizada

- Terraform CLI `1.15.8`.
- AWS Provider `6.58.0`.
- `terraform fmt -check -recursive` aprobado.
- `terraform validate -no-color` aprobado.

**Dónde mostrarlo:**

- [Documentación Terraform](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/terraform/README.md)
- [Código del módulo](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/terraform/modules/security-baseline)
- [Evidencia de validación](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/terraform/evidence/terraform-local-validation.txt)

**No hacer en el video:** no ejecutar `terraform apply` ni ingresar credenciales AWS.

## 9. Respuesta a Incidentes

### Escenario

El escenario describe credenciales comprometidas de `svc-monitoring`, elevación a `AdministratorAccess`, accesos S3, uso de KMS, tráfico saliente, una imagen ECS maliciosa e intento de afectar CloudTrail.

### Qué se entregó

- Informe maestro.
- Separación entre hechos e hipótesis.
- Línea de tiempo lógica.
- IoC y observables.
- MITRE ATT&CK.
- Ciclo completo de respuesta.
- Preservación y cadena de custodia.
- Playbook AWS CLI controlado.
- Reglas Sigma.
- Remediación priorizada.

### Valor del playbook corregido

No actúa como script ciego. Exige:

- Confirmar cuenta y región.
- Preservar configuración antes de cambiarla.
- Aplicar denegación temporal.
- Inactivar claves sin borrarlas inicialmente.
- Retirar login y privilegios de forma controlada.
- Resolver IDs reales antes de aislar EC2.
- Revisar si ECS recreará una tarea detenida.
- Registrar reversión, aprobador y hora UTC.

### Reglas Sigma

- Asociación de `AdministratorAccess` a un usuario IAM.
- Detención o eliminación de CloudTrail.
- Login exitoso sin MFA.
- Registro de una tarea ECS con imagen no aprobada del escenario.

La detección de acceso masivo a S3 no se representa falsamente con un solo `GetObject`; requiere agregación por identidad, bucket y ventana temporal en el SIEM.

**Dónde mostrarlo:**

- [Informe consolidado](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/INCIDENT_RESPONSE_REPORT.md)
- [Playbook AWS CLI](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/playbook-aws-cli.md)
- [Reglas Sigma](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/sigma-rules.yml)

**No hacer en el video:** no ejecutar comandos de contención contra AWS.

## 10. Mapa de carpetas

| Ruta | Función |
|---|---|
| `.github/workflows/` | Pipeline principal y Break Glass |
| `.github/semgrep-rules/` | Reglas SAST personalizadas |
| `.github/zap/` | Automatización DAST |
| `.githooks/` | Controles locales antes del commit |
| `terraform/` | Línea base AWS y validación local |
| `vapt/` | Plan, informe, PoC y evidencias VAPT |
| `incident-response/` | Informe, playbook, Sigma, MITRE e IoC |
| `docs/` | Checklist y guiones de sustentación |
| `sbom/`, `semgrep/`, `trivy/`, `zap/` | Artefactos o estructura asociada a herramientas |
| `Dockerfile` | Imagen local reproducible |
| `.trivyignore.yaml` | Excepciones temporales justificadas |
| `README.md` | Entrada principal y visión del proyecto |

## 11. Enlaces para preparar como pestañas

Abrir en este orden antes de grabar:

1. [README principal](https://github.com/Japrada380/secure-devsecops-juiceshop) — presenta alcance, estado y arquitectura.
2. [Actions](https://github.com/Japrada380/secure-devsecops-juiceshop/actions) — demuestra automatización y último pipeline verde.
3. [Workflow principal](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/.github/workflows/pipeline.yml) — explica herramientas, artefactos y gates.
4. [Ejecuciones Break Glass](https://github.com/Japrada380/secure-devsecops-juiceshop/actions/workflows/break-glass.yml) — muestra doble aprobación.
5. [Issues](https://github.com/Japrada380/secure-devsecops-juiceshop/issues) — evidencia seguimiento DAST y auditoría Break Glass.
6. [Informe VAPT](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/vapt/VAPT_Report.md) — muestra tabla consolidada y hallazgos.
7. [Evidencias VAPT](https://github.com/Japrada380/secure-devsecops-juiceshop/tree/7c56705/vapt/evidence) — demuestra trazabilidad.
8. [Terraform README](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/terraform/README.md) — explica arquitectura AWS.
9. [Validación Terraform](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/terraform/evidence/terraform-local-validation.txt) — evidencia validación sin AWS.
10. [Informe de incidentes](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/INCIDENT_RESPONSE_REPORT.md) — presenta respuesta completa.
11. [Playbook](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/playbook-aws-cli.md) — muestra contención segura.
12. [Sigma](https://github.com/Japrada380/secure-devsecops-juiceshop/blob/7c56705/incident-response/sigma-rules.yml) — muestra detecciones.

## 12. Guion corto — 8 a 10 minutos

### 0:00–0:45 — Introducción

> Soy Jhon Alex Prada Gomez. Este proyecto integra seguridad en todo el ciclo DevSecOps de OWASP Juice Shop. Incluye pipeline automatizado, VAPT con evidencias, infraestructura segura con Terraform y respuesta a incidentes AWS.

Mostrar README y arquitectura.

### 0:45–3:15 — Pipeline

> Cada push a main activa Semgrep, Gitleaks, Checkov, Trivy, SBOM, construcción Docker y ZAP autenticado. Los resultados no son solo informativos: existen gates y artefactos. ZAP crea seguimiento para hallazgos medios y bloquea riesgos altos o críticos.

Mostrar último pipeline verde, jobs y artefactos.

### 3:15–4:15 — Break Glass

> El acceso de emergencia es manual, registra un issue y exige dos aprobaciones secuenciales: Seguridad y Operaciones. Las dos cuentas de la demostración representan roles separados; en producción serían personas o equipos distintos.

Mostrar ejecución completada, sin volverla a ejecutar.

### 4:15–6:15 — VAPT

> El VAPT confirmó SQL Injection, ausencia de rate limiting, IDOR y XSS reflejado. Las pruebas JWT, Mass Assignment, Logging PII y Stored XSS se conservaron como no reproducibles. Gitleaks no encontró secretos. Así mantengo trazabilidad sin inventar resultados.

Mostrar tabla y máximo tres evidencias visuales.

### 6:15–7:25 — Terraform

> La línea base incluye red segmentada, IAM, KMS, Secrets Manager, S3 seguro, CloudTrail, Config, GuardDuty, Security Hub y WAF. No usé una cuenta AWS porque no era requerida. Validé formato y consistencia localmente, evitando credenciales y costos.

Mostrar arquitectura y `Success!`.

### 7:25–8:35 — Incidentes

> Consolidé hechos e hipótesis, cronología, IoC, MITRE, preservación, remediación, Sigma y un playbook que exige validación y aprobación antes de cualquier contención.

Mostrar informe y playbook.

### 8:35–9:00 — Cierre

> El resultado cubre prevención, detección, validación, respuesta y trazabilidad. Como siguiente paso real aplicaría remediaciones, realizaría retests y validaría Terraform en una cuenta sandbox autorizada.

## 13. Guion detallado — 15 a 20 minutos

### Parte 1 — Contexto y arquitectura (2 minutos)

- Explicar problema y alcance.
- Señalar que Juice Shop es deliberadamente vulnerable.
- Recorrer el diagrama sin abrir archivos todavía.

### Parte 2 — Pipeline (5 minutos)

- Mostrar ejecución verde.
- Explicar cada herramienta en una frase.
- Abrir el workflow y señalar los nombres de pasos.
- Mostrar artefactos SBOM/ZAP.
- Explicar gates y excepciones.

### Parte 3 — Break Glass (2 minutos)

- Mostrar disparo manual.
- Mostrar issue y dos aprobaciones.
- Explicar simulación de roles con dos usuarios.
- Señalar controles necesarios en producción.

### Parte 4 — VAPT (4 minutos)

- Mostrar resumen y metodología.
- Explicar dos hallazgos con detalle y mencionar los otros dos.
- Mostrar una prueba no reproducible.
- Mostrar Gitleaks limpio.
- Explicar diferencia entre confirmado y no reproducible.

### Parte 5 — Terraform (2 minutos)

- Mostrar árbol del módulo.
- Explicar capas de seguridad.
- Mostrar evidencia de validación.
- Explicar por qué no se usó AWS.

### Parte 6 — Incidentes (3 minutos)

- Resumir ataque.
- Mostrar hechos/hipótesis y línea de tiempo.
- Mostrar playbook y Sigma.
- Explicar preservación y reversión.

### Parte 7 — Cierre (1 minuto)

- Ventajas.
- Limitaciones.
- Próximos pasos.

## 14. Ventajas globales del proyecto

- Seguridad integrada desde el commit hasta las pruebas en ejecución.
- Defensa en profundidad con herramientas complementarias.
- Evidencia reproducible y auditable.
- Gates automáticos, no solo reportes pasivos.
- Autenticación real para DAST.
- Separación de funciones para emergencias.
- Infraestructura segura revisada antes del despliegue.
- Tratamiento honesto de limitaciones y pruebas negativas.
- Cobertura de prevención, detección, respuesta y recuperación.

## 15. Limitaciones que debes declarar

- Juice Shop es deliberadamente vulnerable y requiere excepciones controladas.
- No se desplegó Terraform en AWS real.
- El VAPT no cubre todas las rutas posibles ni confirma pruebas pendientes sin evidencia.
- ZAP no reemplaza pruebas manuales de lógica de negocio.
- Las reglas Sigma necesitan adaptación al esquema real del SIEM.
- El escenario de incidentes es documental; no se ejecutó contención real.
- Las dos cuentas Break Glass simulan dos roles; en producción deben pertenecer a responsables independientes.

Declarar limitaciones aumenta credibilidad; no disminuye el valor del proyecto.

## 16. Preguntas probables y respuestas

### ¿Por qué usar varias herramientas?

Porque cubren superficies distintas. Semgrep revisa código, Gitleaks secretos, Checkov infraestructura, Trivy dependencias e imagen, y ZAP comportamiento en ejecución. Ninguna sustituye completamente a las otras.

### ¿Qué diferencia hay entre SAST y DAST?

SAST analiza código sin ejecutar la aplicación; DAST prueba la aplicación funcionando desde una perspectiva externa. SAST encuentra patrones temprano y DAST confirma comportamientos observables.

### ¿Qué pasa cuando el pipeline encuentra algo?

Depende del control y umbral: puede detener el pipeline, conservar artefactos o crear un issue. ZAP crea seguimiento para MEDIUM y bloquea HIGH/CRITICAL.

### ¿Por qué mantener excepciones de Trivy?

Porque Juice Shop es una imagen de entrenamiento deliberadamente vulnerable. Las excepciones están limitadas, justificadas y tienen vencimiento; no se desactiva el escaneo completo.

### ¿Por qué no se ejecutó Terraform?

No se requería cuenta AWS. `apply` modifica recursos y puede generar costos. Se validaron sintaxis y coherencia localmente; un despliegue real requeriría cuenta sandbox, backend seguro, plan y aprobación.

### ¿Dos usuarios Break Glass representan separación real?

En la demostración representan dos roles distintos. Es válido como simulación técnica, pero producción requiere revisores realmente independientes, cuentas individuales y prohibición de compartir credenciales.

### ¿Una prueba no reproducible significa que no existe la vulnerabilidad?

No. Significa que no se obtuvo evidencia suficiente bajo esas condiciones. Por eso se documenta la prueba y su limitación.

### ¿Cuál es el hallazgo VAPT más crítico?

La SQL Injection del login, porque permitió bypass de autenticación y acceso administrativo.

### ¿Cómo se protege el JWT en ZAP?

Se genera para un usuario efímero durante la ejecución, se inyecta en solicitudes y no debe imprimirse ni persistirse como evidencia pública.

### ¿Qué aporta el SBOM?

Permite saber qué componentes existen y localizar rápidamente si una dependencia está afectada por una vulnerabilidad nueva.

### ¿Qué cambiaría para producción?

Separaría cuentas y ambientes, usaría OIDC y permisos mínimos, backend Terraform remoto cifrado y bloqueado, firma de imágenes, despliegues progresivos, SIEM integrado, retests y métricas de seguridad.

## 17. Qué mostrar, explicar y evitar

### Mostrar

- Último pipeline verde.
- Jobs y artefactos.
- Ejecución Break Glass completada.
- Tabla VAPT y evidencia representativa.
- Validación Terraform.
- Informe y playbook de incidentes.

### Explicar sin ejecutar

- Gates de seguridad.
- Doble aprobación.
- Arquitectura AWS.
- Comandos del playbook.
- Próximos pasos de producción.

### No mostrar

- Contraseñas, JWT, tokens o sesiones.
- Información personal de las cuentas auxiliares.
- Pestañas personales, correo o notificaciones.
- Rutas locales con información sensible innecesaria.

### No ejecutar

- `terraform apply`.
- Contención AWS CLI.
- Un nuevo Break Glass.
- PoC destructivas.
- Pushes innecesarios durante la grabación.

## 18. Preparación técnica del video

### Antes de grabar

- Confirmar que el último pipeline esté verde.
- Abrir las 12 pestañas en el orden sugerido.
- Iniciar Juice Shop local solo si se mostrará la interfaz.
- Ocultar barra de favoritos y notificaciones.
- Cerrar sesiones personales no necesarias.
- Usar zoom entre 110 % y 125 %.
- Probar micrófono y grabación a 1080p.
- Tener el guion en una segunda pantalla o impreso.

### Si se muestra Juice Shop local

```powershell
cd C:\Proyectos\secure-devsecops-juiceshop
docker build -t juice-shop:local .
docker run --rm --name juice-shop-local -p 3000:3000 juice-shop:local
```

Abrir `http://localhost:3000`. No es necesario volver a explotar las vulnerabilidades; las evidencias ya existen.

### Validaciones locales opcionales

```powershell
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform validate -no-color
gitleaks detect --source . --no-git
```

Ejecutarlas solo si aportan al video y ya se comprobó que funcionan.

## 19. Frase final recomendada

> Este proyecto no trata cada herramienta como un escaneo aislado. Las integra en un flujo con decisiones, evidencia, trazabilidad y respuesta. El resultado demuestra cómo reducir riesgo antes del despliegue y cómo actuar cuando un control preventivo no es suficiente.

