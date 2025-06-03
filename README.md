# mktg-data-graph

*A governed "ledger" and Segment Data Graph integration for Ramsey Solutions’ marketing data.*
This repo contains all data‑contract definitions, dbt models, Segment Data Graph specs, Reverse ETL job configs, CI scripts, and helper tooling that turn raw clickstream & attribution events into marketer‑friendly, unified profiles.

---

## 1  Architecture at a Glance

```
Segment Sources → S3 Raw → Redshift (staging) ─ dbt ─┐
                                                    │
                                      user_profile_ledger_v1
                                                    │
                      (Reverse ETL) → Segment Unify/Data Graph → Braze, Mode, …
```

All schema and pipeline changes live *in code* here; CI/CD deploys them, keeping the warehouse, Data Graph, and downstream tools perfectly in sync.

---

## 2  Repo Layout

| Path                         | What lives here                                            |
| ---------------------------- | ---------------------------------------------------------- |
| `models/linked/`             | Redshift **views** exposed to Segment Data Graph           |
| `data_graph_collections.yml` | Declarative list of Data Graph collections & relationships |
| `jobs/`                      | Reverse ETL job JSON descriptors                           |
| `tests/schema.yml`           | dbt & dbt‑expectations column‑set tests                    |
| `Makefile`                   | One‑liners for bootstrap, lint, test, deploy               |
| `.github/workflows/`         | CI pipelines (schema drift, deploy)                        |
| `requirements.txt`           | Python + dbt dependencies                                  |
| `package.json`               | Node dev deps (spectral, segment‑cli)                      |

---

## 3  Prerequisites

### System CLIs

* **git**, **awscli v2**, **psql**, **jq**
  (macOS users: `brew install git awscli psql jq`)
* **Python 3.11**
  Use `pyenv` or `brew install python@3.11`.
* **Node ≥ 18**
  `brew install node@18` or fnm/nvm.
* *(Optional)* **direnv**, **Docker Desktop** for local parity with CI.

### Python packages (`requirements.txt` excerpt)

```text
dbt-core==1.8.1
dbt-redshift==1.8.1
dbt-expectations==0.10.3
sqlfluff==3.0.4
pre-commit==3.7.1
pyyaml==6.0.1
boto3==1.34.119
awscli==2.16.10
```

### Node dev deps (`package.json` excerpt)

```jsonc
{
  "devDependencies": {
    "@stoplight/spectral-cli": "6.11.0",
    "segment-cli": "0.0.20"
  }
}
```

---

## 4  First‑Time Setup

```bash
# clone + bootstrap
$ git clone git@github.com:ramsey-solutions/mktg-data-graph.git
$ cd mktg-data-graph
$ cp .env.sample .env   # add REDSHIFT_URL, SEGMENT_TOKEN, etc.
$ make bootstrap        # pip + npm installs, pre‑commit hooks
$ pre-commit install

# run modified dbt models + lint contracts locally
$ make test
```

> **Segment Dev space** : create one in the Segment UI → **Unify ▸ Spaces**, grab its Space ID & API token, then drop them in your `.env`.

---

## 5  Everyday Commands

| Task                                  | Command               |
| ------------------------------------- | --------------------- |
| Lint SQL & specs                      | `make lint`           |
| Build + test modified models          | `make test`           |
| Run all models                        | `dbt build`           |
| Deploy to Redshift prod               | `make deploy_dbt`     |
| Push Data Graph + Reverse ETL configs | `make deploy_segment` |
| Open dbt docs                         | `make docs`           |
| Quick Redshift shell                  | `make psql_prod`      |

---

## 6  Development Workflow

1. **Feature branch** → edit `models/`, `data_graph_collections.yml`, or `jobs/*.json`.
2. `make test` locally; fix any red dbt or spectral errors.
3. Push & open a PR.
   *GitHub Actions* will compile dbt, run schema‑drift tests, and lint YAML/JSON.
4. After review, merge to `main`.
   CI deploys dbt models to Redshift and applies Segment configs.
5. Verify in Segment Dev space → promote to Prod by updating environment vars.

---

## 7  CI/CD Overview

* **Drift Check Job** – fails PRs if column sets change in critical views.
* **Deploy Job** – runs after drift check passes; executes:

  1. `dbt run --target prod`
  2. `segment config apply` & `segment reverse-etl apply`
* Container image `ghcr.io/ramsey-solutions/mktg-data-graph-ci:latest` bundles Python 3.11, dbt‑redshift, Node 18, segment‑cli, spectral, awscli.

---

## 8  Environment Variables (`.env`)

| Variable           | Description                                                |
| ------------------ | ---------------------------------------------------------- |
| `REDSHIFT_URL`     | redshift+psql://… connection string                        |
| `AWS_REGION`       | e.g. `us-east-1`                                           |
| `SEGMENT_TOKEN`    | Personal Access Token with Config API & Reverse ETL scopes |
| `SEGMENT_SPACE_ID` | Dev or Prod space ID (e.g. `spc_dev_12345`)                |

---

## 9  Contributing

* Open issues for bugs or schema‑change proposals.
* Feature branches must pass `make test` *and* `make lint` before review.
* Use [Conventional Commits](https://www.conventionalcommits.org/) in commit messages; CI auto‑tags releases.

---

## 10  License

© 2025 Ramsey Solutions. Internal use only.
