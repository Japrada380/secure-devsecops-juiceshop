# Threat Intelligence - IP 185.220.101.22

## Alcance

Enriquecimiento puntual realizado el 12 de agosto de 2026 sobre el indicador incluido en el escenario. La reputación de una IP cambia con el tiempo; los resultados deben conservar fecha y fuente y no atribuyen por sí solos una identidad humana.

## Resultado consolidado

| Campo | Resultado | Fuente / limitación |
|---|---|---|
| IP | `185.220.101.22` | Escenario del incidente |
| País / ciudad | Alemania / Berlín | AbuseIPDB, datos de IPInfo actualizados semanalmente |
| ASN | AS60729 | AbuseIPDB |
| Organización / ISP | Artikel10 e.V. | AbuseIPDB |
| Hostname | `berlin01.tor-exit.artikel10.org` | AbuseIPDB |
| Clasificación | Nodo de salida Tor | AbuseIPDB y página del operador Artikel10 |
| AbuseIPDB | 100% de confianza; 4.302 reportes de 595 fuentes | Consulta pública del 2026-08-12; los reportes comunitarios pueden contener ruido |
| Actividad reciente | Reportes dentro de la última semana | AbuseIPDB |
| VirusTotal | No verificado en esta revisión | El resultado detallado requiere acceso/sesión o API; no se inventa una puntuación |
| Shodan | No verificado en esta revisión | La ficha exacta no fue accesible públicamente desde el entorno de revisión |
| AlienVault OTX / MISP | No se confirmó un pulse/feed exacto | OTX requiere cuenta/API para una consulta reproducible; MISP depende de la instancia/feed utilizado |

## Fuentes

- AbuseIPDB: https://www.abuseipdb.com/check/185.220.101.22
- Operador Artikel10: https://artikel10.org/dienste/tor-relays/
- VirusTotal: https://www.virustotal.com/gui/ip-address/185.220.101.22
- Shodan: https://www.shodan.io/host/185.220.101.22
- AlienVault OTX: https://otx.alienvault.com/indicator/ip/185.220.101.22

## Evaluación

La IP debe considerarse de alto riesgo dentro del contexto del escenario porque aparece asociada al login no autorizado y a la exfiltración, y además está confirmada como infraestructura de salida Tor con numerosos reportes de abuso. Sin embargo, una salida Tor es compartida: bloquearla puede reducir riesgo inmediato, pero no identifica al atacante ni demuestra que el operador del relay participó en la actividad.

## Tratamiento recomendado

- Bloqueo o challenge temporal en puntos de autenticación sensibles, sujeto a impacto.
- Correlación con usuario, User-Agent, hora, región, MFA, API calls y sesiones posteriores.
- No utilizar geolocalización como único criterio de decisión.
- Revisar falsos positivos para usuarios legítimos que utilicen Tor.
- Reconsultar las fuentes y conservar las respuestas originales durante la investigación real.

