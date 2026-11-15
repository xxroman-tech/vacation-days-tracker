\getenv app_password POSTGRES_APP_PASSWORD

BEGIN;
CREATE ROLE vacation_app WITH LOGIN PASSWORD :'app_password';
ALTER DATABASE vacation_days OWNER TO vacation_app;
COMMIT;
