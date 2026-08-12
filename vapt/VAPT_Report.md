# Informe de Pruebas de Seguridad (VAPT)

## Secure DevSecOps — OWASP Juice Shop

## 1. Resumen ejecutivo

Se evaluó la aplicación OWASP Juice Shop y el repositorio del proyecto con pruebas manuales y automatizadas, utilizando exclusivamente la evidencia conservada en `vapt/evidence` y las PoC existentes en `vapt/poc`.

La evaluación confirmó cuatro hallazgos: inyección SQL en el inicio de sesión, ausencia de limitación de intentos de autenticación, acceso directo inseguro a objetos (IDOR) en el carrito y XSS reflejado en la búsqueda. La revisión de secretos con Gitleaks no encontró filtraciones. Las pruebas de manipulación JWT, Mass Assignment, Stored XSS y Logging PII no reprodujeron una vulnerabilidad en el entorno y condiciones evaluados.

Este estado no implica ausencia absoluta de vulnerabilidades; representa únicamente los resultados demostrados por la evidencia disponible.

### Estado consolidado

| ID | Prueba | Resultado | Evidencia |
|---|---|---|---|
| V-01 | SQL Injection | Confirmada | `evidence/burp/V01_SQLi_Request_Response.txt`; `evidence/screenshots/V01_SQLi_Login_Bypass.png` |
| V-02 | Manipulación JWT | No reproducible; control validado | Resultado documentado: respuesta 401 `invalid signature`; no existe archivo independiente en `evidence` |
| V-05 | Mass Assignment | No reproducible | `evidence/burp/V05_MassAssignment_Test.txt` |
| V-07 | Missing Rate Limiting | Confirmada | `poc-rate-limit.ps1`; `evidence/logs/rate-limit-test.txt`; `evidence/screenshots/V07_Rate_Limit_Test.png` |
| V-08 | Logging PII | No reproducible | `evidence/logs/juice-shop.log` |
| V-09 | IDOR | Confirmada | `evidence/burp/V09_IDOR_Basket.txt` |
| V-10 | Hardcoded Credentials | No identificada (`no leaks found`) | `evidence/gitleaks/Gitleaks_No_Leaks.txt`; `evidence/gitleaks/Gitleaks_No_Leaks.png` |
| HA-01 | XSS reflejado | Confirmada | `evidence/burp/XSS_Search.txt`; `evidence/screenshots/XSS_Search_Alert.png` |
| PA-01 | Stored XSS | No reproducible | `evidence/burp/XSS_Stored_Test.txt`; `evidence/screenshots/XSS_Stored_No_Reproducible.png` |

## 2. Alcance

El alcance documental comprende:

- La instancia local de OWASP Juice Shop, accesible durante las pruebas en `127.0.0.1:3000`.
- Los endpoints y funciones descritos en cada hallazgo.
- El repositorio local del proyecto para la detección de secretos con Gitleaks.
- Las evidencias ya generadas y almacenadas bajo `vapt/evidence`.

No se incluyen como resultados verificados las pruebas pendientes que carecen de evidencia en la carpeta, entre ellas SSRF, XXE y Path Traversal. Tampoco se declara remediación aplicada ni retest, pues no existe evidencia de esas actividades.

## 3. Metodología

La evaluación combinó:

1. Revisión de la superficie de ataque y selección de endpoints.
2. Interceptación y modificación manual de solicitudes HTTP.
3. Ejecución de PoC controladas contra el entorno local.
4. Revisión de respuestas HTTP, comportamiento del navegador y registros de la aplicación.
5. Búsqueda automatizada de secretos en el repositorio con Gitleaks.
6. Clasificación de cada prueba como confirmada, no reproducible o no identificada según la evidencia disponible.

Una prueba no reproducible significa que no se obtuvo evidencia suficiente para confirmar la vulnerabilidad bajo las condiciones evaluadas; no equivale a una garantía de inexistencia.

## 4. Superficie de ataque evaluada

| Componente | Interfaz evaluada | Pruebas relacionadas |
|---|---|---|
| Autenticación | `POST /rest/user/login` | SQL Injection, manipulación JWT, rate limiting |
| Carrito | `GET /rest/basket/{id}` | IDOR |
| API B2B | `POST /b2b/v2/orders` | Mass Assignment |
| Búsqueda | `/#/search?q=...` | XSS reflejado |
| Customer Feedback / Administration | Formulario y visualización de comentarios | Stored XSS |
| Registros de ejecución | `juice-shop.log` | Logging PII |
| Repositorio | Código y archivos versionados | Hardcoded Credentials |

## 5. Hallazgos confirmados

### 5.1 V-01 — SQL Injection (CWE-89)

**Estado:** Confirmada  
**Severidad registrada:** Crítica (CVSS base 9.8)  
**Endpoint:** `POST /rest/user/login`

Se utilizó el payload `' OR 1=1--` en el mecanismo de autenticación. La aplicación respondió `HTTP 200 OK` y permitió iniciar sesión como `admin@juice-sh.op` sin conocer la contraseña.

**Impacto:** acceso no autorizado con privilegios administrativos, con afectación potencial a la confidencialidad e integridad de la información.

**Recomendación:** utilizar consultas parametrizadas, evitar concatenación de entradas en SQL, validar datos de entrada y monitorear intentos anómalos de autenticación.

**Evidencia:**

- `evidence/burp/V01_SQLi_Request_Response.txt`
- `evidence/screenshots/V01_SQLi_Login_Bypass.png`

**Remediación y retest:** pendientes; no existe evidencia de implementación o validación posterior.

### 5.2 V-07 — Missing Rate Limiting (CWE-307)

**Estado:** Confirmada  
**Severidad registrada:** Alta (CVSS base 7.5)  
**Endpoint:** `POST /rest/user/login`

La PoC ejecutó 30 intentos consecutivos con credenciales inválidas. Todos recibieron `HTTP 401`; no se observó `HTTP 429`, bloqueo temporal, CAPTCHA ni otro mecanismo de limitación en la evidencia capturada.

**Impacto:** facilita ataques automatizados de fuerza bruta o credential stuffing y puede incrementar el consumo de recursos del servicio.

**Recomendación:** implementar limitación por IP y cuenta, retraso progresivo, bloqueo temporal, monitoreo y controles adaptativos como CAPTCHA o MFA para cuentas privilegiadas.

**Evidencia:**

- `poc-rate-limit.ps1`
- `evidence/logs/rate-limit-test.txt`
- `evidence/screenshots/V07_Rate_Limit_Test.png`

**Remediación y retest:** pendientes.

### 5.3 V-09 — IDOR (CWE-639)

**Estado:** Confirmada  
**Severidad registrada:** Media (CVSS base 6.5)  
**Endpoint:** `GET /rest/basket/{id}`

Un usuario autenticado solicitó `GET /rest/basket/1`. La respuesta fue `HTTP 200 OK` e incluyó un carrito con `UserId: 1`, correspondiente a un recurso ajeno al usuario de prueba.

**Impacto:** exposición de información perteneciente a otros usuarios y posible ampliación del riesgo si existen operaciones de modificación con el mismo defecto de autorización.

**Recomendación:** verificar en el servidor que el recurso solicitado pertenece al usuario autenticado y responder `403 Forbidden` o `404 Not Found` ante accesos cruzados.

**Evidencia:** `evidence/burp/V09_IDOR_Basket.txt`.

**Remediación y retest:** pendientes.

### 5.4 HA-01 — XSS reflejado (CWE-79)

**Estado:** Confirmada  
**Severidad registrada:** Media  
**Componente:** búsqueda `/#/search`

El payload `<iframe src="javascript:alert(`XSS`)">` incluido en el parámetro de búsqueda ejecutó JavaScript en el navegador y mostró una alerta con el texto `XSS`.

**Impacto:** ejecución de código en el contexto del navegador de la víctima, con riesgo de phishing, redirección maliciosa o acceso a información disponible para el contexto de la página.

**Recomendación:** codificar la salida según contexto, sanitizar contenido no confiable y aplicar una Content Security Policy restrictiva.

**Evidencia:**

- `evidence/burp/XSS_Search.txt`
- `evidence/screenshots/XSS_Search_Alert.png`

**Remediación y retest:** pendientes.

## 6. Pruebas no reproducibles y controles validados

### 6.1 V-02 — Manipulación JWT (CWE-345)

**Estado:** No reproducible; validación de firma observada.

La modificación manual del JWT produjo `HTTP 401 Unauthorized` con el mensaje `invalid signature`. No fue posible falsificar una sesión mediante el token alterado.

**Limitación de evidencia:** el resultado estaba documentado en el informe previo, pero no existe un archivo independiente asociado en `vapt/evidence`. No se atribuye una captura o registro inexistente.

### 6.2 V-05 — Mass Assignment (CWE-915)

**Estado:** No reproducible.

Se agregó el atributo no documentado `role: admin` a una solicitud `POST /b2b/v2/orders`. La API respondió `HTTP 401 Unauthorized` con `invalid signature`; la solicitud no alcanzó la lógica de negocio y no permitió determinar si el atributo sería aceptado.

**Evidencia:** `evidence/burp/V05_MassAssignment_Test.txt`.

### 6.3 V-08 — Logging PII

**Estado:** No reproducible en el registro disponible.

Se revisó el registro de ejecución conservado. La evidencia contiene información operativa, advertencias de configuración y eventos de la aplicación, pero no demuestra exposición de PII. Esta conclusión se limita al archivo y período capturados.

**Evidencia:** `evidence/logs/juice-shop.log`.

### 6.4 V-10 — Hardcoded Credentials (CWE-798)

**Estado:** No se identificaron secretos.

Se ejecutó:

```powershell
gitleaks detect --source . --no-git
```

Gitleaks analizó aproximadamente 163.59 KB y reportó `no leaks found`. El resultado valida la ausencia de coincidencias en ese análisis puntual; no se presenta como garantía absoluta sobre otros historiales o fuentes no incluidos por `--no-git`.

**Evidencia unificada:**

- `evidence/gitleaks/Gitleaks_No_Leaks.txt`
- `evidence/gitleaks/Gitleaks_No_Leaks.png`

### 6.5 PA-01 — Stored XSS

**Estado:** No reproducible.

Se envió `<img src=x onerror=alert('XSS Feedback')>` mediante Customer Feedback y se revisó en Administration. El payload no se ejecutó, por lo que no se demostró Stored XSS en la versión evaluada.

**Evidencia:**

- `evidence/burp/XSS_Stored_Test.txt`
- `evidence/screenshots/XSS_Stored_No_Reproducible.png`

## 7. Conclusión

La evidencia disponible confirma debilidades relevantes en autenticación, autorización y manejo de contenido no confiable. La prioridad de corrección debe comenzar por SQL Injection, seguida de rate limiting, IDOR y XSS reflejado. Después de implementar controles, deben repetirse las PoC y conservarse evidencias de retest.

Las pruebas no reproducibles deben mantenerse diferenciadas de los hallazgos confirmados. La búsqueda de Gitleaks constituye un resultado positivo de control, mientras que JWT, Mass Assignment, Logging PII y Stored XSS reflejan únicamente que la vulnerabilidad no se demostró en las condiciones actuales.

Con este informe consolidado, el entregable VAPT queda documentalmente preparado para cerrar su organización y continuar con el módulo Terraform. Las pruebas pendientes sin evidencia no se incorporan como resultados.

## 8. Anexos

### Anexo A — Índice de evidencias

```text
vapt/
├── VAPT_Report.md
├── poc-rate-limit.ps1
└── evidence/
    ├── burp/
    │   ├── V01_SQLi_Request_Response.txt
    │   ├── V05_MassAssignment_Test.txt
    │   ├── V09_IDOR_Basket.txt
    │   ├── XSS_Search.txt
    │   └── XSS_Stored_Test.txt
    ├── gitleaks/
    │   ├── Gitleaks_No_Leaks.txt
    │   └── Gitleaks_No_Leaks.png
    ├── logs/
    │   ├── juice-shop.log
    │   └── rate-limit-test.txt
    └── screenshots/
        ├── V01_SQLi_Login_Bypass.png
        ├── V07_Rate_Limit_Test.png
        ├── XSS_Search_Alert.png
        └── XSS_Stored_No_Reproducible.png
```

### Anexo B — Criterios de interpretación

- **Confirmada:** existe evidencia que demuestra el comportamiento vulnerable.
- **No reproducible:** la prueba fue realizada, pero no confirmó la vulnerabilidad bajo las condiciones evaluadas.
- **No identificada:** la herramienta no detectó coincidencias en el alcance analizado.
- **Pendiente:** no existe evidencia suficiente para reportar un resultado.
