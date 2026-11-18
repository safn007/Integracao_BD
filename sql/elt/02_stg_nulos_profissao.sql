-- ELT-04 · Limpeza 2: nulos, categorias e profissão
-- Equivalente em SQL às etapas ETL-16 (nulos e categorias) e ETL-17 (profissão).
-- Origem : stg.pessoas_tipos_texto_datas (ELT-03, 26 colunas)
-- Destino: stg.pessoas_nulos_profissao (VIEW, 28 colunas: as 26 + flag_obito + grupo_profissao)
-- Execução via src/rodar_sql.py (sem BEGIN/COMMIT manuais no arquivo).
--
-- Por que VIEW e não tabela: o banco já guarda raw (~209 MB), a stg da ELT-03 (~188 MB)
-- e a estrela da ETL (~166 MB). A view não ocupa espaço: as regras rodam quando as
-- dimensões (ELT-05/06) e a fato (ELT-07) leem dela.
--
-- Regras (as mesmas da ETL):
--   1. flag_obito = tem data de óbito.
--   2. Veículo vazio: pedestre -> NÃO SE APLICA; os demais -> NÃO INFORMADO.
--   3. local_obito vazio: quem não morreu -> NÃO SE APLICA; quem morreu -> NÃO INFORMADO.
--   4. nacionalidade, local_via e grau_de_instrucao vazios -> NÃO INFORMADO.
--   5. 'NAO DISPONIVEL' é nulo disfarçado -> NÃO INFORMADO (inclui gravidade_lesao).
--   6. Profissão: maiúsculas, sem acento, sem (A)/(O), hífen e barra viram espaço,
--      espaços simples; MOTOBOY e MOTOFRETISTA unificados.
--   7. Profissão vazia ou escrita como "não informado" (NAO INFORMADO, NAO INFORMADA)
--      -> NÃO INFORMADO, com grupo NÃO INFORMADO (regra da ETL-22).
--   8. grupo_profissao: primeiro grupo cujas palavras-chave aparecem (a ordem importa);
--      sem nenhuma -> OUTROS.

-- ----------------------------------------------------------------------------
-- 1. Pré-checagem da origem
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    IF to_regclass('stg.pessoas_tipos_texto_datas') IS NULL THEN
        RAISE EXCEPTION 'Tabela stg.pessoas_tipos_texto_datas não existe. Execute antes a ELT-03.';
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 2. Recriação idempotente da view
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS stg.pessoas_nulos_profissao;

CREATE VIEW stg.pessoas_nulos_profissao AS
-- regras 6, 7 e 8 calculadas uma vez por grafia distinta (são ~815), e não linha a linha
WITH grafias AS (
    SELECT DISTINCT COALESCE(profissao, '') AS original
    FROM stg.pessoas_tipos_texto_datas
),
padronizadas AS (
    -- regra 6: padroniza a escrita (unaccent vem da ELT-01)
    SELECT
        original,
        NULLIF(BTRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(
            UPPER(unaccent(original)),
            '\(A\)|\(O\)', '', 'g'),       -- MECANICO(A) vira MECANICO
            '[-/]', ' ', 'g'),             -- MOTO-BOY vira MOTO BOY
            '\s+', ' ', 'g')), '') AS escrita
    FROM grafias
),
unificadas AS (
    -- regras 6 e 7: unifica grafias e junta os "não informado"
    SELECT
        original,
        CASE
            WHEN escrita IS NULL OR escrita IN ('NAO INFORMADO', 'NAO INFORMADA') THEN 'NÃO INFORMADO'
            WHEN escrita = 'MOTOBOY'      THEN 'MOTO BOY'
            WHEN escrita = 'MOTOFRETISTA' THEN 'MOTO FRETISTA'
            ELSE escrita
        END AS profissao
    FROM padronizadas
),
mapa_profissao AS MATERIALIZED (   -- calcula o mapa uma vez só (senão o regex roda por linha)
    SELECT
        original,
        profissao,
        -- regra 8 (a primeira condição verdadeira vence, como na ETL-17)
        CASE
            WHEN profissao = 'NÃO INFORMADO' THEN 'NÃO INFORMADO'
            WHEN profissao ~ 'ESTUDANTE|APOSENTAD|DESEMPREGAD|DESOCUPAD|DO LAR|PENSIONISTA'
                THEN 'SEM OCUPACAO'
            WHEN profissao ~ 'ENFERM|MEDIC|FISIOTERAP|DENTISTA|PSICOLOG|FARMAC|NUTRICION|VETERINAR|PROFESSOR|PEDAGOG|INSTRUTOR'
                THEN 'SAUDE E EDUCACAO'
            WHEN profissao ~ 'MOTORISTA|MOTO ?BOY|MOTO ?FRETISTA|MOTOTAXISTA|MOTOCICLISTA|ENTREGADOR|TAXISTA|CAMINHONEIRO|CONDUTOR|FRETISTA|COBRADOR|MANOBRISTA'
                THEN 'TRANSPORTE E ENTREGA'
            WHEN profissao ~ 'VIGILANTE|POLICIAL|SEGURANCA|PORTEIRO|BOMBEIRO|MILITAR|FUNCION|SERVIDOR PUBLICO|GUARDA'
                THEN 'SEGURANCA E SERVICO PUBLICO'
            WHEN profissao ~ 'ENGENHEIR|ADVOGAD|ARQUITET|ANALISTA DE SISTEMAS|PROGRAMADOR|TECNICO|DESIGNER|JORNALISTA|PUBLICITARIO'
                THEN 'TECNICOS E NIVEL SUPERIOR'
            WHEN profissao ~ 'ADMINISTRAT|ADMINISTRADOR|ANALISTA|SUPERVISOR|GERENTE|CONTADOR|SECRETARI|ENCARREGADO|BANCARI|ASSISTENTE|COORDENADOR|DIRETOR|RECEPCIONISTA|ESTAGIARIO|AUXILIAR DE ESCRITORIO|ALMOXARIFE|ESTOQUISTA|CONFERENTE|CONSULTOR'
                THEN 'ADMINISTRATIVO'
            WHEN profissao ~ 'VENDEDOR|COMERCIANTE|REPOSITOR|REPRESENTANTE|PROMOTOR|CAIXA|BALCONISTA|ATENDENTE|COMERCIAL|CORRETOR'
                THEN 'COMERCIO E VENDAS'
            WHEN profissao ~ 'AGRICULTOR|LAVRADOR|TRATORISTA|PECUARIST|JARDINEIR|CAMPO'
                THEN 'AGRICULTURA E CAMPO'
            WHEN profissao ~ 'PEDREIRO|PINTOR|MECANICO|OPERADOR|METALURG|SOLDADOR|SERRALHEIR|MONTADOR|ELETRICISTA|PRODUCAO|MARCENEIR|SERVENTE|AJUDANTE|CARPINTEIR|ENCANADOR|MANUTENCAO|OPERARIO|COSTUREIR|FUNILEIR|SAPATEIR|VIDRACEIR'
                THEN 'INDUSTRIA E CONSTRUCAO'
            WHEN profissao ~ 'AUXILIAR GERAL|SERVICOS GERAIS|DOMESTIC|DIARISTA|LIMPEZA|COZINH|CABELEIREIR|MANICURE|BARBEIR|GARCOM|GARCON|ACOUGUEIR|FRENTISTA|FAXINEIR|CUIDADOR'
                THEN 'SERVICOS PESSOAIS E DOMESTICOS'
            WHEN profissao ~ 'AUTONOMO|EMPRESARIO|PROPRIETARIO'
                THEN 'AUTONOMO E EMPRESARIO'
            ELSE 'OUTROS'
        END AS grupo_profissao
    FROM unificadas
)
SELECT
    s.id_sinistro,
    s.id_pessoa,
    s.id_veiculo,
    s.cod_ibge,
    s.municipio,
    s.regiao_administrativa,

    -- regra 5
    CASE WHEN s.tipo_via = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO' ELSE s.tipo_via END AS tipo_via,

    -- regras 2 e 5: veículo vazio depende de ser pedestre
    CASE
        WHEN s.tipo_veiculo_vitima IS NULL AND s.tipo_de_vitima = 'PEDESTRE' THEN 'NÃO SE APLICA'
        WHEN s.tipo_veiculo_vitima IS NULL OR s.tipo_veiculo_vitima = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
        ELSE s.tipo_veiculo_vitima
    END AS tipo_veiculo_vitima,

    CASE WHEN s.tipo_de_vitima = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO' ELSE s.tipo_de_vitima END AS tipo_de_vitima,

    CASE
        WHEN s.modo_transporte_vitima IS NULL AND s.tipo_de_vitima = 'PEDESTRE' THEN 'NÃO SE APLICA'
        WHEN s.modo_transporte_vitima IS NULL OR s.modo_transporte_vitima = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
        ELSE s.modo_transporte_vitima
    END AS modo_transporte_vitima,

    CASE WHEN s.sexo = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO' ELSE s.sexo END AS sexo,
    s.idade,
    CASE WHEN s.gravidade_lesao = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO' ELSE s.gravidade_lesao END AS gravidade_lesao,
    CASE WHEN s.faixa_etaria_demografica = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
         ELSE s.faixa_etaria_demografica END AS faixa_etaria_demografica,
    CASE WHEN s.faixa_etaria_legal = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
         ELSE s.faixa_etaria_legal END AS faixa_etaria_legal,

    -- regras 6, 7 e 8 (pelo mapa de grafias)
    mp.profissao,
    mp.grupo_profissao,

    COALESCE(s.grau_de_instrucao, 'NÃO INFORMADO') AS grau_de_instrucao,   -- regra 4
    COALESCE(s.nacionalidade, 'NÃO INFORMADO')     AS nacionalidade,       -- regra 4
    s.data_sinistro,
    s.data_obito,

    -- regras 3 e 5
    CASE
        WHEN s.local_obito IS NULL AND s.data_obito IS NULL THEN 'NÃO SE APLICA'
        WHEN s.local_obito IS NULL OR s.local_obito = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
        ELSE s.local_obito
    END AS local_obito,

    -- regras 4 e 5
    CASE WHEN s.local_via IS NULL OR s.local_via = 'NAO DISPONIVEL' THEN 'NÃO INFORMADO'
         ELSE s.local_via END AS local_via,

    s.tempo_sinistro_obito,
    s.dias_ate_obito,
    (s.data_obito IS NOT NULL) AS flag_obito,   -- regra 1
    s.ano_origem,
    s.arquivo_origem
FROM stg.pessoas_tipos_texto_datas AS s
JOIN mapa_profissao AS mp
  ON mp.original = COALESCE(s.profissao, '');

COMMENT ON VIEW stg.pessoas_nulos_profissao IS
    'Staging 2 (ELT-04): nulos e NAO DISPONIVEL tratados, flag_obito, profissão padronizada e grupo_profissao.';

-- ----------------------------------------------------------------------------
-- 3. Validações (falha a transação se qualquer regra divergir), em passada única
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    v_linhas            BIGINT;
    v_obitos            BIGINT;
    v_nao_disponivel    BIGINT;
    v_nulos_categoricos BIGINT;
    v_local_incoerente  BIGINT;
    v_veiculo_incoer    BIGINT;
    v_prof_multigrupo   BIGINT;
BEGIN
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE flag_obito),
        COUNT(*) FILTER (WHERE 'NAO DISPONIVEL' IN (
            tipo_via, tipo_veiculo_vitima, tipo_de_vitima, modo_transporte_vitima, sexo,
            gravidade_lesao, faixa_etaria_demografica, faixa_etaria_legal, local_obito, local_via)),
        COUNT(*) FILTER (WHERE num_nulls(
            tipo_via, tipo_veiculo_vitima, tipo_de_vitima, modo_transporte_vitima, sexo,
            gravidade_lesao, faixa_etaria_demografica, faixa_etaria_legal, profissao,
            grupo_profissao, grau_de_instrucao, nacionalidade, local_obito, local_via) > 0),
        -- NÃO SE APLICA no local do óbito tem que ser exatamente quem não morreu
        COUNT(*) FILTER (WHERE (local_obito = 'NÃO SE APLICA') <> (NOT flag_obito)),
        -- NÃO SE APLICA no veículo só para pedestre
        COUNT(*) FILTER (WHERE 'NÃO SE APLICA' IN (tipo_veiculo_vitima, modo_transporte_vitima)
                           AND tipo_de_vitima <> 'PEDESTRE')
      INTO v_linhas, v_obitos, v_nao_disponivel, v_nulos_categoricos, v_local_incoerente, v_veiculo_incoer
      FROM stg.pessoas_nulos_profissao;

    -- cada profissão num grupo só: pares distintos (profissão, grupo) = profissões distintas
    SELECT COUNT(*) - COUNT(DISTINCT profissao) INTO v_prof_multigrupo
      FROM (SELECT DISTINCT profissao, grupo_profissao FROM stg.pessoas_nulos_profissao) t;

    IF v_linhas <> 806977 OR v_obitos <> 15793 THEN
        RAISE EXCEPTION 'Contagem inesperada: linhas=% (esperado 806977), óbitos=% (esperado 15793).',
            v_linhas, v_obitos;
    END IF;

    IF v_nao_disponivel > 0 OR v_nulos_categoricos > 0 THEN
        RAISE EXCEPTION 'Sobraram nulos disfarçados ou vazios (NAO DISPONIVEL=%, nulos=%).',
            v_nao_disponivel, v_nulos_categoricos;
    END IF;

    IF v_local_incoerente > 0 OR v_veiculo_incoer > 0 THEN
        RAISE EXCEPTION 'NÃO SE APLICA incoerente (local_obito=%, veículo fora de pedestre=%).',
            v_local_incoerente, v_veiculo_incoer;
    END IF;

    IF v_prof_multigrupo > 0 THEN
        RAISE EXCEPTION '% profissões com mais de um grupo.', v_prof_multigrupo;
    END IF;
END $$;

-- ----------------------------------------------------------------------------
-- 4. Consulta final de conferência (devolvida por rodar_sql())
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                         AS linhas,
    COUNT(*) FILTER (WHERE flag_obito)                               AS obitos,
    COUNT(*) FILTER (WHERE local_obito = 'NÃO SE APLICA')            AS local_obito_nao_se_aplica,
    COUNT(*) FILTER (WHERE tipo_veiculo_vitima = 'NÃO SE APLICA')    AS veiculo_nao_se_aplica,
    COUNT(*) FILTER (WHERE tipo_veiculo_vitima = 'NÃO INFORMADO')    AS veiculo_nao_informado,
    COUNT(*) FILTER (WHERE gravidade_lesao = 'NÃO INFORMADO')        AS gravidade_nao_informada,
    COUNT(*) FILTER (WHERE grau_de_instrucao = 'NÃO INFORMADO')      AS instrucao_nao_informada,
    COUNT(*) FILTER (WHERE profissao = 'NÃO INFORMADO')              AS profissao_nao_informada,
    COUNT(DISTINCT profissao) FILTER (WHERE profissao <> 'NÃO INFORMADO') AS profissoes_distintas,
    COUNT(DISTINCT grupo_profissao)                                  AS grupos_profissao,
    COUNT(*) FILTER (WHERE grupo_profissao = 'OUTROS')               AS grupo_outros
FROM stg.pessoas_nulos_profissao;
