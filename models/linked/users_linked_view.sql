-- models/linked/users_linked_view.sql
-- -----------------------------------------------------------------------------
-- Linked VIEW exposed to Segment Data Graph as the **users** collection.
-- All fields listed in data_graph_collections.yml must appear here unchanged.
-- -----------------------------------------------------------------------------

{{ config(
    materialized='view',           -- keep it lightweight; rebuilt each run
    schema='linked',              -- separates linked views from core models
    tags=['linked', 'critical']   -- `critical` = schema drift test covers it
) }}

with src as (
    select
        user_id                             as id,            -- primary key
        lower(email)                        as email,
        created_at,
        current_timestamp                   as dbt_updated_at  -- lineage column
    from {{ ref('stg_users') }}                               -- staging model
)

select * from src;
