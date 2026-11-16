-- ============================================================================
-- ETL-18 · DDL do Esquema Estrela do Data Warehouse (PostgreSQL / Supabase)
-- Projeto : Integração de Dados — Pessoas Envolvidas em Sinistros (SP, 2021–2023)
-- Modelo  : docs/modelagem/modelo_estrela.md (ETL-10)
-- Grão    : 1 linha na fato = 1 pessoa envolvida em 1 sinistro (806.977 linhas)
-- Membros especiais em todas as dimensões:
--   -1 = NÃO INFORMADO (dado ausente, "NAO DISPONIVEL" ou inválido na fonte)
--   -2 = NÃO SE APLICA (atributo não se aplica à linha, ex.: óbito sem falecimento)
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. Remoção idempotente (permite reexecução segura antes de recargas)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS fato_pessoa_sinistro CASCADE;
DROP TABLE IF EXISTS dim_tempo CASCADE;
DROP TABLE IF EXISTS dim_gravidade CASCADE;
DROP TABLE IF EXISTS dim_perfil_vitima CASCADE;
DROP TABLE IF EXISTS dim_transporte CASCADE;
DROP TABLE IF EXISTS dim_localidade CASCADE;
DROP TABLE IF EXISTS dim_via CASCADE;
DROP TABLE IF EXISTS dim_profissao CASCADE;
DROP TABLE IF EXISTS dim_local_obito CASCADE;

-- ----------------------------------------------------------------------------
-- 2. Tabelas de Dimensão (8 dimensões)
-- ----------------------------------------------------------------------------

-- 2.1 dim_tempo (role-playing: referenciada por sk_data_sinistro e sk_data_obito)
CREATE TABLE dim_tempo (
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
            data IS NOT NULL
            AND ano IS NOT NULL
            AND trimestre IS NOT NULL
            AND mes IS NOT NULL
            AND nome_mes IS NOT NULL
            AND dia IS NOT NULL
            AND ano_mes IS NOT NULL
            AND dia_semana IS NOT NULL
            AND nome_dia_semana IS NOT NULL
            AND fim_de_semana IS NOT NULL
            AND feriado IS NOT NULL
        )
    )
);

-- 2.2 dim_gravidade
CREATE TABLE dim_gravidade (
    sk_gravidade    INTEGER     NOT NULL,
    gravidade_lesao VARCHAR(20) NOT NULL,
    nivel_gravidade SMALLINT    NULL,

    CONSTRAINT pk_dim_gravidade PRIMARY KEY (sk_gravidade),
    CONSTRAINT uq_dim_gravidade_lesao UNIQUE (gravidade_lesao),
    CONSTRAINT chk_dim_gravidade_sk CHECK (sk_gravidade IN (-1, -2) OR sk_gravidade > 0),
    CONSTRAINT chk_dim_gravidade_nivel CHECK (
        sk_gravidade IN (-1, -2)
        OR (nivel_gravidade BETWEEN 0 AND 3)
    )
);

-- 2.3 dim_perfil_vitima (dimensão de combinações)
CREATE TABLE dim_perfil_vitima (
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

-- 2.4 dim_transporte (dimensão de combinações)
CREATE TABLE dim_transporte (
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

-- 2.5 dim_localidade
CREATE TABLE dim_localidade (
    sk_localidade         INTEGER     NOT NULL,
    cod_ibge              INTEGER     NULL,
    municipio             VARCHAR(60) NOT NULL,
    regiao_administrativa VARCHAR(40) NOT NULL,

    CONSTRAINT pk_dim_localidade PRIMARY KEY (sk_localidade),
    CONSTRAINT uq_dim_localidade_cod_ibge UNIQUE (cod_ibge),
    CONSTRAINT chk_dim_localidade_sk CHECK (sk_localidade IN (-1, -2) OR sk_localidade > 0),
    CONSTRAINT chk_dim_localidade_ibge CHECK (sk_localidade IN (-1, -2) OR cod_ibge IS NOT NULL)
);

-- 2.6 dim_via (dimensão de combinações)
CREATE TABLE dim_via (
    sk_via    INTEGER     NOT NULL,
    tipo_via  VARCHAR(30) NOT NULL,
    local_via VARCHAR(20) NOT NULL,

    CONSTRAINT pk_dim_via PRIMARY KEY (sk_via),
    CONSTRAINT uq_dim_via_comb UNIQUE (tipo_via, local_via),
    CONSTRAINT chk_dim_via_sk CHECK (sk_via IN (-1, -2) OR sk_via > 0)
);

-- 2.7 dim_profissao
CREATE TABLE dim_profissao (
    sk_profissao    INTEGER     NOT NULL,
    profissao       VARCHAR(80) NOT NULL,
    grupo_profissao VARCHAR(40) NOT NULL,

    CONSTRAINT pk_dim_profissao PRIMARY KEY (sk_profissao),
    CONSTRAINT uq_dim_profissao_comb UNIQUE (profissao, grupo_profissao),
    CONSTRAINT chk_dim_profissao_sk CHECK (sk_profissao IN (-1, -2) OR sk_profissao > 0)
);

-- 2.8 dim_local_obito
CREATE TABLE dim_local_obito (
    sk_local_obito INTEGER     NOT NULL,
    local_obito    VARCHAR(30) NOT NULL,

    CONSTRAINT pk_dim_local_obito PRIMARY KEY (sk_local_obito),
    CONSTRAINT uq_dim_local_obito_nome UNIQUE (local_obito),
    CONSTRAINT chk_dim_local_obito_sk CHECK (sk_local_obito IN (-1, -2) OR sk_local_obito > 0)
);

-- ----------------------------------------------------------------------------
-- 3. Tabela Fato (1 fato)
-- ----------------------------------------------------------------------------

CREATE TABLE fato_pessoa_sinistro (
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

    CONSTRAINT pk_fato_pessoa_sinistro PRIMARY KEY (id_pessoa),

    CONSTRAINT fk_fato_data_sinistro FOREIGN KEY (sk_data_sinistro) REFERENCES dim_tempo (sk_tempo),
    CONSTRAINT fk_fato_data_obito    FOREIGN KEY (sk_data_obito)    REFERENCES dim_tempo (sk_tempo),
    CONSTRAINT fk_fato_gravidade     FOREIGN KEY (sk_gravidade)     REFERENCES dim_gravidade (sk_gravidade),
    CONSTRAINT fk_fato_perfil_vitima FOREIGN KEY (sk_perfil_vitima) REFERENCES dim_perfil_vitima (sk_perfil_vitima),
    CONSTRAINT fk_fato_transporte    FOREIGN KEY (sk_transporte)    REFERENCES dim_transporte (sk_transporte),
    CONSTRAINT fk_fato_localidade    FOREIGN KEY (sk_localidade)    REFERENCES dim_localidade (sk_localidade),
    CONSTRAINT fk_fato_via           FOREIGN KEY (sk_via)           REFERENCES dim_via (sk_via),
    CONSTRAINT fk_fato_profissao     FOREIGN KEY (sk_profissao)     REFERENCES dim_profissao (sk_profissao),
    CONSTRAINT fk_fato_local_obito   FOREIGN KEY (sk_local_obito)   REFERENCES dim_local_obito (sk_local_obito),

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
-- 4. Índices de apoio a consultas analíticas e joins
-- ----------------------------------------------------------------------------
CREATE INDEX idx_fato_id_sinistro      ON fato_pessoa_sinistro (id_sinistro);
CREATE INDEX idx_fato_sk_data_sinistro ON fato_pessoa_sinistro (sk_data_sinistro);
CREATE INDEX idx_fato_sk_data_obito    ON fato_pessoa_sinistro (sk_data_obito);
CREATE INDEX idx_fato_sk_gravidade     ON fato_pessoa_sinistro (sk_gravidade);
CREATE INDEX idx_fato_sk_perfil_vitima ON fato_pessoa_sinistro (sk_perfil_vitima);
CREATE INDEX idx_fato_sk_transporte    ON fato_pessoa_sinistro (sk_transporte);
CREATE INDEX idx_fato_sk_localidade    ON fato_pessoa_sinistro (sk_localidade);
CREATE INDEX idx_fato_sk_via           ON fato_pessoa_sinistro (sk_via);
CREATE INDEX idx_fato_sk_profissao     ON fato_pessoa_sinistro (sk_profissao);
CREATE INDEX idx_fato_sk_local_obito   ON fato_pessoa_sinistro (sk_local_obito);

-- ----------------------------------------------------------------------------
-- 5. Comentários no catálogo do PostgreSQL (tabelas e colunas)
-- ----------------------------------------------------------------------------

-- dim_tempo
COMMENT ON TABLE  dim_tempo IS 'Dimensão de calendário (01/01/2021 a 24/01/2024 + membros especiais -1 e -2). Usada em role-playing pela fato para data do sinistro e data do óbito.';
COMMENT ON COLUMN dim_tempo.sk_tempo IS 'Chave substituta no formato AAAAMMDD (ex.: 20210115); -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_tempo.data IS 'Data calendário (DATE); nula apenas nos membros especiais -1 e -2.';
COMMENT ON COLUMN dim_tempo.ano IS 'Ano da data (2021 a 2024).';
COMMENT ON COLUMN dim_tempo.trimestre IS 'Trimestre do ano (1 a 4).';
COMMENT ON COLUMN dim_tempo.mes IS 'Número do mês (1 a 12).';
COMMENT ON COLUMN dim_tempo.nome_mes IS 'Nome do mês por extenso em português (ex.: JANEIRO).';
COMMENT ON COLUMN dim_tempo.dia IS 'Dia do mês (1 a 31).';
COMMENT ON COLUMN dim_tempo.ano_mes IS 'Competência no formato AAAA-MM (ex.: 2021-01).';
COMMENT ON COLUMN dim_tempo.dia_semana IS 'Dia da semana ISO/numérico (1 = segunda-feira ... 7 = domingo).';
COMMENT ON COLUMN dim_tempo.nome_dia_semana IS 'Nome do dia da semana em português (ex.: SEGUNDA-FEIRA).';
COMMENT ON COLUMN dim_tempo.fim_de_semana IS 'Indica se a data cai em sábado ou domingo (TRUE/FALSE).';
COMMENT ON COLUMN dim_tempo.feriado IS 'Indica se a data é feriado nacional (TRUE/FALSE).';
COMMENT ON COLUMN dim_tempo.nome_feriado IS 'Nome do feriado nacional; nulo quando não for feriado.';

-- dim_gravidade
COMMENT ON TABLE  dim_gravidade IS 'Dimensão de classificação clínica/policial da gravidade da lesão (4 categorias + membros -1 e -2).';
COMMENT ON COLUMN dim_gravidade.sk_gravidade IS 'Chave substituta da gravidade; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_gravidade.gravidade_lesao IS 'Descrição da gravidade da lesão (ILESO, LEVE, GRAVE, FATAL, NÃO INFORMADO, NÃO SE APLICA).';
COMMENT ON COLUMN dim_gravidade.nivel_gravidade IS 'Escala ordinal da gravidade: 0 = ileso, 1 = leve, 2 = grave, 3 = fatal (nulo/-1 nos especiais).';

-- dim_perfil_vitima
COMMENT ON TABLE  dim_perfil_vitima IS 'Dimensão de combinações de atributos demográficos e socioeconômicos da pessoa envolvida.';
COMMENT ON COLUMN dim_perfil_vitima.sk_perfil_vitima IS 'Chave substituta do perfil da vítima; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_perfil_vitima.sexo IS 'Sexo registrado da pessoa (MASCULINO, FEMININO, NÃO INFORMADO, NÃO SE APLICA).';
COMMENT ON COLUMN dim_perfil_vitima.faixa_etaria_demografica IS 'Faixa etária quinquenal (00 a 04 ... 90 e +).';
COMMENT ON COLUMN dim_perfil_vitima.faixa_etaria_legal IS 'Faixa etária com recorte legal (0-17, 18-24 ... 80 ou mais).';
COMMENT ON COLUMN dim_perfil_vitima.nacionalidade IS 'Nacionalidade padronizada sem espaços excedentes à direita.';
COMMENT ON COLUMN dim_perfil_vitima.grau_de_instrucao IS 'Nível de escolaridade (BÁSICO, MÉDIO, SUPERIOR, NÃO INFORMADO, NÃO SE APLICA).';

-- dim_transporte
COMMENT ON TABLE  dim_transporte IS 'Dimensão de combinações de papel da vítima, modo de transporte e tipo de veículo.';
COMMENT ON COLUMN dim_transporte.sk_transporte IS 'Chave substituta de transporte; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_transporte.tipo_de_vitima IS 'Papel da pessoa no sinistro (CONDUTOR, PASSAGEIRO, PEDESTRE, NÃO INFORMADO, NÃO SE APLICA).';
COMMENT ON COLUMN dim_transporte.modo_transporte_vitima IS 'Modo de transporte da vítima (AUTOMOVEL, MOTOCICLETA, PEDESTRE, NÃO SE APLICA, etc.).';
COMMENT ON COLUMN dim_transporte.tipo_veiculo_vitima IS 'Categoria do veículo da vítima (AUTOMOVEL, MOTOCICLETA, NÃO SE APLICA para pedestre, etc.).';

-- dim_localidade
COMMENT ON TABLE  dim_localidade IS 'Dimensão geográfica dos 645 municípios paulistas e suas 16 regiões administrativas.';
COMMENT ON COLUMN dim_localidade.sk_localidade IS 'Chave substituta de localidade; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_localidade.cod_ibge IS 'Código IBGE de 7 dígitos do município (chave natural única; nulo/-1 nos membros especiais).';
COMMENT ON COLUMN dim_localidade.municipio IS 'Nome do município paulista padronizado (com apóstrofos D''OESTE / D''ALHO restaurados).';
COMMENT ON COLUMN dim_localidade.regiao_administrativa IS 'Região Administrativa do Estado de São Paulo à qual o município pertence.';

-- dim_via
COMMENT ON TABLE  dim_via IS 'Dimensão de combinações da classificação macro e natureza de acesso da via.';
COMMENT ON COLUMN dim_via.sk_via IS 'Chave substituta da via; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_via.tipo_via IS 'Classificação da via (VIAS URBANAS, ESTRADAS E RODOVIAS, NÃO INFORMADO, NÃO SE APLICA).';
COMMENT ON COLUMN dim_via.local_via IS 'Natureza de acesso da via (PUBLICO, PRIVADO, NÃO INFORMADO, NÃO SE APLICA).';

-- dim_profissao
COMMENT ON TABLE  dim_profissao IS 'Dimensão de ocupação declarada da pessoa com agrupamento macro em grupos profissionais.';
COMMENT ON COLUMN dim_profissao.sk_profissao IS 'Chave substituta da profissão; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_profissao.profissao IS 'Ocupação/profissão com grafia padronizada.';
COMMENT ON COLUMN dim_profissao.grupo_profissao IS 'Agrupamento macro da profissão (cerca de 10 grupos).';

-- dim_local_obito
COMMENT ON TABLE  dim_local_obito IS 'Dimensão de tipo de estabelecimento ou local onde ocorreu o óbito.';
COMMENT ON COLUMN dim_local_obito.sk_local_obito IS 'Chave substituta do local de óbito; -1 = NÃO INFORMADO, -2 = NÃO SE APLICA.';
COMMENT ON COLUMN dim_local_obito.local_obito IS 'Local do óbito (VIA, ESTABELECIMENTO DE SAUDE, OUTROS, NÃO INFORMADO, NÃO SE APLICA).';

-- fato_pessoa_sinistro
COMMENT ON TABLE  fato_pessoa_sinistro IS 'Tabela fato central no grão 1 linha = 1 pessoa envolvida em 1 sinistro (SP, 2021–2023; 806.977 linhas esperadas).';
COMMENT ON COLUMN fato_pessoa_sinistro.id_pessoa IS 'Chave primária natural e dimensão degenerada: identificador único da pessoa envolvida na fonte Infosiga.';
COMMENT ON COLUMN fato_pessoa_sinistro.id_sinistro IS 'Dimensão degenerada: identificador do sinistro (use COUNT(DISTINCT id_sinistro) para contar ocorrências).';
COMMENT ON COLUMN fato_pessoa_sinistro.id_veiculo IS 'Dimensão degenerada: identificador do veículo na fonte; nulo permitido (cerca de 21 por cento para pedestres e registros sem veículo).';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_data_sinistro IS 'FK para dim_tempo representando a data do sinistro.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_data_obito IS 'FK para dim_tempo representando a data do óbito (-2 = NÃO SE APLICA quando não houve óbito).';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_gravidade IS 'FK para dim_gravidade representando a gravidade da lesão.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_perfil_vitima IS 'FK para dim_perfil_vitima representando o perfil demográfico e educacional da pessoa.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_transporte IS 'FK para dim_transporte representando papel, modo e veículo da pessoa.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_localidade IS 'FK para dim_localidade representando o município e região administrativa do sinistro.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_via IS 'FK para dim_via representando o tipo e o local da via.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_profissao IS 'FK para dim_profissao representando a profissão e grupo profissional da pessoa.';
COMMENT ON COLUMN fato_pessoa_sinistro.sk_local_obito IS 'FK para dim_local_obito representando o local do óbito (-2 = NÃO SE APLICA quando não houve óbito).';
COMMENT ON COLUMN fato_pessoa_sinistro.idade IS 'Medida não aditiva: idade da pessoa em anos completos na data do sinistro (0 a 102; nulo quando não informada).';
COMMENT ON COLUMN fato_pessoa_sinistro.dias_ate_obito IS 'Medida não aditiva: dias decorridos entre o sinistro e o óbito (0 a 30; nulo quando não houve óbito).';
COMMENT ON COLUMN fato_pessoa_sinistro.flag_obito IS 'Medida aditiva indicadora de óbito: 1 se houve óbito até 30 dias, 0 caso contrário.';
COMMENT ON COLUMN fato_pessoa_sinistro.qtd_pessoas IS 'Medida aditiva unitária (sempre 1) para contagem de pessoas envolvidas via SUM(qtd_pessoas).';

COMMIT;
