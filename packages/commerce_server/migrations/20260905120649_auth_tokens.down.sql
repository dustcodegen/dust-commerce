-- Reverts only auth_tokens; SQLx orders dependency-safe downs.
DROP TABLE auth_tokens;
