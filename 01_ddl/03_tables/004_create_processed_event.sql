-- The eventId of every event consumed, written in the same transaction as the
-- delivery_log rows: a redelivery by the broker changes nothing.
CREATE TABLE notification.processed_event (
  event_id      UUID        PRIMARY KEY,
  event_type    TEXT        NOT NULL,
  processed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
