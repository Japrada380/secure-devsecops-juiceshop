# Plan de Ejecución VAPT
## Prueba Técnica – Ingeniero de Ciberseguridad
### Secure DevSecOps – OWASP Juice Shop

---

# Estado General

| ID | Vulnerabilidad | Aplicación | Evidencia | Remediación | Estado |
|----|----------------|------------|-----------|-------------|--------|
| V-01 | SQL Injection (CWE-89) | Juice Shop | ❌ | ❌ | Pendiente |
| V-02 | Broken Authentication / JWT (CWE-345) | Juice Shop | ✅ | N/A | Control validado |
| V-03 | SSRF (CWE-918) | Por validar | ❌ | ❌ | Pendiente |
| V-04 | XXE (CWE-611) | Por validar | ❌ | ❌ | Pendiente |
| V-05 | Mass Assignment (CWE-915) | Por validar | ❌ | ❌ | Pendiente |
| V-06 | Path Traversal (CWE-22) | Por validar | ❌ | ❌ | Pendiente |
| V-07 | Missing Rate Limiting (CWE-307) | Juice Shop | ✅ | ❌ | En progreso |
  V-08     No reproducible en Juice Shop. Se implementará en el proyecto propio.
| V-09 | IDOR (CWE-639) | Juice Shop | ✅ | N/A | No reproducible (pendiente de documentar) |
| V-10 | Hardcoded Credentials (CWE-798) | Proyecto | ❌ | ❌ | Pendiente |

---

# Evidencias obtenidas

## V-02 – Broken Authentication / JWT

Estado:

- Control de seguridad validado.

Evidencia obtenida:

- Modificación manual del JWT mediante Burp Suite.
- Respuesta HTTP 401 Unauthorized.
- Mensaje: invalid signature.

Conclusión:

La aplicación valida correctamente la firma del token JWT. No fue posible falsificar una sesión mediante modificación del token.

---

## V-07 – Missing Rate Limiting

Estado:

En proceso.

Evidencia obtenida:

- Script PowerShell ejecutado.
- 30 intentos consecutivos de autenticación.
- Respuestas HTTP 401.
- No se observó HTTP 429 ni bloqueo temporal.

Pendiente:

- Clasificación del hallazgo.
- Remediación.
- Validación posterior.

---

## V-09 – IDOR

Estado:

No reproducible.

Pruebas realizadas:

- Modificación de BasketId.
- Modificación de BasketItem.
- Validación entre dos usuarios.
- Manipulación mediante Burp Suite.

Resultado:

No fue posible acceder o modificar recursos pertenecientes a otro usuario.

Conclusión:

Hasta el momento no existe evidencia suficiente para confirmar una vulnerabilidad IDOR en el entorno evaluado.

---

# Próximas actividades

1. Validar SQL Injection.
2. Validar SSRF.
3. Validar XXE.
4. Validar Mass Assignment.
5. Validar Path Traversal.
6. Documentar Logging de PII.
7. Documentar Hardcoded Credentials.
8. Completar el informe VAPT.

## 8.1 V-01 – Inyección SQL (SQL Injection)

### Estado

**Confirmada**

---

### Severidad

**Crítica (CVSS Base: 9.8)**

---

### CWE

**CWE-89 – Neutralización incorrecta de elementos especiales utilizados en una sentencia SQL (SQL Injection).**

---

### OWASP Top 10 2021

**A03:2021 – Inyección (Injection).**

---

### Descripción

Durante la evaluación del mecanismo de autenticación de la aplicación OWASP Juice Shop v20.0.0 se identificó una vulnerabilidad de Inyección SQL en el endpoint de inicio de sesión.

Mediante un payload SQL fue posible omitir la validación de credenciales e iniciar sesión como el usuario administrador sin conocer su contraseña.

---

### Endpoint afectado

```http
POST /rest/user/login
```

---

### Prueba de Concepto (PoC)

**Payload utilizado:**

```text
' OR 1=1--
```

**Resultado obtenido:**

- Respuesta HTTP **200 OK**.
- Inicio de sesión exitoso.
- Acceso como usuario **Administrador** (`admin@juice-sh.op`).

---

### Evidencia

**Archivos asociados:**

- `vapt/evidence/burp/V01_SQLi_Request_Response.txt`
- `vapt/evidence/screenshots/V01_SQLi_Login_Bypass.png`

---

### Impacto

**Confidencialidad:** Alta.

Permite acceder a información restringida sin autorización.

**Integridad:** Alta.

Un atacante podría modificar información utilizando privilegios administrativos.

**Disponibilidad:** Media.

El acceso privilegiado podría utilizarse para afectar la disponibilidad del servicio.

**Ley 1581 de 2012**

La explotación de esta vulnerabilidad podría permitir el acceso no autorizado a datos personales, incumpliendo los principios de confidencialidad y seguridad establecidos en la Ley 1581 de 2012.

---

### Remediación

**Pendiente de implementar.**

---

### Validación posterior

**Pendiente de ejecutar después de aplicar la remediación.**

### Remediación propuesta

La vulnerabilidad se origina por la construcción insegura de consultas SQL utilizando entradas controladas por el usuario.

Se recomienda implementar las siguientes medidas:

1. Utilizar consultas parametrizadas (Prepared Statements).
2. Emplear un ORM que evite la concatenación directa de cadenas SQL.
3. Validar y sanitizar todas las entradas del usuario.
4. Implementar autenticación basada en comparación segura de credenciales.
5. Registrar y monitorear intentos de autenticación anómalos.
6. Implementar limitación de intentos (Rate Limiting) para reducir ataques automatizados.

#### Ejemplo de implementación segura

**Inseguro**

```javascript
const query = "SELECT * FROM Users WHERE email='" + email + "' AND password='" + password + "'";
```

**Seguro**

```javascript
const query = "SELECT * FROM Users WHERE email = ?";
db.execute(query, [email]);
```

## 8.2 V-07 – Ausencia de limitación de intentos de autenticación (Missing Rate Limiting)

### Estado

**Confirmada**

---

### Severidad

**Alta (CVSS Base: 7.5)**

**Vector CVSS v3.1**

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:L/A:N
```

---

### CWE

**CWE-307 – Improper Restriction of Excessive Authentication Attempts**

---

### OWASP Top 10 2021

**A07:2021 – Identification and Authentication Failures**

---

### Descripción

Durante la evaluación del mecanismo de autenticación de OWASP Juice Shop v20.0.0 se verificó la ausencia de controles efectivos para limitar múltiples intentos consecutivos de autenticación fallidos.

Se ejecutó una prueba automatizada de fuerza bruta mediante un script de PowerShell que realizó 30 intentos consecutivos utilizando credenciales inválidas.

La aplicación respondió con código **HTTP 401 Unauthorized** en todos los intentos, sin evidenciar mecanismos de protección como bloqueo temporal, CAPTCHA, incremento progresivo del tiempo de espera o limitación por dirección IP.

---

### Endpoint evaluado

```http
POST /rest/user/login
```

---

### Prueba de Concepto (PoC)

Se ejecutó el script:

```text
vapt/poc/poc-rate-limit.ps1
```

El script realizó treinta (30) intentos consecutivos de autenticación utilizando credenciales inválidas.

Fragmento de la evidencia:

```text
Attempt 01 -> HTTP 401
Attempt 02 -> HTTP 401
Attempt 03 -> HTTP 401
...
Attempt 28 -> HTTP 401
Attempt 29 -> HTTP 401
Attempt 30 -> HTTP 401
```

Durante toda la prueba no se observó:

- HTTP 429 (Too Many Requests).
- Bloqueo temporal de la cuenta.
- Incremento progresivo del tiempo de respuesta.
- CAPTCHA.
- Restricción por dirección IP.

---

### Evidencia

Se recopiló la siguiente evidencia durante la prueba:

**Script utilizado**

```
vapt/poc/poc-rate-limit.ps1
```

**Registro de ejecución**

```
vapt/evidence/logs/rate-limit-test.txt
```

**Captura de la consola**

```
vapt/evidence/screenshots/V07_Rate_Limit_Test.png
```

**Captura de Burp Suite (opcional)**

```
vapt/evidence/screenshots/V07_Burp_History.png
```

---

### Impacto

#### Confidencialidad

**Alta**

Un atacante podría realizar ataques de fuerza bruta o credential stuffing hasta obtener credenciales válidas.

#### Integridad

**Baja**

La vulnerabilidad no modifica directamente la información, pero facilita el acceso no autorizado.

#### Disponibilidad

**Media**

Los ataques automatizados podrían consumir recursos del servicio de autenticación y afectar su disponibilidad.

#### Ley 1581 de 2012

La explotación exitosa de esta vulnerabilidad podría permitir el acceso no autorizado a datos personales, incumpliendo el principio de seguridad establecido en la Ley 1581 de 2012.

---

### Remediación

Se recomienda implementar las siguientes medidas:

1. Rate Limiting por dirección IP.
2. Bloqueo temporal de la cuenta después de múltiples intentos fallidos.
3. Retraso progresivo entre intentos consecutivos.
4. CAPTCHA adaptativo después de un número determinado de intentos.
5. Autenticación multifactor (MFA) para cuentas privilegiadas.
6. Alertamiento y monitoreo de intentos repetitivos.

Ejemplo utilizando Express Rate Limit:

```javascript
const rateLimit = require("express-rate-limit");

const loginLimiter = rateLimit({
    windowMs: 5 * 60 * 1000,
    max: 10,
    message: "Demasiados intentos de autenticación. Intente nuevamente más tarde."
});

app.use("/rest/user/login", loginLimiter);
```

---

### Validación posterior

Después de implementar la remediación se deberá repetir la prueba de fuerza bruta verificando que:

- Después del límite configurado la aplicación responda con **HTTP 429 Too Many Requests** o aplique un mecanismo equivalente.
- La cuenta sea bloqueada temporalmente cuando corresponda.
- Los intentos legítimos continúen funcionando correctamente una vez finalice el período de bloqueo.

---

### Conclusión

La evaluación confirmó la ausencia de mecanismos efectivos para limitar intentos consecutivos de autenticación fallidos.

Este comportamiento incrementa el riesgo de ataques de fuerza bruta y credential stuffing, por lo que se recomienda implementar controles de limitación de intentos y monitoreo continuo del proceso de autenticación.

## 8.3 V-10 – Credenciales Hardcodeadas (Hardcoded Credentials)

### Estado

**No se identificó la vulnerabilidad.**

---

### Severidad

Crítica (CVSS Base: 9.0)

---

### CWE

CWE-798 – Use of Hard-coded Credentials

---

### OWASP Top 10 2021

A02:2021 – Cryptographic Failures

---

### Descripción

Se realizó una revisión del código fuente utilizando búsquedas manuales y herramientas de análisis de secretos integradas en el pipeline DevSecOps.

No se identificaron credenciales, contraseñas, claves AWS, API Keys ni tokens almacenados directamente en el repositorio.

---

### Evidencia

Se ejecutó:

```bash
git grep -nEi "password|passwd|secret|token|apikey|api_key|access_key|secret_key|AKIA"
```

Los resultados corresponden únicamente a:

- Reglas de Semgrep.
- Configuración de Gitleaks.
- Variables temporales del pipeline.
- AWS Secrets Manager.
- Documentación.

No se encontraron credenciales reales expuestas.

---

### Controles implementados

- Gitleaks en pre-commit.
- Gitleaks en GitHub Actions.
- AWS Secrets Manager.
- Variables de entorno.
- Enmascaramiento de secretos mediante `::add-mask::`.

---

### Impacto

No se evidenció exposición de credenciales.

El riesgo se considera mitigado mediante los controles implementados.

---

### Validación

La ejecución de Gitleaks y la revisión manual no identificaron secretos expuestos en el repositorio.
