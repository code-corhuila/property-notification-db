REVOKE notification_writer FROM notification_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA notification REVOKE ALL ON TABLES FROM notification_reader, notification_writer;
REVOKE ALL ON ALL TABLES IN SCHEMA notification FROM notification_reader, notification_writer;
REVOKE USAGE ON SCHEMA notification FROM notification_reader, notification_writer;
