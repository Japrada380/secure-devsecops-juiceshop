# Guion de sustentación — Secure DevSecOps Juice Shop

Duración sugerida: 8 a 10 minutos.

## 1. Apertura — 30 segundos

> Hola, soy Jhon Alex Prada Gomez. En esta prueba implementé un flujo Secure DevSecOps sobre OWASP Juice Shop. El objetivo fue integrar seguridad en el ciclo de desarrollo, documentar una evaluación VAPT, diseñar una línea base AWS con Terraform y resolver un escenario de respuesta a incidentes. Todo el trabajo está versionado y respaldado por evidencias reproducibles.

Mostrar: página principal del repositorio y tabla “Estado del proyecto”.

## 2. Arquitectura general — 45 segundos

> Cada push a `main` activa un pipeline que combina análisis estático, detección de secretos, revisión de infraestructura como código, análisis de vulnerabilidades, generación de SBOM, construcción de imagen y pruebas dinámicas autenticadas. Los resultados se publican como artefactos y los gates bloquean riesgos que superan los criterios definidos.

Mostrar: diagrama textual del README.

## 3. Pipeline DevSecOps — 2 minutos

> El pipeline comienza con Semgrep y reglas personalizadas. Gitleaks revisa secretos con historial Git completo. Checkov evalúa Terraform. Trivy analiza tanto el filesystem como la imagen, y las excepciones están justificadas y tienen vencimiento. También genero un SBOM CycloneDX.
>
> Para DAST, el pipeline levanta Juice Shop de forma aislada, crea un usuario efímero, obtiene un JWT válido e inyecta el token en OWASP ZAP. ZAP importa OpenAPI, realiza descubrimiento y active scan. Los hallazgos medios crean seguimiento y los hallazgos altos o críticos bloquean la ejecución.

Mostrar:

1. Última ejecución verde.
2. Lista de jobs.
3. Artefactos `cyclonedx-sbom` y `zap-authenticated-report`.
4. Un issue DAST generado, si está disponible.

No abrir ni mostrar tokens, contraseñas o valores sensibles.

## 4. Break Glass — 1 minuto

> El acceso de emergencia está separado del pipeline normal y solo se inicia manualmente. Exige una justificación y referencia auditable, registra un issue y pasa secuencialmente por aprobación de Seguridad y de Operaciones. La autorización final solo ocurre cuando ambas etapas fueron aprobadas.

Mostrar: ejecución manual exitosa y registro de las dos aprobaciones. Evitar ejecutar nuevamente el workflow durante la presentación.

## 5. VAPT — 2 minutos

> Consolidé el VAPT con alcance, metodología, superficie de ataque y anexos. Confirmé cuatro hallazgos: SQL Injection en login, ausencia de rate limiting, IDOR en el carrito y XSS reflejado en la búsqueda.
>
> También documenté las pruebas que no fueron reproducibles: manipulación JWT, Mass Assignment, Logging PII y Stored XSS. Esta separación evita presentar como vulnerabilidad algo que la evidencia no demuestra. Gitleaks no identificó secretos y ese resultado quedó registrado como control validado.

Mostrar:

- Tabla de estado consolidado.
- Una evidencia de SQL Injection.
- Registro de 30 intentos sin `429`.
- Respuesta del carrito con `UserId` ajeno.
- Captura del XSS reflejado.
- Resultado `no leaks found`.

> Las remediaciones y retests están marcados como pendientes porque no inventé evidencia de correcciones no implementadas.

## 6. Terraform — 1 minuto y 15 segundos

> Diseñé una línea base AWS modular con segmentación de red, Flow Logs, IAM, KMS, Secrets Manager, almacenamiento seguro de logs, CloudTrail, Config, GuardDuty, Security Hub y WAF. El secreto inicial está deshabilitado por defecto para evitar almacenarlo en el estado de Terraform.
>
> La prueba no exige una cuenta AWS real. Por eso validé formato y consistencia localmente, pero no ejecuté `plan` ni `apply`; así evité usar credenciales no autorizadas o generar costos.

Mostrar: `terraform/README.md` y la evidencia con `Success! The configuration is valid.`

## 7. Respuesta a Incidentes — 1 minuto y 15 segundos

> Para el escenario de compromiso AWS consolidé un informe que separa hechos de hipótesis, organiza la línea de tiempo, los IoC, MITRE ATT&CK, preservación de evidencia y remediación priorizada.
>
> Corregí el playbook para que no se use como un script ciego: primero confirma cuenta y región, preserva configuración, aplica contención temporal, inactiva claves, retira acceso de consola, aísla recursos con identificadores verificados y documenta reversión. Las reglas Sigma cubren elevación IAM, alteración de CloudTrail, login sin MFA y tareas ECS con imagen no aprobada.

Mostrar: resumen del informe y primeras secciones del playbook. No ejecutar comandos AWS.

## 8. Decisiones y limitaciones — 45 segundos

> Las decisiones principales fueron usar referencias inmutables en GitHub Actions, conservar evidencia tanto positiva como negativa, no desplegar infraestructura sin autorización y tratar Juice Shop como una aplicación deliberadamente vulnerable. Las excepciones se documentaron explícitamente y ninguna conclusión excede la evidencia disponible.

## 9. Cierre — 30 segundos

> El resultado es un repositorio reproducible que cubre prevención, detección, validación, respuesta y trazabilidad. Los módulos están integrados por el pipeline y documentados para revisión técnica. Como siguientes pasos en un entorno real, ejecutaría Terraform con backend remoto y credenciales autorizadas, aplicaría las remediaciones del VAPT y realizaría los retests correspondientes.

## Preguntas probables

### ¿Por qué no ejecutó Terraform en AWS?

Porque el alcance no exigía una cuenta real. `plan` y `apply` requieren credenciales autorizadas, pueden consultar o crear recursos y generar costos. Se realizó la validación local apropiada para el alcance.

### ¿Por qué algunos VAPT figuran como no reproducibles?

Porque la solicitud alcanzó un control previo o no produjo el comportamiento vulnerable. Se conserva la prueba y su limitación, sin convertir ausencia de evidencia en una garantía de seguridad.

### ¿Cómo evita que Juice Shop rompa siempre el pipeline?

Los gates diferencian severidad, alcance y excepciones justificadas. Trivy usa excepciones temporales documentadas para la imagen de entrenamiento; ZAP conserva reportes y aplica los umbrales definidos.

### ¿Cómo se protege Break Glass?

Es manual, exige trazabilidad y dos aprobaciones secuenciales de entornos distintos. Deben mantenerse revisores separados y `Prevent self-review` habilitado.

### ¿Qué mejoraría con más tiempo?

Aplicaría remediaciones sobre una aplicación controlada, ejecutaría retests, validaría Terraform en una cuenta sandbox autorizada y conectaría las reglas de detección a un SIEM para probar su comportamiento con eventos sintéticos.

## Recomendaciones para grabar

- Usar una ventana privada o cerrar pestañas personales.
- Ocultar notificaciones, nombres de cuenta y tokens.
- Preparar previamente las pestañas que se mostrarán.
- No escribir comandos largos en vivo; mostrar resultados ya generados.
- Mantener visible el commit y el pipeline verde más recientes.
- Grabar a 1080p y comprobar audio antes de la toma final.

