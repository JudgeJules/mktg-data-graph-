# Makefile – helper commands for mktg-data-graph

PYTHON := python3.11
PIP := \$(PYTHON) -m pip

## -------------------------------------------------

## Setup & Quality

## -------------------------------------------------

bootstrap:
\$(PIP) install --upgrade pip
\$(PIP) install -r requirements.txt
npm install

lint:
sqlfluff lint models
npm run lint

test:
dbt deps
dbt build --select state\:modified+

## -------------------------------------------------

## Deploy

## -------------------------------------------------

deploy\_dbt:
dbt run --profiles-dir ./.dbt --target prod
dbt docs generate

# Applies Data Graph collections + Reverse ETL jobs

# Requires SEGMENT\_TOKEN env var

.deploy\_segment\_base:
npm run deploy\:segment
npm run deploy\:reverse-etl

deploy\_segment: .deploy\_segment\_base

## -------------------------------------------------

## Docs & Utilities

## -------------------------------------------------

docs:
dbt docs serve --port 8080 --profiles-dir ./.dbt

psql\_prod:
psql "\$(REDSHIFT\_URL)"

## -------------------------------------------------

.PHONY: bootstrap lint test deploy\_dbt deploy\_segment docs psql\_prod
