-- ELT-07 · Tabela fato: dw_elt.fato_pessoa_sinistro
-- Equivalente em SQL às etapas ETL-18 (DDL da fato) e ETL-23 (montagem da fato).
-- Origem : stg.pessoas_nulos_profissao (ELT-04) + 8 dimensões em dw_elt (ELT-05 e ELT-06)
-- Destino: dw_elt.fato_pessoa_sinistro (806.977 linhas, 16 colunas)
--          Todas as referências são qualificadas com dw_elt./stg. para não tocar em public.
-- Execução via python -m src.rodar_sql sql/elt/05_fato.sql (sem BEGIN/COMMIT manuais).

-- ----------------------------------------------------------------------------
-- 1. Pré-checagem da origem e das oito dimensões em dw_elt
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_faltantes TEXT;
BEGIN
    IF to_regnamespace('dw_elt') IS NULL THEN
        RAISE EXCEPTION 'Schema dw_elt não existe. Execute antes a ELT-01.';
    END IF;

    IF to_regclass('stg.pessoas_nulos_profissao') IS NULL THEN
        RAISE EXCEPTION 'View stg.pessoas_nulos_profissao não existe. Execute antes a ELT-04.';
    END IF;

    SELECT STRING_AGG(tabela, ', ' ORDER BY tabela)
      INTO v_faltantes
      FROM (
          VALUES
              ('dw_elt.dim_tempo'),
              ('dw_elt.dim_gravidade'),
              ('dw_elt.dim_profissao'),
              ('dw_elt.dim_local_obito'),
              ('dw_elt.dim_perfil_vitima'),
              ('dw_elt.dim_transporte'),
              ('dw_elt.dim_localidade'),
              ('dw_elt.dim_via')
      ) AS req(tabela)
     WHERE to_regclass(req.tabela) IS NULL;

    IF v_faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'Dimensões ausentes em dw_elt (%). Execute antes a ELT-05 e a ELT-06.',
            v_faltantes;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Recriação idempotente da tabela fato (DDL da ETL-18 adaptado para dw_elt)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dw_elt.fato_pessoa_sinistro;

CREATE TABLE dw_elt.fato_pessoa_sinistro (
    id_pessoa        INTEGER  NOT NULL,
    id_sinistro      INTEGER  NOT NULL,
    id_veiculo       INTEGER  NULL,
    sk_data_sinistro INTEGER  NOT NULL,
    sk_data_obito    INTEGER  NOT NULL,
    sk_gravidade     INTEGER  NOT NULL,
    sk_perfil_vitima INTEGER  NOT NULL,
    sk_transporte    INTEGER  NOT NULL,
    sk_localidade    INTEGER  NOT NULL,
    sk_via           INTEGER  NOT NULL,
    sk_profissao     INTEGER  NOT NULL,
    sk_local_obito   INTEGER  NOT NULL,
    idade            SMALLINT NULL,
    dias_ate_obito   SMALLINT NULL,
    flag_obito       SMALLINT NOT NULL DEFAULT 0,
    qtd_pessoas      SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT chk_fato_idade          CHECK (idade IS NULL OR (idade BETWEEN 0 AND 120)),
    CONSTRAINT chk_fato_dias_ate_obito CHECK (dias_ate_obito IS NULL OR (dias_ate_obito BETWEEN 0 AND 30)),
    CONSTRAINT chk_fato_flag_obito     CHECK (flag_obito IN (0, 1)),
    CONSTRAINT chk_fato_qtd_pessoas    CHECK (qtd_pessoas = 1),
    CONSTRAINT chk_fato_obito_coerencia CHECK (
        (flag_obito = 0 AND sk_data_obito = -2 AND sk_local_obito = -2 AND dias_ate_obito IS NULL)
        OR (flag_obito = 1 AND sk_data_obito <> -2)
    )
);

-- ----------------------------------------------------------------------------
-- 3. Carga via INSERT ... SELECT e JOIN nas oito dimensões (9 joins)
--    As dimensões são pequenas e entram em memória; priorizar hash join evita
--    ordenações extensas sobre as 806.977 linhas.
--    LEFT JOIN garante falha explícita (NOT NULL) se alguma chave não existir.
-- ----------------------------------------------------------------------------
SET LOCAL enable_hashjoin = on;
SET LOCAL enable_hashagg  = on;
SET LOCAL enable_mergejoin = off;

INSERT INTO dw_elt.fato_pessoa_sinistro (
    id_pessoa,
    id_sinistro,
    id_veiculo,
    sk_data_sinistro,
    sk_data_obito,
    sk_gravidade,
    sk_perfil_vitima,
    sk_transporte,
    sk_localidade,
    sk_via,
    sk_profissao,
    sk_local_obito,
    idade,
    dias_ate_obito,
    flag_obito,
    qtd_pessoas
)
SELECT
    p.id_pessoa,
    p.id_sinistro,
    p.id_veiculo,
    ts.sk_tempo                                                   AS sk_data_sinistro,
    CASE
        WHEN p.data_obito IS NULL THEN -2
        ELSE tob.sk_tempo
    END                                                           AS sk_data_obito,
    g.sk_gravidade,
    pv.sk_perfil_vitima,
    tr.sk_transporte,
    loc.sk_localidade,
    v.sk_via,
    pr.sk_profissao,
    lo.sk_local_obito,
    p.idade,
    p.dias_ate_obito,
    CASE WHEN p.flag_obito THEN 1 ELSE 0 END::SMALLINT            AS flag_obito,
    1::SMALLINT                                                   AS qtd_pessoas
FROM stg.pessoas_nulos_profissao AS p
LEFT JOIN dw_elt.dim_tempo         AS ts
       ON ts.data = p.data_sinistro
LEFT JOIN dw_elt.dim_tempo         AS tob
       ON tob.data = p.data_obito
LEFT JOIN dw_elt.dim_gravidade     AS g
       ON g.gravidade_lesao = p.gravidade_lesao
LEFT JOIN dw_elt.dim_perfil_vitima AS pv
       ON pv.sexo                     = p.sexo
      AND pv.faixa_etaria_demografica = p.faixa_etaria_demografica
      AND pv.faixa_etaria_legal       = p.faixa_etaria_legal
      AND pv.nacionalidade            = p.nacionalidade
      AND pv.grau_de_instrucao        = p.grau_de_instrucao
LEFT JOIN dw_elt.dim_transporte    AS tr
       ON tr.tipo_de_vitima         = p.tipo_de_vitima
      AND tr.modo_transporte_vitima = p.modo_transporte_vitima
      AND tr.tipo_veiculo_vitima    = p.tipo_veiculo_vitima
LEFT JOIN dw_elt.dim_localidade    AS loc
       ON loc.cod_ibge = p.cod_ibge
LEFT JOIN dw_elt.dim_via           AS v
       ON v.tipo_via  = p.tipo_via
      AND v.local_via = p.local_via
LEFT JOIN dw_elt.dim_profissao     AS pr
       ON pr.profissao       = p.profissao
      AND pr.grupo_profissao = p.grupo_profissao
LEFT JOIN dw_elt.dim_local_obito   AS lo
       ON lo.local_obito = p.local_obito;

-- ----------------------------------------------------------------------------
-- 4. Chaves (PK/FKs), índices de apoio, estatísticas e comentários pós-carga
--    Declarar PK e FKs após o INSERT evita ~7,3 milhões de checagens de trigger
--    linha a linha durante a carga em lote e reduz drasticamente o tempo no banco.
-- ----------------------------------------------------------------------------
ALTER TABLE dw_elt.fato_pessoa_sinistro
    ADD CONSTRAINT pk_fato_pessoa_sinistro PRIMARY KEY (id_pessoa),
    ADD CONSTRAINT fk_fato_data_sinistro FOREIGN KEY (sk_data_sinistro) REFERENCES dw_elt.dim_tempo (sk_tempo),
    ADD CONSTRAINT fk_fato_data_obito    FOREIGN KEY (sk_data_obito)    REFERENCES dw_elt.dim_tempo (sk_tempo),
    ADD CONSTRAINT fk_fato_gravidade     FOREIGN KEY (sk_gravidade)     REFERENCES dw_elt.dim_gravidade (sk_gravidade),
    ADD CONSTRAINT fk_fato_perfil_vitima FOREIGN KEY (sk_perfil_vitima) REFERENCES dw_elt.dim_perfil_vitima (sk_perfil_vitima),
    ADD CONSTRAINT fk_fato_transporte    FOREIGN KEY (sk_transporte)    REFERENCES dw_elt.dim_transporte (sk_transporte),
    ADD CONSTRAINT fk_fato_localidade    FOREIGN KEY (sk_localidade)    REFERENCES dw_elt.dim_localidade (sk_localidade),
    ADD CONSTRAINT fk_fato_via           FOREIGN KEY (sk_via)           REFERENCES dw_elt.dim_via (sk_via),
    ADD CONSTRAINT fk_fato_profissao     FOREIGN KEY (sk_profissao)     REFERENCES dw_elt.dim_profissao (sk_profissao),
    ADD CONSTRAINT fk_fato_local_obito   FOREIGN KEY (sk_local_obito)   REFERENCES dw_elt.dim_local_obito (sk_local_obito);

CREATE INDEX idx_fato_id_sinistro      ON dw_elt.fato_pessoa_sinistro (id_sinistro);
CREATE INDEX idx_fato_sk_data_sinistro ON dw_elt.fato_pessoa_sinistro (sk_data_sinistro);
CREATE INDEX idx_fato_sk_data_obito    ON dw_elt.fato_pessoa_sinistro (sk_data_obito);
CREATE INDEX idx_fato_sk_gravidade     ON dw_elt.fato_pessoa_sinistro (sk_gravidade);
CREATE INDEX idx_fato_sk_perfil_vitima ON dw_elt.fato_pessoa_sinistro (sk_perfil_vitima);
CREATE INDEX idx_fato_sk_transporte    ON dw_elt.fato_pessoa_sinistro (sk_transporte);
CREATE INDEX idx_fato_sk_localidade    ON dw_elt.fato_pessoa_sinistro (sk_localidade);
CREATE INDEX idx_fato_sk_via           ON dw_elt.fato_pessoa_sinistro (sk_via);
CREATE INDEX idx_fato_sk_profissao     ON dw_elt.fato_pessoa_sinistro (sk_profissao);
CREATE INDEX idx_fato_sk_local_obito   ON dw_elt.fato_pessoa_sinistro (sk_local_obito);

ANALYZE dw_elt.fato_pessoa_sinistro;

COMMENT ON TABLE  dw_elt.fato_pessoa_sinistro IS 'Tabela fato central no grão 1 linha = 1 pessoa envolvida em 1 sinistro (SP, 2021–2023; 806.977 linhas esperadas).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.id_pessoa IS 'Chave primária natural e dimensão degenerada: identificador único da pessoa envolvida na fonte Infosiga.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.id_sinistro IS 'Dimensão degenerada: identificador do sinistro (use COUNT(DISTINCT id_sinistro) para contar ocorrências).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.id_veiculo IS 'Dimensão degenerada: identificador do veículo na fonte; nulo permitido (cerca de 21 por cento para pedestres e registros sem veículo).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_data_sinistro IS 'FK para dw_elt.dim_tempo representando a data do sinistro.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_data_obito IS 'FK para dw_elt.dim_tempo representando a data do óbito (-2 = NÃO SE APLICA quando não houve óbito).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_gravidade IS 'FK para dw_elt.dim_gravidade representando a gravidade da lesão.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_perfil_vitima IS 'FK para dw_elt.dim_perfil_vitima representando o perfil demográfico e educacional da pessoa.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_transporte IS 'FK para dw_elt.dim_transporte representando papel, modo e veículo da pessoa.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_localidade IS 'FK para dw_elt.dim_localidade representando o município e região administrativa do sinistro.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_via IS 'FK para dw_elt.dim_via representando o tipo e o local da via.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_profissao IS 'FK para dw_elt.dim_profissao representando a profissão e grupo profissional da pessoa.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.sk_local_obito IS 'FK para dw_elt.dim_local_obito representando o local do óbito (-2 = NÃO SE APLICA quando não houve óbito).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.idade IS 'Medida não aditiva: idade da pessoa em anos completos na data do sinistro (0 a 102; nulo quando não informada).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.dias_ate_obito IS 'Medida não aditiva: dias decorridos entre o sinistro e o óbito (0 a 30; nulo quando não houve óbito).';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.flag_obito IS 'Medida aditiva indicadora de óbito: 1 se houve óbito até 30 dias, 0 caso contrário.';
COMMENT ON COLUMN dw_elt.fato_pessoa_sinistro.qtd_pessoas IS 'Medida aditiva unitária (sempre 1) para contagem de pessoas envolvidas via SUM(qtd_pessoas).';

-- ----------------------------------------------------------------------------
-- 5. Validações pós-carga (falha a transação se qualquer regra divergir)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_linhas_stg     BIGINT;
    v_obitos_stg     BIGINT;
    v_linhas_fato    BIGINT;
    v_sinistros_fato BIGINT;
    v_obitos_fato    BIGINT;
    v_2021           BIGINT;
    v_2022           BIGINT;
    v_2023           BIGINT;
    v_dias_diverg    BIGINT;
BEGIN
    SELECT COUNT(*), COUNT(*) FILTER (WHERE flag_obito)
      INTO v_linhas_stg, v_obitos_stg
      FROM stg.pessoas_nulos_profissao;

    SELECT COUNT(*), COUNT(DISTINCT id_sinistro), COALESCE(SUM(flag_obito), 0)
      INTO v_linhas_fato, v_sinistros_fato, v_obitos_fato
      FROM dw_elt.fato_pessoa_sinistro;

    IF v_linhas_fato <> v_linhas_stg OR v_linhas_fato <> 806977 THEN
        RAISE EXCEPTION 'Contagem de linhas divergente: fato=%, stg=% (esperado 806977).',
            v_linhas_fato, v_linhas_stg;
    END IF;

    IF v_sinistros_fato <> 402695 THEN
        RAISE EXCEPTION 'Contagem de sinistros inesperada na fato: % (esperado 402695).',
            v_sinistros_fato;
    END IF;

    IF v_obitos_fato <> v_obitos_stg OR v_obitos_fato <> 15793 THEN
        RAISE EXCEPTION 'Contagem de óbitos divergente: fato=%, stg=% (esperado 15793).',
            v_obitos_fato, v_obitos_stg;
    END IF;

    SELECT
        COUNT(*) FILTER (WHERE ts.ano = 2021),
        COUNT(*) FILTER (WHERE ts.ano = 2022),
        COUNT(*) FILTER (WHERE ts.ano = 2023)
      INTO v_2021, v_2022, v_2023
      FROM dw_elt.fato_pessoa_sinistro AS f
      JOIN dw_elt.dim_tempo            AS ts
        ON ts.sk_tempo = f.sk_data_sinistro;

    IF v_2021 <> 260886 OR v_2022 <> 266128 OR v_2023 <> 279963 THEN
        RAISE EXCEPTION 'Totais anuais divergentes (2021=%, 2022=%, 2023=%).',
            v_2021, v_2022, v_2023;
    END IF;

    SELECT COUNT(*)
      INTO v_dias_diverg
      FROM dw_elt.fato_pessoa_sinistro AS f
      JOIN dw_elt.dim_tempo            AS ts  ON ts.sk_tempo  = f.sk_data_sinistro
      JOIN dw_elt.dim_tempo            AS tob ON tob.sk_tempo = f.sk_data_obito
     WHERE f.flag_obito = 1
       AND f.dias_ate_obito IS DISTINCT FROM (tob.data - ts.data)::SMALLINT;

    IF v_dias_diverg > 0 THEN
        RAISE EXCEPTION '% óbitos com dias_ate_obito divergente das datas em dw_elt.dim_tempo.',
            v_dias_diverg;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 6. Consulta final de conferência (devolvida por rodar_sql())
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                  AS linhas,
    COUNT(DISTINCT id_sinistro)                               AS sinistros,
    SUM(flag_obito)                                           AS obitos,
    COUNT(*) FILTER (WHERE id_veiculo IS NULL)                AS id_veiculo_nulos,
    COUNT(*) FILTER (WHERE sk_data_sinistro = -1)             AS sk_data_sinistro_ni,
    COUNT(*) FILTER (WHERE sk_data_obito = -2)                AS sk_data_obito_na,
    COUNT(*) FILTER (WHERE sk_local_obito = -1)               AS sk_local_obito_ni,
    COUNT(*) FILTER (WHERE sk_local_obito = -2)               AS sk_local_obito_na,
    COUNT(*) FILTER (WHERE sk_gravidade = -1)                 AS sk_gravidade_ni,
    COUNT(*) FILTER (WHERE sk_transporte = -1)                AS sk_transporte_ni,
    COUNT(*) FILTER (WHERE sk_profissao = -1)                 AS sk_profissao_ni,
    COUNT(*) FILTER (WHERE sk_perfil_vitima = -1)             AS sk_perfil_vitima_ni,
    COUNT(*) FILTER (WHERE sk_via = -1)                       AS sk_via_ni,
    COUNT(*) FILTER (WHERE sk_localidade = -1)                AS sk_localidade_ni,
    ROUND(pg_total_relation_size('dw_elt.fato_pessoa_sinistro') / 1024.0 / 1024, 1) AS tamanho_mb
FROM dw_elt.fato_pessoa_sinistro;
