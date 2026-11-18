-- ELT-05 · Dimensões A: dim_tempo, dim_gravidade, dim_profissao e dim_local_obito
-- Equivalente em SQL às etapas ETL-19 (tempo e gravidade) e ETL-22 (profissão e local do óbito).
-- Origem : stg.pessoas_nulos_profissao (ELT-04)
-- Destino: dw_elt.dim_tempo, dw_elt.dim_gravidade, dw_elt.dim_profissao, dw_elt.dim_local_obito
--          (mesmas colunas e regras do DDL da ETL-18; membros especiais -1 NÃO INFORMADO e -2 NÃO SE APLICA)
-- Execução via src/rodar_sql.py (sem BEGIN/COMMIT manuais no arquivo).

-- ----------------------------------------------------------------------------
-- 1. Pré-checagem da origem
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    IF to_regclass('stg.pessoas_nulos_profissao') IS NULL THEN
        RAISE EXCEPTION 'View stg.pessoas_nulos_profissao não existe. Execute antes a ELT-04.';
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Recriação idempotente das tabelas (DDL da ETL-18, no schema dw_elt)
--    CASCADE: se a fato da ELT-07 já existir, as chaves estrangeiras dela caem
--    e voltam quando a ELT-07 rodar de novo.
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dw_elt.dim_tempo CASCADE;
DROP TABLE IF EXISTS dw_elt.dim_gravidade CASCADE;
DROP TABLE IF EXISTS dw_elt.dim_profissao CASCADE;
DROP TABLE IF EXISTS dw_elt.dim_local_obito CASCADE;

CREATE TABLE dw_elt.dim_tempo (
    sk_tempo        INTEGER     NOT NULL,
    data            DATE        NULL,
    ano             SMALLINT    NULL,
    trimestre       SMALLINT    NULL,
    mes             SMALLINT    NULL,
    nome_mes        VARCHAR(20) NULL,
    dia             SMALLINT    NULL,
    ano_mes         VARCHAR(15) NULL,
    dia_semana      SMALLINT    NULL,
    nome_dia_semana VARCHAR(20) NULL,
    fim_de_semana   BOOLEAN     NULL,
    feriado         BOOLEAN     NULL,
    nome_feriado    VARCHAR(40) NULL,

    CONSTRAINT pk_dim_tempo PRIMARY KEY (sk_tempo),
    CONSTRAINT uq_dim_tempo_data UNIQUE (data),
    CONSTRAINT chk_dim_tempo_sk CHECK (sk_tempo IN (-1, -2) OR sk_tempo > 0),
    CONSTRAINT chk_dim_tempo_trimestre CHECK (trimestre IS NULL OR trimestre BETWEEN 1 AND 4),
    CONSTRAINT chk_dim_tempo_mes CHECK (mes IS NULL OR mes BETWEEN 1 AND 12),
    CONSTRAINT chk_dim_tempo_dia CHECK (dia IS NULL OR dia BETWEEN 1 AND 31),
    CONSTRAINT chk_dim_tempo_dia_semana CHECK (dia_semana IS NULL OR dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_dim_tempo_campos_validos CHECK (
        sk_tempo IN (-1, -2)
        OR (
            data IS NOT NULL AND ano IS NOT NULL AND trimestre IS NOT NULL AND mes IS NOT NULL
            AND nome_mes IS NOT NULL AND dia IS NOT NULL AND ano_mes IS NOT NULL
            AND dia_semana IS NOT NULL AND nome_dia_semana IS NOT NULL
            AND fim_de_semana IS NOT NULL AND feriado IS NOT NULL
        )
    )
);

CREATE TABLE dw_elt.dim_gravidade (
    sk_gravidade    INTEGER     NOT NULL,
    gravidade_lesao VARCHAR(20) NOT NULL,
    nivel_gravidade SMALLINT    NULL,

    CONSTRAINT pk_dim_gravidade PRIMARY KEY (sk_gravidade),
    CONSTRAINT uq_dim_gravidade_lesao UNIQUE (gravidade_lesao),
    CONSTRAINT chk_dim_gravidade_sk CHECK (sk_gravidade IN (-1, -2) OR sk_gravidade > 0),
    CONSTRAINT chk_dim_gravidade_nivel CHECK (sk_gravidade IN (-1, -2) OR (nivel_gravidade BETWEEN 0 AND 3))
);

CREATE TABLE dw_elt.dim_profissao (
    sk_profissao    INTEGER     NOT NULL,
    profissao       VARCHAR(80) NOT NULL,
    grupo_profissao VARCHAR(40) NOT NULL,

    CONSTRAINT pk_dim_profissao PRIMARY KEY (sk_profissao),
    CONSTRAINT uq_dim_profissao_comb UNIQUE (profissao, grupo_profissao),
    CONSTRAINT chk_dim_profissao_sk CHECK (sk_profissao IN (-1, -2) OR sk_profissao > 0)
);

CREATE TABLE dw_elt.dim_local_obito (
    sk_local_obito INTEGER     NOT NULL,
    local_obito    VARCHAR(30) NOT NULL,

    CONSTRAINT pk_dim_local_obito PRIMARY KEY (sk_local_obito),
    CONSTRAINT uq_dim_local_obito_nome UNIQUE (local_obito),
    CONSTRAINT chk_dim_local_obito_sk CHECK (sk_local_obito IN (-1, -2) OR sk_local_obito > 0)
);

-- ----------------------------------------------------------------------------
-- 3. dim_tempo: um dia por linha, de 01/01/2021 até a maior data da base.
--    Chave = data no formato AAAAMMDD. Dia da semana: 1 = segunda ... 7 = domingo.
--    Feriados: só nacionais (8 fixos + Sexta-feira Santa); Carnaval e Corpus Christi
--    são ponto facultativo. Consciência Negra só é nacional a partir de 2024 (Lei 14.759/2023).
-- ----------------------------------------------------------------------------
INSERT INTO dw_elt.dim_tempo (sk_tempo, nome_mes, ano_mes, nome_dia_semana)
VALUES (-1, 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_tempo
WITH limites AS (
    SELECT DATE '2021-01-01'                         AS inicio,
           GREATEST(MAX(data_sinistro), MAX(data_obito)) AS fim
    FROM stg.pessoas_nulos_profissao
),
anos AS (
    SELECT generate_series(EXTRACT(YEAR FROM inicio)::INT, EXTRACT(YEAR FROM fim)::INT) AS ano
    FROM limites
),
pascoa AS (
    -- Domingo de Páscoa (algoritmo de Meeus/Jones/Butcher; divisões inteiras)
    SELECT ano, make_date(ano, (h + l - 7 * m + 114) / 31, (h + l - 7 * m + 114) % 31 + 1) AS domingo
    FROM anos
    CROSS JOIN LATERAL (SELECT ano % 19 AS a, ano / 100 AS b, ano % 100 AS c) p1
    CROSS JOIN LATERAL (SELECT b / 4 AS d, b % 4 AS e, (b + 8) / 25 AS f) p2
    CROSS JOIN LATERAL (SELECT (b - f + 1) / 3 AS g) p3
    CROSS JOIN LATERAL (SELECT (19 * a + b - d - g + 15) % 30 AS h, c / 4 AS i, c % 4 AS k) p4
    CROSS JOIN LATERAL (SELECT (32 + 2 * e + 2 * i - h - k) % 7 AS l) p5
    CROSS JOIN LATERAL (SELECT (a + 11 * h + 22 * l) / 451 AS m) p6
),
feriados AS (
    SELECT make_date(anos.ano, f.mes, f.dia) AS data, f.nome
    FROM anos
    CROSS JOIN (VALUES
        (1, 1, 'Confraternização Universal'),
        (4, 21, 'Tiradentes'),
        (5, 1, 'Dia do Trabalho'),
        (9, 7, 'Independência do Brasil'),
        (10, 12, 'Nossa Senhora Aparecida'),
        (11, 2, 'Finados'),
        (11, 15, 'Proclamação da República'),
        (12, 25, 'Natal')
    ) AS f(mes, dia, nome)
    UNION ALL
    SELECT domingo - 2, 'Sexta-feira Santa' FROM pascoa
    UNION ALL
    SELECT make_date(ano, 11, 20), 'Dia Nacional de Zumbi e da Consciência Negra' FROM anos WHERE ano >= 2024
),
dias AS (
    SELECT generate_series(inicio, fim, INTERVAL '1 day')::DATE AS data FROM limites
)
SELECT
    TO_CHAR(d.data, 'YYYYMMDD')::INTEGER                       AS sk_tempo,
    d.data,
    EXTRACT(YEAR FROM d.data)::SMALLINT                        AS ano,
    EXTRACT(QUARTER FROM d.data)::SMALLINT                     AS trimestre,
    EXTRACT(MONTH FROM d.data)::SMALLINT                       AS mes,
    (ARRAY['JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO', 'JULHO',
           'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO'])[EXTRACT(MONTH FROM d.data)::INT] AS nome_mes,
    EXTRACT(DAY FROM d.data)::SMALLINT                         AS dia,
    TO_CHAR(d.data, 'YYYY-MM')                                 AS ano_mes,
    EXTRACT(ISODOW FROM d.data)::SMALLINT                      AS dia_semana,
    (ARRAY['SEGUNDA-FEIRA', 'TERÇA-FEIRA', 'QUARTA-FEIRA', 'QUINTA-FEIRA',
           'SEXTA-FEIRA', 'SÁBADO', 'DOMINGO'])[EXTRACT(ISODOW FROM d.data)::INT] AS nome_dia_semana,
    EXTRACT(ISODOW FROM d.data) IN (6, 7)                      AS fim_de_semana,
    f.nome IS NOT NULL                                         AS feriado,
    f.nome                                                     AS nome_feriado
FROM dias AS d
LEFT JOIN feriados AS f ON f.data = d.data
ORDER BY d.data;

-- ----------------------------------------------------------------------------
-- 4. dim_gravidade: chave na ordem do nível (1 = ILESO ... 4 = FATAL)
-- ----------------------------------------------------------------------------
INSERT INTO dw_elt.dim_gravidade (sk_gravidade, gravidade_lesao, nivel_gravidade)
VALUES (-1, 'NÃO INFORMADO', NULL),
       (-2, 'NÃO SE APLICA', NULL),
       (1, 'ILESO', 0),
       (2, 'LEVE', 1),
       (3, 'GRAVE', 2),
       (4, 'FATAL', 3);

-- ----------------------------------------------------------------------------
-- 5. dim_profissao: uma linha por profissão padronizada (ELT-04), com o grupo.
--    Ordem alfabética por código (COLLATE "C"), a mesma da ETL.
-- ----------------------------------------------------------------------------
INSERT INTO dw_elt.dim_profissao (sk_profissao, profissao, grupo_profissao)
VALUES (-1, 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_profissao (sk_profissao, profissao, grupo_profissao)
SELECT ROW_NUMBER() OVER (ORDER BY profissao COLLATE "C"), profissao, grupo_profissao
FROM (
    SELECT DISTINCT profissao, grupo_profissao
    FROM stg.pessoas_nulos_profissao
    WHERE profissao <> 'NÃO INFORMADO'
) AS p;

-- ----------------------------------------------------------------------------
-- 6. dim_local_obito: os locais reais, em ordem alfabética, + membros especiais
-- ----------------------------------------------------------------------------
INSERT INTO dw_elt.dim_local_obito (sk_local_obito, local_obito)
VALUES (-1, 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_local_obito (sk_local_obito, local_obito)
SELECT ROW_NUMBER() OVER (ORDER BY local_obito COLLATE "C"), local_obito
FROM (
    SELECT DISTINCT local_obito
    FROM stg.pessoas_nulos_profissao
    WHERE local_obito NOT IN ('NÃO INFORMADO', 'NÃO SE APLICA')
) AS l;

ANALYZE dw_elt.dim_tempo;
ANALYZE dw_elt.dim_gravidade;
ANALYZE dw_elt.dim_profissao;
ANALYZE dw_elt.dim_local_obito;

COMMENT ON TABLE dw_elt.dim_tempo IS 'Calendário (ELT-05): data do sinistro e do óbito; feriados nacionais.';
COMMENT ON TABLE dw_elt.dim_gravidade IS 'Gravidade da lesão (ELT-05), com nível de 0 (ileso) a 3 (fatal).';
COMMENT ON TABLE dw_elt.dim_profissao IS 'Profissão padronizada e grupo (ELT-05).';
COMMENT ON TABLE dw_elt.dim_local_obito IS 'Local do óbito (ELT-05).';

-- ----------------------------------------------------------------------------
-- 7. Validações (falha a transação se qualquer regra divergir)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_dias_esperados   INT;
    v_dias             INT;
    v_feriados_errados INT;
    v_gravidade_nova   INT;
    v_local_novo       INT;
    v_sem_chave        BIGINT;
BEGIN
    -- calendário sem buracos
    SELECT (GREATEST(MAX(data_sinistro), MAX(data_obito)) - DATE '2021-01-01') + 1
      INTO v_dias_esperados FROM stg.pessoas_nulos_profissao;
    SELECT COUNT(*) INTO v_dias FROM dw_elt.dim_tempo WHERE sk_tempo > 0;
    IF v_dias <> v_dias_esperados THEN
        RAISE EXCEPTION 'dim_tempo com % dias (esperado %).', v_dias, v_dias_esperados;
    END IF;

    -- 9 feriados nacionais por ano completo (2021 a 2023)
    SELECT COUNT(*) INTO v_feriados_errados
      FROM (SELECT ano FROM dw_elt.dim_tempo WHERE feriado AND ano BETWEEN 2021 AND 2023
             GROUP BY ano HAVING COUNT(*) <> 9) t;
    IF v_feriados_errados > 0 THEN
        RAISE EXCEPTION '% anos com quantidade de feriados diferente de 9.', v_feriados_errados;
    END IF;

    -- só valores conhecidos (nada de linha de lixo nas dimensões)
    SELECT COUNT(DISTINCT gravidade_lesao) INTO v_gravidade_nova
      FROM stg.pessoas_nulos_profissao
     WHERE gravidade_lesao NOT IN ('ILESO', 'LEVE', 'GRAVE', 'FATAL', 'NÃO INFORMADO');
    SELECT COUNT(*) INTO v_local_novo
      FROM dw_elt.dim_local_obito
     WHERE sk_local_obito > 0 AND local_obito NOT IN ('ESTABELECIMENTO DE SAUDE', 'OUTROS', 'VIA');
    IF v_gravidade_nova > 0 OR v_local_novo > 0 THEN
        RAISE EXCEPTION 'Valor novo na origem (gravidade=%, local do óbito=%).', v_gravidade_nova, v_local_novo;
    END IF;

    -- toda pessoa acha chave nas 4 dimensões (datas, gravidade, profissão e local do óbito)
    SELECT COUNT(*) FILTER (
               WHERE ts.sk_tempo IS NULL
                  OR (p.data_obito IS NOT NULL AND tob.sk_tempo IS NULL)
                  OR g.sk_gravidade IS NULL
                  OR pr.sk_profissao IS NULL
                  OR lo.sk_local_obito IS NULL)
      INTO v_sem_chave
      FROM stg.pessoas_nulos_profissao AS p
      LEFT JOIN dw_elt.dim_tempo       AS ts  ON ts.data = p.data_sinistro
      LEFT JOIN dw_elt.dim_tempo       AS tob ON tob.data = p.data_obito
      LEFT JOIN dw_elt.dim_gravidade   AS g   ON g.gravidade_lesao = p.gravidade_lesao
      LEFT JOIN dw_elt.dim_profissao   AS pr  ON pr.profissao = p.profissao
      LEFT JOIN dw_elt.dim_local_obito AS lo  ON lo.local_obito = p.local_obito;
    IF v_sem_chave > 0 THEN
        RAISE EXCEPTION '% pessoas sem chave em alguma dimensão A.', v_sem_chave;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 8. Consulta final de conferência (devolvida por rodar_sql())
-- ----------------------------------------------------------------------------
SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas, COUNT(*) FILTER (WHERE sk_tempo > 0) AS linhas_reais,
       MIN(data)::TEXT || ' a ' || MAX(data)::TEXT AS detalhe
  FROM dw_elt.dim_tempo
UNION ALL
SELECT 'dim_tempo (feriados)', COUNT(*), COUNT(*), STRING_AGG(DISTINCT ano::TEXT, ', ')
  FROM dw_elt.dim_tempo WHERE feriado
UNION ALL
SELECT 'dim_gravidade', COUNT(*), COUNT(*) FILTER (WHERE sk_gravidade > 0),
       STRING_AGG(gravidade_lesao, ', ' ORDER BY sk_gravidade) FILTER (WHERE sk_gravidade > 0)
  FROM dw_elt.dim_gravidade
UNION ALL
SELECT 'dim_profissao', COUNT(*), COUNT(*) FILTER (WHERE sk_profissao > 0),
       COUNT(DISTINCT grupo_profissao) FILTER (WHERE sk_profissao > 0)::TEXT || ' grupos'
  FROM dw_elt.dim_profissao
UNION ALL
SELECT 'dim_local_obito', COUNT(*), COUNT(*) FILTER (WHERE sk_local_obito > 0),
       STRING_AGG(local_obito, ', ' ORDER BY sk_local_obito) FILTER (WHERE sk_local_obito > 0)
  FROM dw_elt.dim_local_obito;
