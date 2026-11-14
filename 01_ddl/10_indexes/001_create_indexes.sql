-- Indexes of 06-data/models.md.
-- "the deliveries of a user":                         WHERE user_id = ?
CREATE INDEX idx_delivery_log_user_id ON notification.delivery_log (user_id);
