-- Least privilege. The writer reads, inserts and updates: a preference or a delivery
-- is never deleted, and nobody but the runner changes structure (migration-strategy.md).
-- The reader is granted to nobody: this project has no cross-domain reads
-- (ADR-008, rule 5).
GRANT USAGE ON SCHEMA notification TO notification_reader, notification_writer;
GRANT SELECT ON ALL TABLES IN SCHEMA notification TO notification_reader;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA notification TO notification_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA notification GRANT SELECT ON TABLES TO notification_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA notification GRANT SELECT, INSERT, UPDATE ON TABLES TO notification_writer;

-- The service connects as notification_app, which holds the writer role (Annex J.7).
GRANT notification_writer TO notification_app;
