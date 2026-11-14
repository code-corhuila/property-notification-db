-- The 9 templates of DOC4 (09-microservices/services/08-notification/data-model.md): one per
-- terminal event and channel. subject only for EMAIL; the bodies in Spanish, the language of
-- the guest. The consumer fills {{nombre}}, {{reservaId}}, {{fechaInicio}}, {{fechaFin}} and
-- {{motivo}}. SMS and PUSH are seeded although nothing is sent on them in MVP 1 (DEC-006).
-- Every environment needs them (migration-strategy.md). Idempotent (rule 7 of the README):
-- running it again leaves each code with these texts.
INSERT INTO notification.message_template (code, channel, subject, body) VALUES
  ('RESERVATION_CONFIRMED_EMAIL', 'EMAIL', 'Tu reserva está confirmada',
   'Hola {{nombre}}: tu reserva {{reservaId}} está confirmada, del {{fechaInicio}} al {{fechaFin}}. Puedes verla en Mis reservas. Gracias por reservar con PMS Property.'),
  ('RESERVATION_CONFIRMED_SMS', 'SMS', NULL,
   'PMS Property: tu reserva {{reservaId}} está confirmada, del {{fechaInicio}} al {{fechaFin}}.'),
  ('RESERVATION_CONFIRMED_PUSH', 'PUSH', NULL,
   'Reserva confirmada, del {{fechaInicio}} al {{fechaFin}}.'),
  ('RESERVATION_CANCELLED_EMAIL', 'EMAIL', 'Tu reserva fue cancelada',
   'Hola {{nombre}}: tu reserva {{reservaId}} fue cancelada: {{motivo}}. Si se había hecho un cobro, se reembolsó completo. Puedes intentarlo de nuevo cuando quieras.'),
  ('RESERVATION_CANCELLED_SMS', 'SMS', NULL,
   'PMS Property: tu reserva {{reservaId}} fue cancelada: {{motivo}}.'),
  ('RESERVATION_CANCELLED_PUSH', 'PUSH', NULL,
   'Reserva cancelada: {{motivo}}.'),
  ('RESERVATION_EXPIRED_EMAIL', 'EMAIL', 'Tu reserva expiró',
   'Hola {{nombre}}: tu reserva {{reservaId}} expiró porque el pago no se completó en 15 minutos. Las fechas quedaron libres y no se hizo ningún cobro. Puedes reservar de nuevo cuando quieras.'),
  ('RESERVATION_EXPIRED_SMS', 'SMS', NULL,
   'PMS Property: tu reserva {{reservaId}} expiró sin pago. Las fechas quedaron libres.'),
  ('RESERVATION_EXPIRED_PUSH', 'PUSH', NULL,
   'Reserva expirada: el pago no se completó a tiempo.')
ON CONFLICT (code) DO UPDATE
  SET channel = EXCLUDED.channel, subject = EXCLUDED.subject, body = EXCLUDED.body, updated_at = now()
  WHERE (message_template.channel, message_template.subject, message_template.body)
        IS DISTINCT FROM (EXCLUDED.channel, EXCLUDED.subject, EXCLUDED.body);
