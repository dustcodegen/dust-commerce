-- Reverts only the email-verification table and its owned trigger.
DROP TRIGGER IF EXISTS email_verifications_touch_updated_at ON email_verifications;
DROP TABLE email_verifications;
