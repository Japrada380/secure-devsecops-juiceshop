# Vulnerabilidades Identificadas

## V-01 – SQL Injection (CWE-89)

- **CVSS v3.1:** 9.8 (Critical)
- **OWASP Top 10 2021:** A03:2021 – Injection
- **CWE:** CWE-89

### Evidencia

Se logró eludir el mecanismo de autenticación utilizando un payload de inyección SQL en el formulario de inicio de sesión de OWASP Juice Shop.

### PoC

**Endpoint**

```
POST /rest/user/login
```

**Payload**

```sql
' OR 1=1--
```

### Resultado

El servidor permitió el inicio de sesión sin conocer credenciales válidas, evidenciando una validación insuficiente de la entrada del usuario.

### Impacto

**Confidencialidad:** Alta

**Integridad:** Alta

**Disponibilidad:** Baja

Existe riesgo de acceso no autorizado a información sensible y compromiso de cuentas.

### Remediación

- Consultas parametrizadas.
- ORM seguro.
- Validación de entradas.
- Principio de mínimo privilegio para cuentas de base de datos.

### Validación

Después de aplicar la remediación, el payload debe ser rechazado y un inicio de sesión con credenciales legítimas debe continuar funcionando correctamente.

---

---
# V-02 – Broken Authentication / JWT (CWE-345)

- **CVSS v3.1:** 9.1 (Critical)
- **OWASP Top 10 2021:** A07:2021 – Identification and Authentication Failures
- **CWE:** CWE-345

## Evidencia

Durante el análisis de la aplicación se identificó el uso de tokens JWT para la autenticación de usuarios. Se verificó la estructura del token y el mecanismo de autenticación utilizado por la API.

## PoC

**Token observado**

```
Authorization: Bearer eyJ...
```

Se inspeccionó el JWT obtenido después de autenticarse y se verificó su utilización en las peticiones autenticadas.

## Resultado

No se evidenció aceptación de tokens manipulados con `alg:none` durante las pruebas realizadas.

El análisis permitió documentar el mecanismo de autenticación implementado y dejar identificado este vector como parte del VAPT.

## Impacto

- Confidencialidad: Alta
- Integridad: Alta
- Disponibilidad: Baja

Una implementación insegura de JWT permitiría la suplantación de identidad y el acceso no autorizado a recursos protegidos.

## Remediación

- Validar siempre la firma del JWT.
- Rechazar el algoritmo `none`.
- Utilizar algoritmos robustos (RS256 o ES256).
- Configurar tiempos de expiración adecuados.
- Rotar periódicamente las claves de firma.

## Validación

Se debe verificar que únicamente sean aceptados JWT firmados correctamente y emitidos por la aplicación.

---

---

# V-03 – Server-Side Request Forgery (SSRF) (CWE-918)

- **CVSS v3.1:** 8.8 (High)
- **OWASP Top 10 2021:** A10:2021 – Server-Side Request Forgery (SSRF)
- **CWE:** CWE-918

## Evidencia

Durante la revisión de la aplicación no se identificó un endpoint funcional que aceptara un parámetro de tipo `url` y permitiera realizar solicitudes desde el servidor hacia recursos internos.

## PoC

Se inspeccionaron los endpoints disponibles buscando parámetros susceptibles a SSRF, incluyendo referencias a URLs externas e internas.

No fue posible demostrar una explotación funcional en la versión evaluada de OWASP Juice Shop.

## Resultado

No se encontró evidencia de una vulnerabilidad SSRF explotable durante el VAPT realizado.

## Impacto

Si existiera esta vulnerabilidad, un atacante podría:

- Acceder a servicios internos.
- Consultar metadatos de infraestructura cloud.
- Evadir controles perimetrales.
- Exfiltrar información sensible.

## Remediación

- Implementar listas blancas de destinos permitidos.
- Validar esquemas (`http`/`https`).
- Bloquear acceso a direcciones internas.
- Utilizar proxies de salida controlados.

## Validación

Intentar nuevamente el acceso a recursos internos (por ejemplo, `169.254.169.254`) debe resultar bloqueado.

---

---

# V-04 – XML External Entity (XXE) (CWE-611)

- **CVSS v3.1:** 8.6 (High)
- **OWASP Top 10 2021:** A05:2021 – Security Misconfiguration
- **CWE:** CWE-611

## Evidencia

Durante el análisis de la aplicación se revisó la presencia de funcionalidades que procesaran documentos XML suministrados por el usuario.

No se identificaron endpoints que aceptaran archivos XML ni procesamiento de entidades externas en la versión evaluada.

## PoC

Se inspeccionaron las funcionalidades disponibles buscando cargas XML y puntos de entrada para entidades externas.

No fue posible demostrar una explotación funcional.

## Resultado

No se encontró evidencia de una vulnerabilidad XXE explotable en el entorno de evaluación.

## Impacto

Una vulnerabilidad XXE podría permitir:

- Lectura de archivos locales.
- SSRF.
- Divulgación de información sensible.
- Denegación de servicio.

## Remediación

- Deshabilitar entidades externas.
- Utilizar parsers seguros.
- Validar el contenido XML recibido.
- Aplicar listas blancas de esquemas permitidos.

## Validación

Se debe comprobar que cualquier documento XML con entidades externas sea rechazado o procesado sin resolver dichas entidades.

---

---

# V-05 – Mass Assignment (CWE-915)

- **CVSS v3.1:** 8.1 (High)
- **OWASP Top 10 2021:** A01:2021 – Broken Access Control
- **CWE:** CWE-915

## Evidencia

Durante el análisis de la API se revisó el comportamiento de los endpoints que reciben objetos JSON para identificar si aceptaban atributos no autorizados enviados por el cliente.

No se identificó un endpoint vulnerable que permitiera modificar privilegios mediante asignación masiva de atributos.

## PoC

Se analizaron las solicitudes HTTP con cuerpos JSON utilizando las herramientas del navegador y Burp Suite, verificando la aceptación de atributos adicionales.

No fue posible demostrar una explotación funcional.

## Resultado

No se encontró evidencia de una vulnerabilidad de Mass Assignment explotable en el entorno evaluado.

## Impacto

Una vulnerabilidad de Mass Assignment podría permitir:

- Escalamiento de privilegios.
- Modificación de atributos internos.
- Acceso no autorizado a funciones administrativas.
- Alteración de datos sensibles.

## Remediación

- Implementar listas blancas de atributos permitidos.
- Ignorar campos no autorizados.
- Validar los modelos de entrada.
- Aplicar controles de autorización del lado del servidor.

## Validación

Verificar que únicamente los atributos autorizados sean aceptados y que cualquier campo adicional sea rechazado o ignorado.

---

---

# V-06 – Path Traversal (CWE-22)

- **CVSS v3.1:** 7.5 (High)
- **OWASP Top 10 2021:** A01:2021 – Broken Access Control
- **CWE:** CWE-22

## Evidencia

Durante la evaluación se analizaron las funcionalidades de descarga y acceso a recursos estáticos buscando parámetros que permitieran manipular rutas de archivos.

No se identificó un endpoint vulnerable que permitiera acceder a archivos fuera del directorio autorizado.

## PoC

Se realizaron pruebas utilizando secuencias de directorio como:

```
../../../../etc/passwd
```

y

```
..\..\..\..\windows\win.ini
```

No fue posible acceder a archivos del sistema.

## Resultado

No se encontró evidencia de una vulnerabilidad de Path Traversal explotable en el entorno evaluado.

## Impacto

Una vulnerabilidad de Path Traversal podría permitir:

- Lectura de archivos sensibles.
- Divulgación de credenciales.
- Exposición de configuraciones internas.
- Acceso a información confidencial.

## Remediación

- Normalizar las rutas recibidas.
- Validar los nombres de archivo permitidos.
- Implementar listas blancas.
- Evitar concatenar rutas proporcionadas por el usuario.

## Validación

Comprobar que cualquier intento de utilizar secuencias de recorrido de directorios sea rechazado por la aplicación.

---

---

# V-07 – Missing Rate Limiting (CWE-307)

- **CVSS v3.1:** 7.5 (High)
- **OWASP Top 10 2021:** A07:2021 – Identification and Authentication Failures
- **CWE:** CWE-307

## Evidencia

Durante la evaluación se revisó el endpoint de autenticación para determinar si existían mecanismos de limitación de intentos de inicio de sesión consecutivos.

No se evidenció un mecanismo de bloqueo temporal o limitación de solicitudes durante las pruebas realizadas.

## PoC

Se ejecutaron múltiples intentos consecutivos de autenticación utilizando credenciales inválidas para observar el comportamiento del servicio.

No se detectó un mecanismo visible de rate limiting durante la evaluación.

## Resultado

El endpoint de autenticación presenta riesgo de ataques de fuerza bruta o credential stuffing si no existe una limitación efectiva de intentos.

## Impacto

- Fuerza bruta de credenciales.
- Credential Stuffing.
- Incremento del riesgo de compromiso de cuentas.
- Consumo innecesario de recursos del servidor.

## Remediación

- Implementar Rate Limiting.
- Bloqueo temporal por IP.
- CAPTCHA después de múltiples intentos.
- MFA para cuentas sensibles.
- Monitoreo y alertamiento de intentos fallidos.

## Validación

Verificar que después de múltiples intentos fallidos el servicio limite nuevas solicitudes y continúe permitiendo autenticaciones legítimas.

---

---

# V-08 – Logging de Información Personal (PII) (CWE-359)

- **CVSS v3.1:** 7.5 (High)
- **OWASP Top 10 2021:** A09:2021 – Security Logging and Monitoring Failures
- **CWE:** CWE-359

## Evidencia

Durante el análisis de la aplicación se revisó el manejo de información personal y los registros generados durante la autenticación y las operaciones del usuario.

No se identificó evidencia de almacenamiento de datos personales en texto plano dentro de los logs del entorno evaluado.

## PoC

Se inspeccionaron los registros generados durante operaciones de autenticación y navegación para verificar la presencia de información sensible.

No se observó exposición de PII en los registros disponibles.

## Resultado

No se encontró evidencia de exposición de información personal identificable (PII) en los registros analizados.

## Impacto

Si existiera esta vulnerabilidad podría ocasionar:

- Exposición de datos personales.
- Incumplimiento de la Ley 1581 de 2012.
- Riesgos regulatorios.
- Acceso no autorizado a información sensible.

## Remediación

- Enmascarar datos sensibles en todos los niveles de logging.
- Evitar registrar contraseñas, tokens y datos personales.
- Aplicar políticas de retención y protección de logs.
- Implementar controles de acceso sobre los registros.

## Validación

Verificar que los registros generados no contengan información personal identificable ni credenciales en texto plano.

---

---

# V-09 – Insecure Direct Object Reference (IDOR) (CWE-639)

- **CVSS v3.1:** 6.5 (Medium)
- **OWASP Top 10 2021:** A01:2021 – Broken Access Control
- **CWE:** CWE-639

## Evidencia

Durante el análisis se revisaron los endpoints que reciben identificadores de recursos con el fin de verificar si era posible acceder a información perteneciente a otros usuarios modificando únicamente el identificador enviado en la solicitud.

No se identificó un endpoint vulnerable que permitiera explotar un IDOR en el entorno evaluado.

## PoC

Se modificaron identificadores de recursos en solicitudes HTTP autenticadas para verificar controles de autorización.

No fue posible acceder a información perteneciente a otros usuarios.

## Resultado

No se encontró evidencia de una vulnerabilidad IDOR explotable durante la evaluación.

## Impacto

Una vulnerabilidad IDOR podría permitir:

- Acceso a información de otros usuarios.
- Modificación no autorizada de recursos.
- Exposición de datos personales.
- Incumplimiento de controles de autorización.

## Remediación

- Validar autorización en el servidor para cada recurso solicitado.
- No confiar en identificadores enviados por el cliente.
- Implementar controles de acceso basados en el usuario autenticado.
- Registrar intentos de acceso no autorizado.

## Validación

Verificar que un usuario autenticado únicamente pueda acceder a los recursos que le pertenecen.

---

---

# V-10 – Hardcoded Credentials (CWE-798)

- **CVSS v3.1:** 9.0 (Critical)
- **OWASP Top 10 2021:** A02:2021 – Cryptographic Failures
- **CWE:** CWE-798

## Evidencia

Durante la revisión del código fuente y la configuración del proyecto se verificó la presencia de credenciales, secretos, claves API y tokens almacenados directamente en archivos del repositorio.

Se utilizaron herramientas de análisis estático de secretos (Gitleaks) como parte del pipeline DevSecOps para detectar posibles credenciales expuestas.

## PoC

Se ejecutó el análisis del repositorio utilizando Gitleaks para identificar secretos incrustados en el código fuente.

No se identificaron credenciales activas expuestas en el estado final del repositorio.

## Resultado

No se encontró evidencia de credenciales hardcodeadas en la versión final evaluada.

## Impacto

La presencia de credenciales embebidas en el código puede permitir:

- Acceso no autorizado a infraestructura.
- Compromiso de servicios cloud.
- Escalamiento de privilegios.
- Exposición de información sensible.

## Remediación

- Utilizar variables de entorno.
- Almacenar secretos en AWS Secrets Manager.
- Integrar escaneo de secretos en el pipeline CI/CD.
- Rotar inmediatamente cualquier credencial expuesta.

## Validación

Verificar mediante Gitleaks que el repositorio no contenga secretos, tokens o credenciales almacenadas directamente en el código fuente.

---

# Estado General del VAPT

| Vulnerabilidad | Estado |
|----------------|--------|
| V-01 – SQL Injection | ✅ Documentado |
| V-02 – Broken Authentication / JWT | ✅ Documentado |
| V-03 – SSRF | ✅ Documentado |
| V-04 – XXE | ✅ Documentado |
| V-05 – Mass Assignment | ✅ Documentado |
| V-06 – Path Traversal | ✅ Documentado |
| V-07 – Missing Rate Limiting | ✅ Documentado |
| V-08 – Logging de PII | ✅ Documentado |
| V-09 – IDOR | ✅ Documentado |
| V-10 – Hardcoded Credentials | ✅ Documentado |