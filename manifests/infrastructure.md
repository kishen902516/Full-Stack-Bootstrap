# Infrastructure Manifest

This manifest contains the file structure and content for the infrastructure components.

## infrastructure/docker-compose.yaml

```yaml
version: '3.9'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: appdb
    ports: ['5432:5432']
    volumes: ['pgdata:/var/lib/postgresql/data']
volumes: { pgdata: {} }

```

---

## infrastructure/migrations/0001_init.sql

```plaintext
-- baseline schema
CREATE TABLE IF NOT EXISTS health ( id int PRIMARY KEY, status text NOT NULL );
INSERT INTO health (id, status) VALUES (1, 'ok') ON CONFLICT (id) DO NOTHING;

```

