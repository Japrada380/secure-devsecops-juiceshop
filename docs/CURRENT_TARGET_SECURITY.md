# Estado actual y objetivo de seguridad

## Diagrama

```mermaid
flowchart LR
    subgraph Actual["Estado actual validado"]
        A1["Pipeline DevSecOps en GitHub Actions"]
        A2["SAST, secretos, IaC, filesystem e imagen"]
        A3["SBOM CycloneDX"]
        A4["DAST autenticado con JWT"]
        A5["Break Glass con dos aprobaciones"]
        A6["VAPT con evidencia parcial"]
        A7["Terraform validado sin despliegue"]
        A8["IR documental y reglas Sigma"]
    end

    subgraph Objetivo["Estado objetivo de producción"]
        O1["Ambientes y cuentas AWS separados"]
        O2["OIDC, mínimo privilegio y secretos rotados"]
        O3["Terraform plan/apply aprobado en sandbox"]
        O4["Backend remoto cifrado y bloqueado"]
        O5["Remediaciones VAPT y retests automáticos"]
        O6["SIEM con Sigma adaptado y probado"]
        O7["Respuesta automática con aprobación humana"]
        O8["Métricas, cumplimiento y mejora continua"]
    end

    A1 --> O1
    A2 --> O2
    A3 --> O8
    A4 --> O5
    A5 --> O7
    A6 --> O5
    A7 --> O3
    A7 --> O4
    A8 --> O6
```

## Lectura del estado

El estado actual demuestra integración y validación estática/dinámica en un entorno de evaluación. El estado objetivo añade controles operativos que requieren autorización, cuentas reales, separación organizacional, remediaciones implementadas y telemetría de producción.

La transición no consiste simplemente en ejecutar `terraform apply`: requiere gestión de cambios, revisión de costos, propietarios de controles, protección de evidencias, pruebas de recuperación y aceptación formal de riesgos residuales.

