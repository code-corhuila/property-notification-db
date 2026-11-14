-- Audit log of every notification dispatched for ReservaConfirmada, ReservaCancelada and
-- ReservaExpirada. uq_delivery_log_event_channel: a redelivered event never sends twice.
CREATE TABLE notification.delivery_log (
  id                 UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID        NOT NULL,
  source_event_type  TEXT        NOT NULL
                     CONSTRAINT chk_delivery_log_source_event_type CHECK (source_event_type IN
                       ('ReservaConfirmada', 'ReservaCancelada', 'ReservaExpirada')),
  source_event_id    UUID        NOT NULL,
  channel            TEXT        NOT NULL
                     CONSTRAINT chk_delivery_log_channel CHECK (channel IN ('EMAIL', 'SMS', 'PUSH')),
  delivery_status    TEXT        NOT NULL DEFAULT 'PENDING'
                     CONSTRAINT chk_delivery_log_delivery_status
                     CHECK (delivery_status IN ('PENDING', 'SENT', 'FAILED')),
  sent_at            TIMESTAMPTZ,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_delivery_log_event_channel UNIQUE (source_event_id, channel)
);
