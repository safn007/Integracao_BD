-- ELT-01 · Preparar a fase ELT
-- Não recria tabelas, não carrega CSVs e não altera o DW da ETL em public.

CREATE SCHEMA IF NOT EXISTS raw;     -- Dados brutos.
CREATE SCHEMA IF NOT EXISTS stg;     -- Dados em limpeza e transformação.
CREATE SCHEMA IF NOT EXISTS dw_elt;  -- Modelo estrela obtido por ELT.

-- Mantém a extensão onde ela já estiver instalada.
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Conferência final: as três flags devem ser true e unaccent_em não nulo.
SELECT
    pg_catalog.to_regnamespace('raw') IS NOT NULL AS raw_ok,
    pg_catalog.to_regnamespace('stg') IS NOT NULL AS stg_ok,
    pg_catalog.to_regnamespace('dw_elt') IS NOT NULL AS dw_elt_ok,
    (
        SELECT n.nspname
        FROM pg_catalog.pg_extension AS e
        JOIN pg_catalog.pg_namespace AS n ON n.oid = e.extnamespace
        WHERE e.extname = 'unaccent'
    ) AS unaccent_em;
