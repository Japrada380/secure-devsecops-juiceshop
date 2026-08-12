# Plan de ejecución VAPT — estado final

## Secure DevSecOps — OWASP Juice Shop

## 1. Propósito

Este documento conserva el alcance planificado y registra el estado final de las pruebas ejecutadas. El informe autoritativo, los resultados completos y las referencias de evidencia se encuentran en [`VAPT_Report.md`](VAPT_Report.md).

Una prueba marcada como **no reproducible** indica que no se obtuvo evidencia suficiente para confirmar la vulnerabilidad bajo las condiciones evaluadas. No equivale a garantizar su inexistencia.

## 2. Estado consolidado

| ID | Prueba | Estado final | Evidencia principal |
|---|---|---|---|
| V-01 | SQL Injection (CWE-89) | Confirmada | `evidence/burp/V01_SQLi_Request_Response.txt`; `evidence/screenshots/V01_SQLi_Login_Bypass.png` |
| V-02 | Manipulación JWT (CWE-345) | No reproducible; firma validada | Resultado documentado en `VAPT_Report.md`; no existe archivo independiente |
| V-03 | SSRF (CWE-918) | No ejecutada / sin evidencia | No se reporta como resultado |
| V-04 | XXE (CWE-611) | No ejecutada / sin evidencia | No se reporta como resultado |
| V-05 | Mass Assignment (CWE-915) | No reproducible | `evidence/burp/V05_MassAssignment_Test.txt` |
| V-06 | Path Traversal (CWE-22) | No ejecutada / sin evidencia | No se reporta como resultado |
| V-07 | Missing Rate Limiting (CWE-307) | Confirmada | `poc-rate-limit.ps1`; `evidence/logs/rate-limit-test.txt`; `evidence/screenshots/V07_Rate_Limit_Test.png` |
| V-08 | Logging PII | No reproducible en el registro disponible | `evidence/logs/juice-shop.log` |
| V-09 | IDOR (CWE-639) | Confirmada | `evidence/burp/V09_IDOR_Basket.txt` |
| V-10 | Hardcoded Credentials (CWE-798) | No se identificaron secretos | `evidence/gitleaks/Gitleaks_No_Leaks.txt`; `evidence/gitleaks/Gitleaks_No_Leaks.png` |
| HA-01 | XSS reflejado (CWE-79) | Confirmada | `evidence/burp/XSS_Search.txt`; `evidence/screenshots/XSS_Search_Alert.png` |
| PA-01 | Stored XSS | No reproducible | `evidence/burp/XSS_Stored_Test.txt`; `evidence/screenshots/XSS_Stored_No_Reproducible.png` |

## 3. Actividades realizadas

- Pruebas manuales mediante navegador y Burp Suite.
- Modificación controlada de solicitudes y parámetros.
- Prueba automatizada de intentos consecutivos de autenticación.
- Revisión de registros de la aplicación.
- Análisis local de secretos mediante Gitleaks.
- Conservación de solicitudes, respuestas, logs y capturas.
- Consolidación de resultados confirmados y no reproducibles.

## 4. Actividades fuera del cierre

- SSRF, XXE y Path Traversal no se incorporaron como resultados porque no existe evidencia suficiente.
- No se implementaron correcciones sobre OWASP Juice Shop.
- No se ejecutaron retests posteriores a remediación.
- No se atribuyen evidencias inexistentes a la prueba JWT.

## 5. Criterio de cierre

La fase VAPT se considera documentalmente cerrada con cuatro hallazgos confirmados, cuatro pruebas no reproducibles, un control de secretos sin detecciones y tres pruebas no ejecutadas o sin evidencia. Las remediaciones y validaciones posteriores permanecen como trabajo futuro.

Para evitar contradicciones, cualquier consulta sobre severidad, impacto, procedimiento, recomendaciones o anexos debe remitirse a [`VAPT_Report.md`](VAPT_Report.md).
