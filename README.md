# property-notification-db

> notification bounded context: database (schema, roles and migrations)

Part of the **Pms_Property** distributed system, Grupo 2. Governance and
documentation live in [`property-docs`](https://github.com/code-corhuila/property-docs).

This repository owns the structure of the `notification` schema: its tables, its
roles and its migrations, versioned with **Liquibase**. It holds **no database
instance**: the single PostgreSQL 16 instance of each environment is defined in
`property-infra-postgres`, and every domain lives there in its own schema
(Annex J of the norm, ADR-008). `property-notification-api` reads and writes the
schema as `notification_app`; it never migrates it.

## Layout

```
changelog/changelog-master.yaml   single entry point of the pipeline
01_ddl/    structure  00_extensions .. 10_indexes (the number is the order of execution)
02_dml/    data       inserts, updates, deletes, upserts, patches
03_dcl/    access     roles, grants, row-level policies
04_tcl/    control    transaction blocks, manual recoveries, release tags
05_rollbacks/          mirror of every changeset that has a rollback file
tests/                 SQL checks run by the CI after the schema is applied
deploy/compose.yml     only the migration runner, notification-db-migrate
.github/workflows/     rebuilds the schema from empty on every pull request
```

## Rules

1. **The schema is `notification`.** Nothing lives in `public`, except the control
   tables of the runner: `databasechangelog_notification` and
   `databasechangeloglock_notification`, so that the `-db` repositories sharing the
   instance never collide (Annex J.6).
2. **Extensions and users belong to the instance.** `pgcrypto`, `btree_gist` and
   the user `notification_app` are created by the start-up script of
   `property-infra-postgres`. This repository creates the `NOLOGIN` roles
   `notification_reader` and `notification_writer` and grants `notification_writer` to
   `notification_app`.
3. **Tables are created without foreign keys** in `03_tables`; keys are added in
   `04_alter`, each one declaring what happens on delete, and every foreign key
   column is indexed in `10_indexes`.
4. **No foreign key to another domain.** `user_id` belongs to Identity: it is a
   plain identifier, verified by contract.
5. **Closed sets of values are a `CHECK`, never an `ENUM`** (the channels `EMAIL`,
   `SMS` and `PUSH`, the delivery states).
6. **Every changeset declares its rollback, and an applied changeset is never
   edited.** A correction is a new changeset.
7. **Seeds are idempotent** (`INSERT … ON CONFLICT … DO UPDATE`). Demo data, if
   any, uses the Liquibase context `dev`, which only the `develop` runner enables.

The SQL of every table is the one in `06-data/models.md` of `property-docs`.

**The seed of `message_template`** (`02_dml/00_inserts`, every environment): the 9 templates
of `09-microservices/services/08-notification/data-model.md` (DOC4), one per terminal event
(`ReservaConfirmada`, `ReservaCancelada`, `ReservaExpirada`) and channel. `subject` only for
`EMAIL`; Spanish bodies with the placeholders `{{nombre}}`, `{{reservaId}}`,
`{{fechaInicio}}`, `{{fechaFin}}` and `{{motivo}}`. SMS and PUSH are seeded although MVP 1
sends only e-mail (DEC-006). `tests/003_seed_message_templates.sql` checks them.

## Run it

From `property-infra-postgres`, with the repositories cloned side by side and the
instance up:

```bash
docker compose --env-file env/dev.env up -d --wait postgres
docker compose --env-file env/dev.env run --rm notification-db-migrate                    # apply
docker compose --env-file env/dev.env run --rm notification-db-migrate status --verbose   # what is pending
docker compose --env-file env/dev.env run --rm notification-db-migrate rollback-count 1   # undo the last one
```

## Verification

`.github/workflows/db-ci.yml` runs on every pull request into `develop` and `qa`.
It prepares an empty PostgreSQL 16 the way the instance is prepared (extensions
and `notification_app`), then: `update` → a second `update` that must apply nothing →
the SQL checks in `tests/` → `rollback-count 999`, which must leave neither the
schema nor the roles → `update` again.

## Branching

Three permanent branches. **None of them accepts a direct commit** — you enter through a child
branch and leave through a Pull Request.

```
develop  <--PR--  feat/... fix/... chore/...
qa       <--PR--  hu-<story>-qa
main     <--PR--  release/...  hotfix/...
```

Promotion happens **by re-application** (`git cherry-pick -x`), never by merging one permanent
branch into another: `merge develop -> qa` and `merge qa -> main` do not exist in this model.

`main` requires **1 approval from `ariel5253`**. On `develop` and `qa` the team sets its own review
rule.

Full policy: `00-governance/branching-policy.md` and `00-governance/git-conventions.md` in
`property-docs`.
