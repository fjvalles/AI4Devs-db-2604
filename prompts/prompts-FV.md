# Prompts FV - Modelo de datos LTI

## Contexto del ejercicio

Repositorio: `AI4Devs-db-2604`

Archivo revisado: `4. Modelo de datos de LTI - AI4Devs 2026/04.pdf`

Objetivo: actualizar el modelo de datos del sistema LTI para soportar companias,
empleados, posiciones, flujos de entrevista, postulaciones y entrevistas,
partiendo del esquema Prisma existente y entregando cambios de modelo mas una
migracion SQL reproducible.

Nota de alcance: esta solucion parte del schema existente del repositorio. La
migracion agregada no es una migracion inicial para una base de datos vacia; asume
que ya existen las tablas Candidate, Education, WorkExperience y Resume.

## Prompt 1 - Leer el enunciado y extraer requisitos

Prompt:

```text
Actua como staff software engineer. Lee el enunciado del ejercicio "Modelo de datos
de LTI", extrae las entidades, relaciones y criterios de entrega. Convierte el ERD
Mermaid en requisitos concretos de base de datos y senala cualquier decision de
diseno que deba resolverse antes de modificar el schema Prisma.
```

Resultado:

- El ejercicio pide expandir el modelo actual para operar aplicaciones a diversas
  posiciones.
- Entidades nuevas requeridas: Company, Employee, Position, InterviewFlow,
  InterviewStep, InterviewType, Application e Interview.
- Candidate ya existe en el proyecto y debe integrarse con Application.
- La entrega debe limitarse a cambios de modelo, migracion SQL en
  `backend/prisma` y prompts en `prompts`.
- Decisiones de diseno:
  - Mantener los modelos existentes y anadir relaciones sin romper el API actual.
  - Usar `DateTime @db.Date` para fechas de negocio.
  - Usar `Decimal @db.Decimal(10, 2)` para rangos salariales.
  - Anadir indices en claves foraneas, estados, visibilidad y campos de busqueda.
  - Usar restricciones unicas para email de empleados, nombre de compania, nombre
    de tipo de entrevista, postulacion unica por candidato/posicion y orden unico
    de pasos por flujo.

## Prompt 2 - Inspeccionar el esquema actual

Prompt:

```text
Actua como staff software engineer. Inspecciona `backend/prisma/schema.prisma`, las
migraciones existentes y los scripts del backend. Resume el estado actual de la base
de datos, identifica compatibilidad con el ejercicio y recomienda el alcance minimo
de cambios para una entrega limpia.
```

Resultado:

- El schema actual define Candidate, Education, WorkExperience y Resume.
- Candidate ya tiene `email` unico y relaciones con educacion, experiencia y CV.
- No hay migraciones versionadas previas, solo `migration_lock.toml`.
- El backend usa Prisma 5.13 y PostgreSQL.
- Alcance recomendado:
  - Actualizar `schema.prisma` sin cambiar los modelos existentes salvo la nueva
    relacion `applications`.
  - Crear una migracion SQL nueva que cree solo las entidades LTI nuevas, indices
    y claves foraneas.
  - Validar con `prisma validate` y `prisma generate`.

## Prompt 3 - Disenar el modelo Prisma final

Prompt:

```text
Actua como staff software engineer. A partir del ERD Mermaid y del schema Prisma
actual, propone el modelo Prisma final. Conserva compatibilidad con Candidate,
Education, WorkExperience y Resume. Agrega las entidades LTI, relaciones,
cardinalidades, defaults e indices necesarios. Evita indices redundantes y explica
las decisiones principales.
```

Resultado:

- Se agrego `applications Application[]` a Candidate para conectar candidatos con
  posiciones mediante postulaciones.
- Se agregaron Company, Employee, Position, InterviewFlow, InterviewStep,
  InterviewType, Application e Interview.
- Se mantuvo `status` como `String` para respetar el ERD y evitar complejidad de
  enums en una entrega centrada en modelo/migracion.
- Se modelo `Position.interviewFlowId` como unico para respetar la relacion
  uno-a-uno indicada por el ERD entre Position e InterviewFlow.
- Se agregaron defaults en campos operativos:
  - Employee.isActive: `true`
  - Position.status: `draft`
  - Position.isVisible: `false`
  - Application.applicationDate: `now()`
  - Application.status: `submitted`
- Se agregaron indices para FKs y consultas esperables:
  - empleados activos por compania
  - posiciones por compania, estado/visibilidad y deadline
  - pasos por tipo de entrevista
  - postulaciones por candidato, posicion/estado y fecha
  - entrevistas por empleado/fecha y paso
- Se agregaron indices a FKs existentes de Education, WorkExperience y Resume.
- Se evitaron indices redundantes cuando ya existia un indice unico o compuesto
  con el mismo prefijo util.

## Prompt 4 - Crear migracion SQL reproducible

Prompt:

```text
Actua como staff software engineer. Genera una migracion SQL para PostgreSQL que
lleve el schema actual al modelo LTI propuesto. Usa nombres de tablas y columnas
compatibles con Prisma, crea constraints, claves foraneas, indices y checks simples
de integridad donde Prisma no los represente directamente.
```

Resultado:

- Se creo `backend/prisma/migrations/20260622010000_add_lti_data_model/migration.sql`.
- La migracion crea las tablas nuevas del flujo LTI.
- La migracion agrega constraints unicas para:
  - Company.name
  - Employee.email
  - Position.interviewFlowId
  - InterviewType.name
  - InterviewStep por flujo y orden
  - Application por posicion y candidato
  - Interview por postulacion y paso
- La migracion agrega foreign keys con `ON DELETE RESTRICT ON UPDATE CASCADE`.
- La migracion agrega checks no destructivos:
  - `Position_salary_range_check`
  - `Interview_score_check`
- La migracion agrega indices sobre las FKs existentes de Education,
  WorkExperience y Resume.
- La migracion parte del schema existente del repositorio y presupone que ya
  existen Candidate, Education, WorkExperience y Resume.

## Prompt 5 - Validar entrega

Prompt:

```text
Actua como staff software engineer. Valida que el schema Prisma sea correcto, que
la migracion este dentro de `backend/prisma`, que no haya cambios fuera del alcance
de entrega y que el fichero de prompts documente el proceso ejecutado.
```

Resultado:

- `prisma format` paso usando Prisma 5.13.0, que es la version del proyecto.
- `prisma validate` paso cargando las variables desde el `.env` de la raiz.
- `git diff --check` no reporto errores de whitespace.
- La migracion SQL se aplico correctamente en un contenedor temporal de
  PostgreSQL 16, creando antes las tablas base existentes que esta migracion
  presupone.
- `prisma generate` tambien se probo correctamente; como npm instalo dependencias
  locales para poder generarlo, se retiraron esos cambios de `package.json`,
  `package-lock.json` y `node_modules` para mantener el alcance de entrega.
- Cambios finales esperados:
  - `backend/prisma/schema.prisma`
  - `backend/prisma/migrations/20260622010000_add_lti_data_model/migration.sql`
  - `prompts/prompts-FV.md`
