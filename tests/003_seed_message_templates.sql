-- The seed of message_template (DOC4): 9 codes, 3 per channel, subject only for EMAIL, every
-- body with its placeholders and no other. Applying it again changes nothing (ON CONFLICT).
DO $$
DECLARE
  n int;
BEGIN
  SELECT count(*) INTO n FROM notification.message_template WHERE code LIKE 'RESERVATION\_%';
  IF n <> 9 THEN RAISE EXCEPTION 'expected 9 templates, found %', n; END IF;

  SELECT count(*) INTO n FROM notification.message_template
  WHERE (channel = 'EMAIL') <> (subject IS NOT NULL);
  IF n <> 0 THEN RAISE EXCEPTION '% templates break: subject only for EMAIL', n; END IF;

  SELECT count(*) INTO n FROM (SELECT channel FROM notification.message_template
                               GROUP BY channel HAVING count(*) = 3) c;
  IF n <> 3 THEN RAISE EXCEPTION 'expected 3 templates for each of EMAIL, SMS and PUSH'; END IF;

  SELECT count(*) INTO n FROM notification.message_template
  WHERE code = 'RESERVATION_CONFIRMED_EMAIL' AND body LIKE '%{{fechaInicio}}%{{fechaFin}}%'
     OR code = 'RESERVATION_CANCELLED_EMAIL' AND body LIKE '%{{motivo}}%'
     OR code = 'RESERVATION_EXPIRED_EMAIL'   AND body NOT LIKE '%{{fecha%' AND body NOT LIKE '%{{motivo}}%';
  IF n <> 3 THEN RAISE EXCEPTION 'a template of EMAIL has the wrong placeholders'; END IF;

  -- Placeholders other than the five of DOC4.
  SELECT count(*) INTO n FROM notification.message_template,
       regexp_matches(body, '\{\{([a-zA-Z]+)\}\}', 'g') AS m
  WHERE m[1] NOT IN ('nombre', 'reservaId', 'fechaInicio', 'fechaFin', 'motivo');
  IF n <> 0 THEN RAISE EXCEPTION '% unknown placeholders', n; END IF;

  RAISE NOTICE 'the 9 templates of DOC4 are seeded';
END
$$;
