\getenv admin_name BOOTSTRAP_ADMIN_NAME
\getenv admin_email BOOTSTRAP_ADMIN_EMAIL
\getenv admin_password BOOTSTRAP_ADMIN_PASSWORD
\getenv issuer OIDC_ISSUER
\getenv client_id OIDC_CLIENT_ID
\getenv client_secret OIDC_CLIENT_SECRET
BEGIN; SET LOCAL statement_timeout = '10s';
-- Use Flare's settings/access lock order to serialize account and role changes.
SELECT pg_advisory_xact_lock(721150092);
SELECT pg_advisory_xact_lock(712347202);
CREATE TEMP TABLE flare_bootstrap_input ON COMMIT DROP AS
SELECT gen_random_uuid()::text AS id, btrim(:'admin_name') AS name, btrim(:'admin_email') AS email, :'admin_password'::text AS password,
       '{"enabled":true,"autoProvision":true,"requireEmailVerified":true,"enforceSso":true,"buttonText":"Sign in with Kanidm"}'::jsonb ||
       jsonb_build_object('issuer', :'issuer', 'clientId', :'client_id', 'clientSecret', :'client_secret') AS oidc;
DO $$ DECLARE
  admin_input flare_bootstrap_input := (SELECT input FROM flare_bootstrap_input AS input);
  config jsonb := (SELECT value FROM "Config" WHERE key = 'flare_config' FOR UPDATE);
  admin_role text := (SELECT id FROM "Role" WHERE "systemKey" = 'administrator' AND permissions @> ARRAY['administrator']);
  -- Match JavaScript's UTF-16 length: supplementary characters count twice.
  validation_error text := CASE
    WHEN admin_input.name !~ '\S' THEN 'BOOTSTRAP_ADMIN_NAME must not be empty or whitespace'
    WHEN char_length(admin_input.email) + regexp_count(admin_input.email, U&'[\+010000-\+10FFFF]') > 320 OR admin_input.email !~ '^[^\s@]+@[^\s@]+\.[^\s@]+$'
      THEN 'BOOTSTRAP_ADMIN_EMAIL must be a valid email address of at most 320 characters'
    WHEN char_length(admin_input.password) < 8 OR octet_length(admin_input.password) > 72
      THEN 'BOOTSTRAP_ADMIN_PASSWORD must contain at least 8 characters and at most 72 UTF-8 bytes (bcrypt limit)'
    WHEN admin_role IS NULL OR NOT EXISTS (SELECT 1 FROM "Role" WHERE "systemKey" = 'everyone')
      THEN 'Flare built-in roles are missing or the administrator role lacks administrator permission'
  END;
BEGIN
  IF config IS NULL THEN RETURN; END IF;
  IF NOT EXISTS (SELECT 1 FROM "User") THEN
    IF validation_error IS NOT NULL THEN RAISE EXCEPTION '%', validation_error; END IF;
    INSERT INTO "User" (id, name, email, password, "emailExempt", "updatedAt", "urlId", "uploadToken")
    VALUES (admin_input.id, admin_input.name, admin_input.email,
            public.crypt(admin_input.password, public.gen_salt('bf', 10)), true, now(),
            encode(public.gen_random_bytes(8), 'hex'), gen_random_uuid()::text);
    INSERT INTO "_RoleToUser" ("A", "B") VALUES (admin_role, admin_input.id);
    config := jsonb_set(jsonb_set(config, '{settings,general,setup}', jsonb_build_object('completed', true, 'completedAt', now())),
      '{settings,general,storage,provider}', '"local"'::jsonb);
  END IF;
  UPDATE "Config"
  SET value = jsonb_set(jsonb_set(config, '{settings,general,oidc}', admin_input.oidc),
                       '{settings,general,registrations,enabled}', 'false'::jsonb), "updatedAt" = now()
  WHERE key = 'flare_config' AND config #>> '{settings,general,setup,completed}' = 'true';
END $$;
SELECT count(*) FROM "Config" WHERE key = 'flare_config' AND value #>> '{settings,general,setup,completed}' = 'true';
COMMIT;
