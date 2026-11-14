-- The defaults HU-NOTIF-002 relies on, and the constraints that defend the schema.
-- Everything runs in one transaction that is rolled back.
BEGIN;

-- Scenario 1 of HU-NOTIF-002: a new row has e-mail and push on, SMS off.
INSERT INTO notification.notification_preference (user_id) VALUES ('22222222-2222-4222-8222-222222222222');
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM notification.notification_preference
                 WHERE user_id = '22222222-2222-4222-8222-222222222222'
                   AND email_enabled AND NOT sms_enabled AND push_enabled) THEN
    RAISE EXCEPTION 'the defaults are not e-mail and push on, SMS off';
  END IF;
  RAISE NOTICE 'defaults: e-mail and push on, SMS off';
END
$$;

-- A channel outside the closed set is rejected.
DO $$
BEGIN
  INSERT INTO notification.message_template (code, channel, body) VALUES ('X_FAX', 'FAX', 'x');
  RAISE EXCEPTION 'a channel FAX was accepted';
EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'chk_message_template_channel rejects FAX';
END
$$;

-- The same event never produces two deliveries on one channel.
INSERT INTO notification.delivery_log (user_id, source_event_type, source_event_id, channel)
VALUES ('22222222-2222-4222-8222-222222222222', 'ReservaConfirmada', '33333333-3333-4333-8333-333333333333', 'EMAIL');
DO $$
BEGIN
  INSERT INTO notification.delivery_log (user_id, source_event_type, source_event_id, channel)
  VALUES ('22222222-2222-4222-8222-222222222222', 'ReservaConfirmada', '33333333-3333-4333-8333-333333333333', 'EMAIL');
  RAISE EXCEPTION 'the same event was delivered twice on EMAIL';
EXCEPTION WHEN unique_violation THEN
  RAISE NOTICE 'uq_delivery_log_event_channel rejects a second EMAIL for the event';
END
$$;

-- Only the three Booking events that notify, and only the three delivery states.
DO $$
BEGIN
  INSERT INTO notification.delivery_log (user_id, source_event_type, source_event_id, channel)
  VALUES ('22222222-2222-4222-8222-222222222222', 'ReservaCreada', '44444444-4444-4444-8444-444444444444', 'EMAIL');
  RAISE EXCEPTION 'ReservaCreada was accepted as a source event';
EXCEPTION WHEN check_violation THEN
  RAISE NOTICE 'chk_delivery_log_source_event_type rejects ReservaCreada';
END
$$;

ROLLBACK;
