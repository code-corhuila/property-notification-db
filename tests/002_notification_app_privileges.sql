-- notification_app, through notification_writer, reads, inserts and updates in
-- notification, and can neither delete nor change structure (migration-strategy.md).
-- The check of Annex J.10: it writes only in its own schema.
-- Everything runs in one transaction that is rolled back.
BEGIN;
SET LOCAL ROLE notification_app;

INSERT INTO notification.notification_preference (user_id, sms_enabled)
VALUES ('22222222-2222-4222-8222-222222222222', TRUE)
ON CONFLICT (user_id) DO UPDATE SET sms_enabled = EXCLUDED.sms_enabled, updated_at = now();
UPDATE notification.notification_preference SET push_enabled = FALSE, updated_at = now()
WHERE user_id = '22222222-2222-4222-8222-222222222222';
INSERT INTO notification.processed_event (event_id, event_type)
VALUES ('33333333-3333-4333-8333-333333333333', 'ReservaConfirmada');
INSERT INTO notification.delivery_log (user_id, source_event_type, source_event_id, channel)
VALUES ('22222222-2222-4222-8222-222222222222', 'ReservaConfirmada', '33333333-3333-4333-8333-333333333333', 'EMAIL');
UPDATE notification.delivery_log SET delivery_status = 'SENT', sent_at = now()
WHERE source_event_id = '33333333-3333-4333-8333-333333333333';
SELECT count(*) AS visible_templates FROM notification.message_template;

DO $$
BEGIN
  DELETE FROM notification.notification_preference;
  RAISE EXCEPTION 'notification_app could delete';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'notification_app cannot delete';
END
$$;

DO $$
BEGIN
  CREATE TABLE notification.not_allowed (id int);
  RAISE EXCEPTION 'notification_app could create a table';
EXCEPTION WHEN insufficient_privilege THEN
  RAISE NOTICE 'notification_app cannot change structure';
END
$$;

RESET ROLE;

-- Annex J.10: the schemas where notification_app can write.
DO $$
DECLARE
  schemas text;
BEGIN
  SELECT string_agg(DISTINCT n.nspname, ', ') INTO schemas
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
    AND n.nspname NOT LIKE 'pg\_%' AND n.nspname <> 'information_schema'
    AND has_schema_privilege('notification_app', n.nspname, 'USAGE')
    AND (has_table_privilege('notification_app', c.oid, 'INSERT')
         OR has_table_privilege('notification_app', c.oid, 'UPDATE')
         OR has_table_privilege('notification_app', c.oid, 'DELETE'));
  IF schemas IS DISTINCT FROM 'notification' THEN
    RAISE EXCEPTION 'notification_app writes in: %', schemas;
  END IF;
  RAISE NOTICE 'Annex J.10: notification_app writes only in notification';
END
$$;

ROLLBACK;
