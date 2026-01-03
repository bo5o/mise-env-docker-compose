# mise-env-docker-compose

A [mise](https://mise.jdx.dev/) plugin that automatically loads environment variables
from your Docker Compose configuration into your shell environment.

## Overview

This plugin resolves your Docker Compose configuration and extracts environment
variables defined in your services, making them available in your local development
environment. This is useful when you want to match the environment variables used in
your containerized services without manually duplicating them.

## Installation

Add this plugin to your mise configuration:

```toml
[plugins]
env-docker-compose = "https://github.com/bo5o/mise-env-docker-compose"

[env]
_.source = "env-docker-compose"
```

## Quick Start

Here's a minimal example to get started:

**docker-compose.yml:**

```yaml {docker-compose.yml}
---
services:
  app:
    image: node:20
    environment:
      DATABASE_URL: postgres://db:5432/myapp
      API_KEY: dev-key-123
```

**mise.toml:**

```toml {mise.toml}
[env]
_.env-docker-compose = {}
```

**Result:**

```sh
$ echo $DATABASE_URL
postgres://db:5432/myapp
$ echo $API_KEY
dev-key-123
```

The plugin automatically extracts all environment variables from your Docker Compose
services and makes them available in your shell.

## Configuration

The plugin supports several configuration options to control which environment variables
are loaded:

### Basic Usage

Load all environment variables from all services:

```toml
[env]
_.env-docker-compose = {}
```

### Filter by Services

Load environment variables only from specific services:

```toml
[env]
_.env-docker-compose = { services = ["web", "api"] }
```

### Filter by Variables

Load only specific environment variable names:

```toml
[env]
_.env-docker-compose = { variables = ["DATABASE_URL", "REDIS_URL"] }
```

### Host Replacement

Replace service references with localhost ports (useful for connecting to containerized
services from your host):

```toml
[env]
_.env-docker-compose = { replace_hosts = true }
```

When `replace_hosts` is enabled, environment variable values like `postgres:5432` will
be replaced with `localhost:5433` (using the published port from your Docker Compose
configuration).

### Include Build Arguments

Load build arguments from the `build.args` section of your services:

```toml
[env]
_.env-docker-compose = { include_build_args = true }
```

When `include_build_args` is enabled, the plugin will extract variables from the
`build.args` section in addition to the `environment` section. This is useful when you
need build-time variables available in your local development environment.

## How It Works

1. The plugin runs `docker compose config --format json` to get the parsed configuration
1. It extracts environment variables from the `environment` section of each service
1. If `include_build_args` is enabled, it also extracts variables from the `build.args`
   section
1. It optionally filters by service names and variable names
1. If `replace_hosts` is enabled, it replaces `service:port` references with
   `localhost:published_port`
1. The resulting environment variables are made available in your shell

## Example

Given a `docker-compose.yml`:

```yaml
---
services:
  web:
    image: myapp
    environment:
      DATABASE_URL: postgres:5432
      API_KEY: secret123
    ports:
      - "3000:3000"

  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
    ports:
      - "5433:5432"
```

With this configuration:

```toml
[env]
_.env-docker-compose = { services = ["web"], replace_hosts = true }
```

Your shell environment will have:

- `DATABASE_URL=localhost:5433` (replaced `postgres:5432` with `localhost:5433`)
- `API_KEY=secret123`

### Example with Build Arguments

Given a `docker-compose.yml` with build args:

```yaml
---
services:
  app:
    build:
      context: .
      args:
        NODE_VERSION: "20"
        BUILD_ENV: production
    environment:
      APP_PORT: "3000"
```

With this configuration:

```toml
[env]
_.env-docker-compose = { include_build_args = true }
```

Your shell environment will have:

- `NODE_VERSION=20`
- `BUILD_ENV=production`
- `APP_PORT=3000`

## Requirements

- [mise](https://mise.jdx.dev/) installed
- Docker and Docker Compose installed
- Valid Docker Compose configuation in your project
