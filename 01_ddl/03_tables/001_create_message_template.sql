-- The texts the consumer of tanda 3 sends, one per code and channel (06-data/models.md).
-- Its initial rows are a seed every environment needs; they are not written yet.
CREATE TABLE notification.message_template (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code        TEXT        NOT NULL,
  channel     TEXT        NOT NULL
              CONSTRAINT chk_message_template_channel CHECK (channel IN ('EMAIL', 'SMS', 'PUSH')),
  subject     TEXT,
  body        TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_message_template_code UNIQUE (code)
);
