-- ELT-03 · Limpeza 1: tipos, texto e datas
-- Equivalente em SQL às etapas ETL-13 (chaves/tipos), ETL-14 (texto/encoding) e ETL-15 (datas).
-- Origem : raw.pessoas (33 colunas: 31 da fonte + ano_origem, arquivo_origem)
-- Destino: stg.pessoas_tipos_texto_datas (26 colunas: 33 - 8 derivadas de data + dias_ate_obito)
-- Execução via src/rodar_sql.py (sem BEGIN/COMMIT manuais no arquivo).

-- ----------------------------------------------------------------------------
-- 1. Pré-checagem da origem (existência de raw.pessoas e unicidade de id_pessoa)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_linhas BIGINT;
    v_distintos BIGINT;
BEGIN
    IF to_regclass('raw.pessoas') IS NULL THEN
        RAISE EXCEPTION 'Tabela raw.pessoas não existe. Execute antes a ELT-02.';
    END IF;

    SELECT COUNT(*), COUNT(DISTINCT NULLIF(BTRIM(id_pessoa), '')::INTEGER)
      INTO v_linhas, v_distintos
      FROM raw.pessoas;

    IF v_linhas = 0 THEN
        RAISE EXCEPTION 'Tabela raw.pessoas está vazia.';
    END IF;

    IF v_linhas <> v_distintos THEN
        RAISE EXCEPTION 'id_pessoa não é único em raw.pessoas (% linhas para % distintos).',
            v_linhas, v_distintos;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Recriação idempotente da tabela de staging
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS stg.pessoas_tipos_texto_datas CASCADE;

CREATE TABLE stg.pessoas_tipos_texto_datas (
    id_sinistro              INTEGER  NOT NULL,
    id_pessoa                INTEGER  NOT NULL,
    id_veiculo               INTEGER  NULL,
    cod_ibge                 INTEGER  NOT NULL,
    municipio                TEXT     NOT NULL,
    regiao_administrativa    TEXT     NOT NULL,
    tipo_via                 TEXT     NOT NULL,
    tipo_veiculo_vitima      TEXT     NULL,
    tipo_de_vitima           TEXT     NOT NULL,
    modo_transporte_vitima   TEXT     NULL,
    sexo                     TEXT     NOT NULL,
    idade                    SMALLINT NULL,
    gravidade_lesao          TEXT     NOT NULL,
    faixa_etaria_demografica TEXT     NOT NULL,
    faixa_etaria_legal       TEXT     NOT NULL,
    profissao                TEXT     NULL,
    grau_de_instrucao        TEXT     NULL,
    nacionalidade            TEXT     NULL,
    data_sinistro            DATE     NOT NULL,
    data_obito               DATE     NULL,
    local_obito              TEXT     NULL,
    local_via                TEXT     NULL,
    tempo_sinistro_obito     SMALLINT NULL,
    dias_ate_obito           SMALLINT NULL,
    ano_origem               SMALLINT NOT NULL,
    arquivo_origem           TEXT     NOT NULL
);

-- ----------------------------------------------------------------------------
-- 3. Carga com tipagem, limpeza de texto/encoding e conversão de datas
--    Nota: tratamento de 'NAO DISPONIVEL', nulos categóricos, flag_obito e
--    padronização/agrupamento de profissão ficam para a ELT-04.
-- ----------------------------------------------------------------------------
INSERT INTO stg.pessoas_tipos_texto_datas (
    id_sinistro,
    id_pessoa,
    id_veiculo,
    cod_ibge,
    municipio,
    regiao_administrativa,
    tipo_via,
    tipo_veiculo_vitima,
    tipo_de_vitima,
    modo_transporte_vitima,
    sexo,
    idade,
    gravidade_lesao,
    faixa_etaria_demografica,
    faixa_etaria_legal,
    profissao,
    grau_de_instrucao,
    nacionalidade,
    data_sinistro,
    data_obito,
    local_obito,
    local_via,
    tempo_sinistro_obito,
    dias_ate_obito,
    ano_origem,
    arquivo_origem
)
SELECT
    NULLIF(BTRIM(id_sinistro), '')::INTEGER AS id_sinistro,
    NULLIF(BTRIM(id_pessoa), '')::INTEGER   AS id_pessoa,
    NULLIF(BTRIM(id_veiculo), '')::INTEGER  AS id_veiculo,
    NULLIF(BTRIM(cod_ibge), '')::INTEGER    AS cod_ibge,

    -- Restaura o apóstrofo perdido nos 8 municípios paulistas (ETL-14)
    CASE norm.municipio_limpo
        WHEN 'SANTA BARBARA D OESTE' THEN 'SANTA BARBARA D''OESTE'
        WHEN 'PALMEIRA D OESTE'      THEN 'PALMEIRA D''OESTE'
        WHEN 'ESTRELA D OESTE'       THEN 'ESTRELA D''OESTE'
        WHEN 'APARECIDA D OESTE'     THEN 'APARECIDA D''OESTE'
        WHEN 'SANTA RITA D OESTE'    THEN 'SANTA RITA D''OESTE'
        WHEN 'SAO JOAO DO PAU D ALHO' THEN 'SAO JOAO DO PAU D''ALHO'
        WHEN 'SANTA CLARA D OESTE'   THEN 'SANTA CLARA D''OESTE'
        WHEN 'GUARANI D OESTE'       THEN 'GUARANI D''OESTE'
        ELSE norm.municipio_limpo
    END AS municipio,

    -- Mapeamento preventivo de acentos eventualmente corrompidos (ETL-14)
    CASE norm.regiao_limpa
        WHEN 'METROPOLITANA DE S O PAULO' THEN 'METROPOLITANA DE SÃO PAULO'
        WHEN 'METROPOLITANA DE SAO PAULO' THEN 'METROPOLITANA DE SÃO PAULO'
        WHEN 'S O JOSÉ DOS CAMPOS'        THEN 'SÃO JOSÉ DOS CAMPOS'
        WHEN 'S O JOS DOS CAMPOS'         THEN 'SÃO JOSÉ DOS CAMPOS'
        WHEN 'S O JOSÉ DO RIO PRETO'      THEN 'SÃO JOSÉ DO RIO PRETO'
        WHEN 'S O JOS DO RIO PRETO'       THEN 'SÃO JOSÉ DO RIO PRETO'
        WHEN 'RIBEIR O PRETO'             THEN 'RIBEIRÃO PRETO'
        WHEN 'MAR LIA'                    THEN 'MARÍLIA'
        WHEN 'ARA ATUBA'                  THEN 'ARAÇATUBA'
        ELSE norm.regiao_limpa
    END AS regiao_administrativa,

    NULLIF(BTRIM(REGEXP_REPLACE(r.tipo_via, '\s+', ' ', 'g')), '')                 AS tipo_via,
    NULLIF(BTRIM(REGEXP_REPLACE(r.tipo_veiculo_vitima, '\s+', ' ', 'g')), '')      AS tipo_veiculo_vitima,
    NULLIF(BTRIM(REGEXP_REPLACE(r.tipo_de_vitima, '\s+', ' ', 'g')), '')           AS tipo_de_vitima,
    NULLIF(BTRIM(REGEXP_REPLACE(r.modo_transporte_vitima, '\s+', ' ', 'g')), '')   AS modo_transporte_vitima,
    NULLIF(BTRIM(REGEXP_REPLACE(r.sexo, '\s+', ' ', 'g')), '')                     AS sexo,
    NULLIF(BTRIM(r.idade), '')::SMALLINT                                           AS idade,
    NULLIF(BTRIM(REGEXP_REPLACE(r.gravidade_lesao, '\s+', ' ', 'g')), '')          AS gravidade_lesao,
    NULLIF(BTRIM(REGEXP_REPLACE(r.faixa_etaria_demografica, '\s+', ' ', 'g')), '') AS faixa_etaria_demografica,
    NULLIF(BTRIM(REGEXP_REPLACE(r.faixa_etaria_legal, '\s+', ' ', 'g')), '')       AS faixa_etaria_legal,
    NULLIF(BTRIM(REGEXP_REPLACE(r.profissao, '\s+', ' ', 'g')), '')                AS profissao,

    CASE norm.instrucao_limpa
        WHEN 'M DIO'  THEN 'MÉDIO'
        WHEN 'B SICO' THEN 'BÁSICO'
        ELSE norm.instrucao_limpa
    END AS grau_de_instrucao,

    NULLIF(BTRIM(REGEXP_REPLACE(r.nacionalidade, '\s+', ' ', 'g')), '') AS nacionalidade,

    datas.data_sinistro_dt                                               AS data_sinistro,
    datas.data_obito_dt                                                  AS data_obito,
    NULLIF(BTRIM(REGEXP_REPLACE(r.local_obito, '\s+', ' ', 'g')), '')    AS local_obito,
    NULLIF(BTRIM(REGEXP_REPLACE(r.local_via, '\s+', ' ', 'g')), '')      AS local_via,
    NULLIF(BTRIM(r.tempo_sinistro_obito), '')::SMALLINT                  AS tempo_sinistro_obito,
    (datas.data_obito_dt - datas.data_sinistro_dt)::SMALLINT             AS dias_ate_obito,
    r.ano_origem                                                         AS ano_origem,
    BTRIM(r.arquivo_origem)                                              AS arquivo_origem
FROM raw.pessoas AS r
CROSS JOIN LATERAL (
    SELECT
        NULLIF(BTRIM(REGEXP_REPLACE(r.municipio, '\s+', ' ', 'g')), '')             AS municipio_limpo,
        NULLIF(BTRIM(REGEXP_REPLACE(r.regiao_administrativa, '\s+', ' ', 'g')), '') AS regiao_limpa,
        NULLIF(BTRIM(REGEXP_REPLACE(r.grau_de_instrucao, '\s+', ' ', 'g')), '')     AS instrucao_limpa
) AS norm
CROSS JOIN LATERAL (
    SELECT
        CASE
            WHEN NULLIF(BTRIM(r.data_sinistro), '') IS NULL THEN NULL
            WHEN BTRIM(r.data_sinistro) ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(BTRIM(r.data_sinistro), 'DD/MM/YYYY')
            WHEN BTRIM(r.data_sinistro) ~ '^\d{4}-\d{2}-\d{2}$' THEN BTRIM(r.data_sinistro)::DATE
            ELSE NULL
        END AS data_sinistro_dt,
        CASE
            WHEN NULLIF(BTRIM(r.data_obito), '') IS NULL THEN NULL
            WHEN BTRIM(r.data_obito) ~ '^\d{2}/\d{2}/\d{4}$' THEN TO_DATE(BTRIM(r.data_obito), 'DD/MM/YYYY')
            WHEN BTRIM(r.data_obito) ~ '^\d{4}-\d{2}-\d{2}$' THEN BTRIM(r.data_obito)::DATE
            ELSE NULL
        END AS data_obito_dt
) AS datas;

ALTER TABLE stg.pessoas_tipos_texto_datas
    ADD CONSTRAINT pk_stg_pessoas_tipos_texto_datas PRIMARY KEY (id_pessoa);

ANALYZE stg.pessoas_tipos_texto_datas;

COMMENT ON TABLE stg.pessoas_tipos_texto_datas IS
    'Staging 1 (ELT-03): tipos numéricos, limpeza de espaços/acentos/apóstrofos e datas convertidas (sem as 8 derivadas, com dias_ate_obito).';

-- ----------------------------------------------------------------------------
-- 4. Validações de integridade (falha a transação se qualquer regra divergir)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_linhas_raw           BIGINT;
    v_linhas_stg           BIGINT;
    v_colunas_stg          INT;
    v_cod_ibge_inconsist   BIGINT;
    v_mun_inconsist        BIGINT;
    v_datas_invalidas      BIGINT;
    v_derivadas_diverg     BIGINT;
    v_sinistro_fora_per    BIGINT;
    v_dias_divergentes     BIGINT;
    v_espacos_restantes    BIGINT;
    v_chars_invalidos      BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_linhas_raw FROM raw.pessoas;
    SELECT COUNT(*) INTO v_linhas_stg FROM stg.pessoas_tipos_texto_datas;

    IF v_linhas_stg <> v_linhas_raw OR v_linhas_stg <> 806977 THEN
        RAISE EXCEPTION 'Contagem inesperada: raw=%, stg=% (esperado 806977).',
            v_linhas_raw, v_linhas_stg;
    END IF;

    SELECT COUNT(*)
      INTO v_colunas_stg
      FROM information_schema.columns
     WHERE table_schema = 'stg'
       AND table_name   = 'pessoas_tipos_texto_datas';

    IF v_colunas_stg <> 26 THEN
        RAISE EXCEPTION 'Quantidade de colunas inesperada em stg.pessoas_tipos_texto_datas: % (esperado 26).',
            v_colunas_stg;
    END IF;

    -- Relação 1:1 cod_ibge <-> municipio e 1 região por cod_ibge
    SELECT COUNT(*)
      INTO v_cod_ibge_inconsist
      FROM (
          SELECT cod_ibge
            FROM stg.pessoas_tipos_texto_datas
           GROUP BY cod_ibge
          HAVING COUNT(DISTINCT municipio) > 1 OR COUNT(DISTINCT regiao_administrativa) > 1
      ) t;

    SELECT COUNT(*)
      INTO v_mun_inconsist
      FROM (
          SELECT municipio
            FROM stg.pessoas_tipos_texto_datas
           GROUP BY municipio
          HAVING COUNT(DISTINCT cod_ibge) > 1
      ) t;

    IF v_cod_ibge_inconsist > 0 OR v_mun_inconsist > 0 THEN
        RAISE EXCEPTION 'Inconsistência 1:1 cod_ibge <-> municipio (ibge=%, mun=%).',
            v_cod_ibge_inconsist, v_mun_inconsist;
    END IF;

    -- Conferência em passada única entre raw e stg: datas inválidas e 8 derivadas descartadas
    SELECT
        COUNT(*) FILTER (
            WHERE (NULLIF(BTRIM(r.data_sinistro), '') IS NOT NULL AND s.data_sinistro IS NULL)
               OR (NULLIF(BTRIM(r.data_obito), '')    IS NOT NULL AND s.data_obito    IS NULL)
        ),
        COUNT(*) FILTER (
            WHERE NULLIF(BTRIM(r.ano_sinistro), '')::SMALLINT IS DISTINCT FROM EXTRACT(YEAR  FROM s.data_sinistro)::SMALLINT
               OR NULLIF(BTRIM(r.mes_sinistro), '')::SMALLINT IS DISTINCT FROM EXTRACT(MONTH FROM s.data_sinistro)::SMALLINT
               OR NULLIF(BTRIM(r.dia_sinistro), '')::SMALLINT IS DISTINCT FROM EXTRACT(DAY   FROM s.data_sinistro)::SMALLINT
               OR NULLIF(BTRIM(r.ano_mes_sinistro), '')       IS DISTINCT FROM TO_CHAR(s.data_sinistro, 'YYYY/MM')
               OR NULLIF(BTRIM(r.ano_obito), '')::SMALLINT    IS DISTINCT FROM EXTRACT(YEAR  FROM s.data_obito)::SMALLINT
               OR NULLIF(BTRIM(r.mes_obito), '')::SMALLINT    IS DISTINCT FROM EXTRACT(MONTH FROM s.data_obito)::SMALLINT
               OR NULLIF(BTRIM(r.dia_obito), '')::SMALLINT    IS DISTINCT FROM EXTRACT(DAY   FROM s.data_obito)::SMALLINT
               OR NULLIF(BTRIM(r.ano_mes_obito), '')          IS DISTINCT FROM TO_CHAR(s.data_obito, 'YYYY/MM')
        )
      INTO v_datas_invalidas, v_derivadas_diverg
      FROM raw.pessoas AS r
      JOIN stg.pessoas_tipos_texto_datas AS s
        ON s.id_pessoa = NULLIF(BTRIM(r.id_pessoa), '')::INTEGER;

    -- Conferência em passada única sobre stg: período/intervalo de datas, dias_ate_obito e limpeza de texto
    SELECT
        COUNT(*) FILTER (
            WHERE data_sinistro < DATE '2021-01-01'
               OR data_sinistro > DATE '2023-12-31'
               OR dias_ate_obito < 0
               OR dias_ate_obito > 30
        ),
        COUNT(*) FILTER (
            WHERE dias_ate_obito IS DISTINCT FROM tempo_sinistro_obito
        ),
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                  FROM unnest(ARRAY[
                      municipio, regiao_administrativa, tipo_via, tipo_veiculo_vitima,
                      tipo_de_vitima, modo_transporte_vitima, sexo, gravidade_lesao,
                      faixa_etaria_demografica, faixa_etaria_legal, profissao,
                      grau_de_instrucao, nacionalidade, local_obito, local_via
                  ]) AS v(txt)
                 WHERE v.txt IS NOT NULL
                   AND (v.txt <> BTRIM(v.txt) OR v.txt ~ '\s{2,}')
            )
        ),
        COUNT(*) FILTER (
            WHERE strpos(
                municipio || regiao_administrativa || tipo_via || COALESCE(tipo_veiculo_vitima, '')
                || tipo_de_vitima || COALESCE(modo_transporte_vitima, '') || sexo || gravidade_lesao
                || faixa_etaria_demografica || faixa_etaria_legal || COALESCE(profissao, '')
                || COALESCE(grau_de_instrucao, '') || COALESCE(nacionalidade, '')
                || COALESCE(local_obito, '') || COALESCE(local_via, ''),
                chr(65533)
            ) > 0
        )
      INTO v_sinistro_fora_per, v_dias_divergentes, v_espacos_restantes, v_chars_invalidos
      FROM stg.pessoas_tipos_texto_datas;

    IF v_datas_invalidas > 0 OR v_sinistro_fora_per > 0 THEN
        RAISE EXCEPTION 'Problemas em datas (inválidas=%, fora_periodo_ou_intervalo=%).',
            v_datas_invalidas, v_sinistro_fora_per;
    END IF;

    IF v_derivadas_diverg > 0 OR v_dias_divergentes > 0 THEN
        RAISE EXCEPTION 'Divergência nas derivadas de data (derivadas=%, dias_ate_obito=%).',
            v_derivadas_diverg, v_dias_divergentes;
    END IF;

    IF v_espacos_restantes > 0 OR v_chars_invalidos > 0 THEN
        RAISE EXCEPTION 'Falha na limpeza de texto (espacos=%, chars_invalidos=%).',
            v_espacos_restantes, v_chars_invalidos;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 5. Consulta final de conferência (devolvida por rodar_sql())
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                                  AS linhas,
    COUNT(DISTINCT id_pessoa)                                                 AS id_pessoa_distintos,
    COUNT(DISTINCT id_sinistro)                                               AS id_sinistro_distintos,
    (
        SELECT COUNT(*)
          FROM information_schema.columns
         WHERE table_schema = 'stg'
           AND table_name   = 'pessoas_tipos_texto_datas'
    )                                                                         AS colunas,
    COUNT(DISTINCT cod_ibge)                                                  AS cod_ibge_distintos,
    COUNT(DISTINCT municipio)                                                 AS municipios_distintos,
    COUNT(DISTINCT regiao_administrativa)                                     AS regioes_distintas,
    COUNT(*) FILTER (WHERE municipio LIKE '%''%')                             AS linhas_municipio_com_apostrofo,
    COUNT(*) FILTER (WHERE data_obito IS NOT NULL)                            AS obitos,
    COUNT(*) FILTER (WHERE id_veiculo IS NULL)                                AS id_veiculo_nulos,
    COUNT(*) FILTER (WHERE idade IS NULL)                                     AS idade_nulos,
    COUNT(*) FILTER (WHERE nacionalidade LIKE '% ')                           AS nacionalidade_com_espaco_dir,
    ROUND(pg_total_relation_size('stg.pessoas_tipos_texto_datas') / 1024.0 / 1024, 1) AS tamanho_mb
FROM stg.pessoas_tipos_texto_datas;
