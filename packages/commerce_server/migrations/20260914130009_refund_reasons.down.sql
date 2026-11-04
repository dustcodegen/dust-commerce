-- Reverts only refund reasons after dependent refunds have been reverted.
DROP TRIGGER IF EXISTS refund_reasons_touch_updated_at ON refund_reasons;
DROP TABLE refund_reasons;
