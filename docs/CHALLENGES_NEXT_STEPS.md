# Desafíos y próximos pasos

## Desafíos encontrados

- Integrar DAST autenticado contra una aplicación de una sola página y obtener cobertura OpenAPI verificable.
- Diferenciar vulnerabilidades confirmadas de pruebas no reproducibles sin inflar resultados.
- Mantener gates útiles sobre una aplicación deliberadamente vulnerable.
- Modelar seguridad AWS sin utilizar credenciales ni crear recursos con costo.
- Diseñar Break Glass con trazabilidad y separación de funciones dentro de las restricciones de una demostración.
- Convertir comandos de respuesta a incidentes en un playbook seguro con preservación, precondiciones y reversión.

## Próximos pasos prioritarios

1. Implementar las remediaciones VAPT en una aplicación controlada y ejecutar retests malicioso/legítimo.
2. Ampliar la cobertura a SSRF, XXE y Path Traversal con evidencia reproducible.
3. Completar la línea base Terraform con RDS, dos AZ, NACL, Object Lock, alarmas, reglas Config, rate limiting y geo-restricción.
4. Ejecutar `terraform plan` en una cuenta sandbox autorizada con backend remoto seguro.
5. Adaptar y probar las reglas Sigma contra el esquema del SIEM seleccionado.
6. Automatizar enriquecimiento de IoC mediante APIs autorizadas y conservar fecha, fuente y respuesta.
7. Agregar pruebas unitarias de reglas Semgrep y políticas de infraestructura.
8. Incorporar firma de imágenes, provenance y validación de cadena de suministro.
9. Realizar un tabletop exercise y medir tiempos de detección, contención y recuperación.
10. Reemplazar las cuentas de demostración de Break Glass por responsables organizacionales independientes.

