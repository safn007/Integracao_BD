-- ELT-06 · Dimensões B (issue #60)
-- Equivalente às dimensões das etapas ETL-20 e ETL-21, com o DDL da ETL-18.
-- Entrada: view stg.pessoas_nulos_profissao (ELT-04).
-- Saída: quatro dimensões em dw_elt. Não escreve em raw, stg ou public.
-- Execute via python -m src.rodar_sql sql/elt/04_dims_b.sql.
-- O executor controla a transação. Não usar BEGIN/COMMIT manuais.

-- 1. Pré-checagem e combinações distintas da origem
DO $$
BEGIN
    IF to_regclass('stg.pessoas_nulos_profissao') IS NULL THEN
        RAISE EXCEPTION 'View stg.pessoas_nulos_profissao não existe. Execute antes a ELT-04.';
    END IF;
    IF to_regnamespace('dw_elt') IS NULL THEN
        RAISE EXCEPTION 'Schema dw_elt não existe. Execute antes a ELT-01.';
    END IF;
END $$;

-- Versão 2: agrega uma dimensão por vez para evitar a ordenação conjunta
-- de todas as colunas da view. Cada agrupamento lê apenas sua chave natural.
-- Preferimos hash para os grupos pequenos e para juntar o mapa de profissões
-- da view. As configurações valem só até o fim desta transação.
-- Em sessões com memória muito baixa, usamos pelo menos 1 MB para
-- reduzir o risco de gravar arquivos de ordenação ou de hash em disco.
DO $$
BEGIN
    IF pg_size_bytes(current_setting('work_mem')) < 1048576 THEN
        PERFORM set_config('work_mem', '1MB', true);
    END IF;
END $$;

SET LOCAL enable_hashagg = on;
SET LOCAL enable_hashjoin = on;
SET LOCAL enable_sort = off;
SET LOCAL enable_mergejoin = off;

CREATE TEMP TABLE elt06_combinacoes (
    tabela                  TEXT NOT NULL,
    sexo                    TEXT,
    faixa_etaria_demografica TEXT,
    faixa_etaria_legal      TEXT,
    nacionalidade           TEXT,
    grau_de_instrucao       TEXT,
    tipo_de_vitima          TEXT,
    modo_transporte_vitima  TEXT,
    tipo_veiculo_vitima     TEXT,
    cod_ibge                INTEGER,
    municipio               TEXT,
    regiao_administrativa   TEXT,
    tipo_via                TEXT,
    local_via               TEXT,
    pessoas                 BIGINT NOT NULL
) ON COMMIT DROP;

-- O COUNT(*) de cada grupo guarda a quantidade de pessoas para a conferência.
-- Não gravamos uma cópia da view. Só as combinações distintas ficam na temporária.
INSERT INTO pg_temp.elt06_combinacoes (tabela, sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao, pessoas)
SELECT 'dim_perfil_vitima', sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao, COUNT(*)
FROM stg.pessoas_nulos_profissao
GROUP BY sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao;

INSERT INTO pg_temp.elt06_combinacoes (tabela, tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima, pessoas)
SELECT 'dim_transporte', tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima, COUNT(*)
FROM stg.pessoas_nulos_profissao
GROUP BY tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima;

INSERT INTO pg_temp.elt06_combinacoes (tabela, cod_ibge, municipio, regiao_administrativa, pessoas)
SELECT 'dim_localidade', cod_ibge, municipio, regiao_administrativa, COUNT(*)
FROM stg.pessoas_nulos_profissao
GROUP BY cod_ibge, municipio, regiao_administrativa;

INSERT INTO pg_temp.elt06_combinacoes (tabela, tipo_via, local_via, pessoas)
SELECT 'dim_via', tipo_via, local_via, COUNT(*)
FROM stg.pessoas_nulos_profissao
GROUP BY tipo_via, local_via;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_temp.elt06_combinacoes) THEN
        RAISE EXCEPTION 'A view da ELT-04 está vazia. Confira a carga e as etapas de staging.';
    END IF;

    -- Campos categóricos chegam tratados pela ELT-04. Nulo em cod_ibge na
    -- origem é erro: só os dois membros especiais de localidade têm IBGE nulo.
    IF EXISTS (
        SELECT 1 FROM pg_temp.elt06_combinacoes
        WHERE CASE tabela
            WHEN 'dim_perfil_vitima' THEN
                num_nulls(sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao) > 0
            WHEN 'dim_transporte' THEN num_nulls(tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima) > 0
            WHEN 'dim_localidade' THEN num_nulls(cod_ibge, municipio, regiao_administrativa) > 0
            WHEN 'dim_via' THEN num_nulls(tipo_via, local_via) > 0
        END
    ) THEN
        RAISE EXCEPTION 'Há campos obrigatórios nulos na origem das dimensões B. Confira a ELT-03 e a ELT-04.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_temp.elt06_combinacoes
        WHERE tabela = 'dim_localidade'
        GROUP BY cod_ibge
        HAVING COUNT(*) > 1
    ) OR EXISTS (
        SELECT 1 FROM pg_temp.elt06_combinacoes
        WHERE tabela = 'dim_localidade'
        GROUP BY municipio
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'Localidade inconsistente: cada município deve ter um código IBGE e cada código uma única combinação de município e região.';
    END IF;
END $$;

-- 2. Recriação das quatro tabelas, com colunas, tipos e restrições da ETL-18
-- Sem CASCADE: se a fato da ELT-07 já referenciar estas dimensões, o PostgreSQL
-- bloqueia a recriação, em vez de remover as suas chaves estrangeiras.
DROP TABLE IF EXISTS dw_elt.dim_perfil_vitima;
DROP TABLE IF EXISTS dw_elt.dim_transporte;
DROP TABLE IF EXISTS dw_elt.dim_localidade;
DROP TABLE IF EXISTS dw_elt.dim_via;

CREATE TABLE dw_elt.dim_perfil_vitima (
    sk_perfil_vitima         INTEGER     NOT NULL,
    sexo                     VARCHAR(20) NOT NULL,
    faixa_etaria_demografica VARCHAR(20) NOT NULL,
    faixa_etaria_legal       VARCHAR(20) NOT NULL,
    nacionalidade            VARCHAR(40) NOT NULL,
    grau_de_instrucao        VARCHAR(20) NOT NULL,

    CONSTRAINT pk_dim_perfil_vitima PRIMARY KEY (sk_perfil_vitima),
    CONSTRAINT uq_dim_perfil_vitima_comb UNIQUE (
        sexo,
        faixa_etaria_demografica,
        faixa_etaria_legal,
        nacionalidade,
        grau_de_instrucao
    ),
    CONSTRAINT chk_dim_perfil_vitima_sk CHECK (sk_perfil_vitima IN (-1, -2) OR sk_perfil_vitima > 0)
);

CREATE TABLE dw_elt.dim_transporte (
    sk_transporte          INTEGER     NOT NULL,
    tipo_de_vitima         VARCHAR(20) NOT NULL,
    modo_transporte_vitima VARCHAR(20) NOT NULL,
    tipo_veiculo_vitima    VARCHAR(20) NOT NULL,

    CONSTRAINT pk_dim_transporte PRIMARY KEY (sk_transporte),
    CONSTRAINT uq_dim_transporte_comb UNIQUE (
        tipo_de_vitima,
        modo_transporte_vitima,
        tipo_veiculo_vitima
    ),
    CONSTRAINT chk_dim_transporte_sk CHECK (sk_transporte IN (-1, -2) OR sk_transporte > 0)
);

CREATE TABLE dw_elt.dim_localidade (
    sk_localidade         INTEGER     NOT NULL,
    cod_ibge              INTEGER     NULL,
    municipio             VARCHAR(60) NOT NULL,
    regiao_administrativa VARCHAR(40) NOT NULL,

    CONSTRAINT pk_dim_localidade PRIMARY KEY (sk_localidade),
    CONSTRAINT uq_dim_localidade_cod_ibge UNIQUE (cod_ibge),
    CONSTRAINT chk_dim_localidade_sk CHECK (sk_localidade IN (-1, -2) OR sk_localidade > 0),
    CONSTRAINT chk_dim_localidade_ibge CHECK (sk_localidade IN (-1, -2) OR cod_ibge IS NOT NULL)
);

CREATE TABLE dw_elt.dim_via (
    sk_via    INTEGER     NOT NULL,
    tipo_via  VARCHAR(30) NOT NULL,
    local_via VARCHAR(20) NOT NULL,

    CONSTRAINT pk_dim_via PRIMARY KEY (sk_via),
    CONSTRAINT uq_dim_via_comb UNIQUE (tipo_via, local_via),
    CONSTRAINT chk_dim_via_sk CHECK (sk_via IN (-1, -2) OR sk_via > 0)
);

-- 3. Membros especiais e carga
-- Combinações inteiramente desconhecidas ou não aplicáveis usam -1/-2.
-- Combinações parciais mantêm os atributos conhecidos e recebem chave positiva.
-- COLLATE "C" ordena texto por código em UTF-8, como o sort_values da ETL.

INSERT INTO dw_elt.dim_perfil_vitima (
    sk_perfil_vitima, sexo, faixa_etaria_demografica,
    faixa_etaria_legal, nacionalidade, grau_de_instrucao
)
VALUES (-1, 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_perfil_vitima (
    sk_perfil_vitima, sexo, faixa_etaria_demografica,
    faixa_etaria_legal, nacionalidade, grau_de_instrucao
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY sexo COLLATE "C", faixa_etaria_demografica COLLATE "C",
                 faixa_etaria_legal COLLATE "C", nacionalidade COLLATE "C",
                 grau_de_instrucao COLLATE "C"
    )::INTEGER,
    sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao
FROM pg_temp.elt06_combinacoes
WHERE tabela = 'dim_perfil_vitima'
  AND (sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao) NOT IN (
      ('NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO'),
      ('NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA')
  );

INSERT INTO dw_elt.dim_transporte (
    sk_transporte, tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima
)
VALUES (-1, 'NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_transporte (
    sk_transporte, tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY tipo_de_vitima COLLATE "C", modo_transporte_vitima COLLATE "C", tipo_veiculo_vitima COLLATE "C"
    )::INTEGER,
    tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima
FROM pg_temp.elt06_combinacoes
WHERE tabela = 'dim_transporte'
  AND (tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima) NOT IN (
      ('NÃO INFORMADO', 'NÃO INFORMADO', 'NÃO INFORMADO'),
      ('NÃO SE APLICA', 'NÃO SE APLICA', 'NÃO SE APLICA')
  );

-- Localidade tem chave natural numérica. SQL permite os dois IBGEs nulos no UNIQUE.
INSERT INTO dw_elt.dim_localidade (sk_localidade, cod_ibge, municipio, regiao_administrativa)
VALUES (-1, NULL, 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, NULL, 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_localidade (sk_localidade, cod_ibge, municipio, regiao_administrativa)
SELECT ROW_NUMBER() OVER (ORDER BY cod_ibge)::INTEGER, cod_ibge, municipio, regiao_administrativa
FROM pg_temp.elt06_combinacoes
WHERE tabela = 'dim_localidade';

INSERT INTO dw_elt.dim_via (sk_via, tipo_via, local_via)
VALUES (-1, 'NÃO INFORMADO', 'NÃO INFORMADO'),
       (-2, 'NÃO SE APLICA', 'NÃO SE APLICA');

INSERT INTO dw_elt.dim_via (sk_via, tipo_via, local_via)
SELECT ROW_NUMBER() OVER (ORDER BY tipo_via COLLATE "C", local_via COLLATE "C")::INTEGER,
       tipo_via, local_via
FROM pg_temp.elt06_combinacoes
WHERE tabela = 'dim_via'
  AND (tipo_via, local_via) NOT IN (
      ('NÃO INFORMADO', 'NÃO INFORMADO'),
      ('NÃO SE APLICA', 'NÃO SE APLICA')
  );

ANALYZE dw_elt.dim_perfil_vitima;
ANALYZE dw_elt.dim_transporte;
ANALYZE dw_elt.dim_localidade;
ANALYZE dw_elt.dim_via;

-- 4. Cobertura usando as mesmas chaves naturais que a fato vai usar.
-- A quantidade de pessoas de cada combinação é usada para contar todas as
-- pessoas sem chave, não apenas o número de combinações que falharam.
CREATE TEMP TABLE elt06_conferencia ON COMMIT DROP AS
WITH cobertura AS (
    SELECT c.tabela, c.pessoas, d.sk_perfil_vitima AS sk
    FROM pg_temp.elt06_combinacoes AS c
    LEFT JOIN dw_elt.dim_perfil_vitima AS d USING (
        sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao
    )
    WHERE c.tabela = 'dim_perfil_vitima'

    UNION ALL
    SELECT c.tabela, c.pessoas, d.sk_transporte
    FROM pg_temp.elt06_combinacoes AS c
    LEFT JOIN dw_elt.dim_transporte AS d USING (tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima)
    WHERE c.tabela = 'dim_transporte'

    UNION ALL
    SELECT c.tabela, c.pessoas, d.sk_localidade
    FROM pg_temp.elt06_combinacoes AS c
    LEFT JOIN dw_elt.dim_localidade AS d USING (cod_ibge)
    WHERE c.tabela = 'dim_localidade'

    UNION ALL
    SELECT c.tabela, c.pessoas, d.sk_via
    FROM pg_temp.elt06_combinacoes AS c
    LEFT JOIN dw_elt.dim_via AS d USING (tipo_via, local_via)
    WHERE c.tabela = 'dim_via'
),
membros AS (
    SELECT 'dim_perfil_vitima' AS tabela, sk_perfil_vitima AS sk FROM dw_elt.dim_perfil_vitima
    UNION ALL SELECT 'dim_transporte', sk_transporte FROM dw_elt.dim_transporte
    UNION ALL SELECT 'dim_localidade', sk_localidade FROM dw_elt.dim_localidade
    UNION ALL SELECT 'dim_via', sk_via FROM dw_elt.dim_via
),
totais AS (
    SELECT tabela, COUNT(*) AS linhas,
           COUNT(*) FILTER (WHERE sk > 0) AS linhas_reais,
           COUNT(*) FILTER (WHERE sk IN (-1, -2)) AS membros_especiais
    FROM membros
    GROUP BY tabela
)
SELECT
    t.tabela, t.linhas, t.linhas_reais, t.membros_especiais,
    SUM(c.pessoas)::BIGINT AS pessoas_origem,
    COALESCE(SUM(c.pessoas) FILTER (WHERE c.sk IS NULL), 0)::BIGINT AS pessoas_sem_chave
FROM totais AS t
JOIN cobertura AS c USING (tabela)
GROUP BY t.tabela, t.linhas, t.linhas_reais, t.membros_especiais;

DO $$
DECLARE
    falhas TEXT;
BEGIN
    SELECT STRING_AGG(FORMAT('%s (%s especiais, %s pessoas sem chave)',
                             tabela, membros_especiais, pessoas_sem_chave), ', ')
      INTO falhas
      FROM pg_temp.elt06_conferencia
     WHERE membros_especiais <> 2 OR pessoas_sem_chave <> 0;

    IF falhas IS NOT NULL THEN
        RAISE EXCEPTION 'Falha na conferência das dimensões B: %.', falhas;
    END IF;
END $$;

-- 5. Consulta final de conferência (devolvida por rodar_sql()).
-- Esperado em cada dimensão: dois membros especiais e zero pessoas sem chave.
SELECT tabela, linhas, linhas_reais, membros_especiais, pessoas_origem, pessoas_sem_chave
FROM pg_temp.elt06_conferencia
ORDER BY tabela;
