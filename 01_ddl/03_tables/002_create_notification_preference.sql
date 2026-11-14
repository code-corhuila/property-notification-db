-- The channels each user accepts: GET and PATCH /preferencias (E-16, E-17). A user with
-- no row has the defaults; the row is created the first time the user changes one.
-- user_id belongs to Identity: referenced by id, no foreign key (ADR-008, rule 3).
CREATE TABLE notification.notification_preference (
  user_id        UUID        PRIMARY KEY,
  email_enabled  BOOLEAN     NOT NULL DEFAULT TRUE,
  sms_enabled    BOOLEAN     NOT NULL DEFAULT FALSE,
  push_enabled   BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
