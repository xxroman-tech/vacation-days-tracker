# Vacation Days Tracker database

## Start PostgreSQL

The first start initializes PostgreSQL 18, creates the `vacation_days` database, and gives the `vacation_app` login ownership so Quarkus can create and migrate tables. The `postgres` administrator has a separate password. A named Docker volume preserves the database across container replacements and `docker compose down`.

If `.env` is missing, copy `.env.example` to `.env`, set `LAN_IP` to the Docker host's LAN IPv4 address, and fill both password fields with different random passwords. For example, run `openssl rand -hex 32` twice. Keep `.env` private. On macOS, `ipconfig getifaddr en0` shows the address if `en0` is your network interface.

With Docker running, start the database from this directory.

```sh
docker compose up -d --wait postgres
```

From a device on the same LAN, replace the example IP below with `LAN_IP` from `.env`. If you changed `POSTGRES_PORT`, use that port. Enter `POSTGRES_APP_PASSWORD` when prompted.

```sh
psql -h 192.168.1.10 -p 5432 -U vacation_app -d vacation_days -W
```

The port is bound to the LAN address in `.env`. If the host IP changes, update `LAN_IP` and rerun the startup command. If a connection from another device times out, check the host firewall and whether the devices' network allows peer connections. Changing the passwords in `.env` after initialization does not rotate passwords already stored in PostgreSQL.

## Database schema

On a fresh volume, PostgreSQL runs `postgres/schema.sql` after creating the application role. The setup creates four tables owned by `vacation_app`.

| DBML table | PostgreSQL table | ID assignment |
| --- | --- | --- |
| `User` | `users` | Database identity |
| `HolidayType` | `holiday_types` | Database identity |
| `UserHolidayBudget` | `user_holiday_budgets` | Database identity |
| `UserHolidays` | `user_holidays` | Assigned by the application |

For a volume initialized before the schema was added, apply it once if the four tables are absent.

```sh
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d vacation_days < postgres/schema.sql
```

## Start Quarkus and PostgreSQL

The Maven scaffold builds and runs Quarkus 3.40.1.1 on Java 27 in Docker. It includes Hibernate ORM, the PostgreSQL JDBC driver, and SmallRye Health. Quarkus uses `vacation_app` and connects to `jdbc:postgresql://postgres:5432/vacation_days` on `vacation-days-network`. Compose supplies the password from `.env`.

```sh
docker compose up -d --build --wait
```

From the Docker host or another device on the LAN, replace the example IP with `LAN_IP` from `.env`. The readiness endpoint includes a database check. Set `QUARKUS_PORT` in `.env` to change the published HTTP port.

```sh
curl --fail-with-body http://192.168.1.10:8080/q/health/ready
```

When you add entities, map them to the table names above. Hibernate is configured to validate mappings against the PostgreSQL schema.
