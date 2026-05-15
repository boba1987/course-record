# Course Record (parent repo)

This repository groups the **Course Record** admin stack as [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules): a Spring Boot API and a Next.js admin UI. It adds **Docker Compose** (MySQL + API) and a **Makefile** so you can run the full dev loop from one folder.

| Part | Upstream repository |
|------|---------------------|
| Backend | [boba1987/course-record-backend](https://github.com/boba1987/course-record-backend) |
| Frontend | [boba1987/course-record-frontend](https://github.com/boba1987/course-record-frontend) |

---

## Prerequisites

- **Git** with submodule support  
- **Docker** and **Docker Compose** v2 (`docker compose`)  
- **GNU Make**, **curl**  
- **Node.js** and **npm** (frontend runs on the host)  
- **JDK 17** and **Maven** only if you use `make dev-local` / `make backend` instead of Docker  

---

## Clone

```bash
git clone --recurse-submodules git@github.com:boba1987/course-record.git
cd course-record
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

Same as **`make init`**.

---

## Docker environment (`.env`)

Secrets and passwords for Compose are **not** stored in `docker-compose.yml`. Copy the template once:

```bash
cp .env.example .env
```

Edit **`.env`** with your own values (never commit `.env`). `docker compose` loads it for variable substitution when you run **`make docker-up`** or **`make dev`**. The Makefile refuses to start Compose if `.env` is missing.

---

## Submodules and “latest”

The parent repo **records a specific commit** for each submodule. Cloning or running **`make init`** checks out those commits; it does **not** automatically follow new commits on GitHub.

To **pull the latest `main` inside each submodule** and fast-forward your working tree to match the remotes:

```bash
make update
```

That runs `git submodule update --remote --merge` (with `branch = main` set in `.gitmodules`). Afterward, **`git status`** in this repo may show the submodule paths as changed. **Commit that change in the parent repo** when you want everyone else to pick up the new submodule revisions.

Resolve any merge conflicts inside the submodule before committing the parent.

---

## Frontend configuration

In `course-record-frontend`, copy the example env file and set the API base URL (no trailing slash):

```bash
cp course-record-frontend/.env.local.example course-record-frontend/.env.local
```

For the default Docker backend on your machine, use:

`NEXT_PUBLIC_API_BASE_URL=http://localhost:8080/course-record`

Details: [course-record-frontend README](https://github.com/boba1987/course-record-frontend/blob/main/README.md).

---

## Makefile targets

| Target | Description |
|--------|-------------|
| **`make help`** | Print targets |
| **`make init`** | Initialize and sync submodules to the commits pinned by this repo |
| **`make update`** | Fetch remotes and update each submodule to the latest **`main`** |
| **`make dev`** | Build and start MySQL + API in Docker, wait until the OpenAPI URL responds, then start Next.js (`npm run dev`). **Ctrl+C** stops only the frontend; run **`make docker-down`** to stop containers |
| **`make prod`** | Same as **`make dev`**, then production **`next build`** (`NODE_ENV=production`) and **`next start`** on port **3000** |
| **`make dev-local`** | Run the backend with Maven and the frontend with npm in parallel (requires local MySQL and `course-record-backend` config as in the backend README) |
| **`make docker-up`** / **`make docker-down`** | Start or stop the Compose stack |
| **`make wait-backend`** | Block until `BACKEND_READY_URL` returns HTTP 200 (default: OpenAPI JSON) |
| **`make backend`** | `mvn spring-boot:run` inside the backend submodule |
| **`make frontend`** | `npm run dev` inside the frontend submodule (runs **`npm ci`** when `node_modules` is missing) |
| **`make frontend-build`** | Production **`next build`** in the frontend submodule |
| **`make frontend-start`** | **`next start`** (run **`make frontend-build`** first) |
| **`make install-frontend`** | **`npm ci`** in the frontend submodule |

Override the readiness check if needed:

```bash
make dev BACKEND_READY_URL=http://127.0.0.1:8080/course-record/v3/api-docs
```

---

## Docker notes

- Compose file: **`docker-compose.yml`**. Credentials and JWT/admin secrets come from **`.env`** (see **`.env.example`**).
- MySQL data persists in the **`mysql_data`** volume until you remove it (for example `docker compose down -v`).
- The MySQL service is **not** published on the host port `3306`; only the backend container connects to it on the Compose network.

---

## Layout

```
course-record/
├── Makefile
├── docker-compose.yml
├── .env.example
├── .dockerignore
├── .gitmodules
├── course-record-backend/    # submodule (includes Dockerfile)
└── course-record-frontend/   # submodule
```

For deeper API and UI documentation, see the README files in the two linked repositories.
