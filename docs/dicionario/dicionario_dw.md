# Dicionário de Dados do Data Warehouse — Esquema Estrela (SP, 2021–2023)

> Documento de referência física e lógica do Data Warehouse implementado no PostgreSQL (Supabase) pelo script [`sql/ddl/etl_star_schema.sql`](../../sql/ddl/etl_star_schema.sql), a partir da modelagem da `ETL-10` ([`modelo_estrela.md`](../modelagem/modelo_estrela.md)) e do dicionário da fonte da `ETL-11` ([`dicionario_fonte.md`](dicionario_fonte.md)). Alimenta a Seção 1 do relatório final.

---

## 1. Visão Geral do Data Warehouse

| Característica | Especificação no DW |
|---|---|
| **SGBD / Hospedagem** | PostgreSQL (instância em nuvem no Supabase, schema `public`) |
| **Arquitetura** | Esquema Estrela (*Star Schema*) — **1 tabela fato + 8 tabelas dimensão** (**9 tabelas**, **54 colunas**) |
| **Grão da tabela fato** | **1 linha = 1 pessoa envolvida em 1 sinistro** (`id_pessoa` único) |
| **Volume esperado na fato** | **806.977 linhas** (2021: `260.886`; 2022: `266.128`; 2023: `279.963`; `402.695` sinistros distintos; `15.793` óbitos) |
| **Período coberto (`dim_tempo`)** | `01/01/2021` a `24/01/2024` (`1.119` dias + `2` membros especiais = `1.121` linhas) |
| **Membros especiais (`sk_*`)** | `-1` (`NÃO INFORMADO`: ausente, `"NAO DISPONIVEL"` ou inválido) e `-2` (`NÃO SE APLICA`: atributo não aplicável, ex.: dados de óbito para sobreviventes) |
| **Integridade referencial** | Todas as **9 chaves estrangeiras** na fato são `NOT NULL` (uso de `-1` e `-2` evita `JOIN`s com perda de linhas) |
| **Metadados no catálogo** | `COMMENT ON TABLE` nas 9 tabelas e `COMMENT ON COLUMN` nas 54 colunas |

---

## 2. Inventário das Tabelas (9 Tabelas / 54 Colunas)

| # | Tabela | Papel | Chave Primária | Colunas | Cardinalidade Esperada | Etapa que Popula |
|---|---|---|---|---|---|---|
| 1 | `fato_pessoa_sinistro` | Fato central | `id_pessoa` | 16 | `806.977` linhas | `ETL-23` / `ETL-24` |
| 2 | `dim_tempo` | Dimensão calendário (*role-playing*) | `sk_tempo` | 13 | `1.121` linhas (`1.119` dias + `-1`, `-2`) | `ETL-19` / `ETL-24` |
| 3 | `dim_gravidade` | Dimensão de gravidade | `sk_gravidade` | 3 | `6` linhas (`4` categorias + `-1`, `-2`) | `ETL-19` / `ETL-24` |
| 4 | `dim_perfil_vitima` | Dimensão de combinações (perfil) | `sk_perfil_vitima` | 6 | `~1.500` linhas (inclui `-1`, `-2`) | `ETL-20` / `ETL-24` |
| 5 | `dim_transporte` | Dimensão de combinações (transporte) | `sk_transporte` | 4 | `~25` linhas (inclui `-1`, `-2`) | `ETL-20` / `ETL-24` |
| 6 | `dim_localidade` | Dimensão geográfica (município/região) | `sk_localidade` | 4 | `647` linhas (`645` municípios + `-1`, `-2`) | `ETL-21` / `ETL-24` |
| 7 | `dim_via` | Dimensão de combinações (via) | `sk_via` | 3 | `~11` linhas (inclui `-1`, `-2`) | `ETL-21` / `ETL-24` |
| 8 | `dim_profissao` | Dimensão de ocupação | `sk_profissao` | 3 | `≤ 816` linhas (após unificação `ETL-17` + `-1`, `-2`) | `ETL-22` / `ETL-24` |
| 9 | `dim_local_obito` | Dimensão de local do óbito | `sk_local_obito` | 2 | `5` linhas (`3` locais + `-1`, `-2`) | `ETL-22` / `ETL-24` |

---

## 3. Dicionário Detalhado por Tabela

### 3.1 `fato_pessoa_sinistro` (16 colunas)

Tabela fato central no grão de 1 pessoa envolvida em 1 sinistro. Reúne 3 dimensões degeneradas (identificadores da fonte), 9 chaves estrangeiras para as dimensões e 4 medidas (2 aditivas e 2 não aditivas).

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `id_pessoa` | `INTEGER` | `NOT NULL` | `PK` (`pk_fato_pessoa_sinistro`) | Identificador único da pessoa envolvida no sinistro (dimensão degenerada). | `id_pessoa` tipado como inteiro na `ETL-13`; unicidade validada (`806.977` valores). | `1979797` |
| 2 | `id_sinistro` | `INTEGER` | `NOT NULL` | Índice (`idx_fato_id_sinistro`) | Identificador do sinistro de trânsito (dimensão degenerada; usar `COUNT(DISTINCT id_sinistro)` para contar ocorrências). | `id_sinistro` tipado como inteiro na `ETL-13` (`402.695` distintos). | `2240338` |
| 3 | `id_veiculo` | `INTEGER` | `NULL` | — | Identificador do veículo associado à pessoa na fonte (dimensão degenerada). | `id_veiculo` tipado como `Int64` na `ETL-13`/`ETL-16`; permanece `NULL` em pedestres e registros sem veículo (`~21%`). | `2874666`, `NULL` |
| 4 | `sk_data_sinistro` | `INTEGER` | `NOT NULL` | `FK` → `dim_tempo(sk_tempo)`, Índice | Chave da data em que ocorreu o sinistro. | Convertida de `data_sinistro` (`ETL-15`) para inteiro `AAAAMMDD` (`ETL-19`, `ETL-23`). | `20210115` |
| 5 | `sk_data_obito` | `INTEGER` | `NOT NULL` | `FK` → `dim_tempo(sk_tempo)`, Índice, `CHECK` coerência | Chave da data do óbito (uso em *role-playing* da `dim_tempo`). | Convertida de `data_obito`; assume `-2` (`NÃO SE APLICA`) quando `flag_obito = 0`. | `20210118`, `-2` |
| 6 | `sk_gravidade` | `INTEGER` | `NOT NULL` | `FK` → `dim_gravidade(sk_gravidade)`, Índice | Chave da gravidade da lesão sofrida pela pessoa. | Mapeada de `gravidade_lesao` (`ETL-19`, `ETL-23`); `-1` quando não informada. | `1`, `-1` |
| 7 | `sk_perfil_vitima` | `INTEGER` | `NOT NULL` | `FK` → `dim_perfil_vitima(sk_perfil_vitima)`, Índice | Chave da combinação demográfica/educacional da pessoa. | Lookup por `(sexo, faixa_etaria_demografica, faixa_etaria_legal, nacionalidade, grau_de_instrucao)` (`ETL-20`, `ETL-23`). | `42`, `-1` |
| 8 | `sk_transporte` | `INTEGER` | `NOT NULL` | `FK` → `dim_transporte(sk_transporte)`, Índice | Chave da combinação de papel da vítima, modo de transporte e veículo. | Lookup por `(tipo_de_vitima, modo_transporte_vitima, tipo_veiculo_vitima)` (`ETL-20`, `ETL-23`). | `1`, `-1` |
| 9 | `sk_localidade` | `INTEGER` | `NOT NULL` | `FK` → `dim_localidade(sk_localidade)`, Índice | Chave do município e região administrativa do sinistro. | Lookup por `cod_ibge` (`ETL-21`, `ETL-23`). | `512` |
| 10 | `sk_via` | `INTEGER` | `NOT NULL` | `FK` → `dim_via(sk_via)`, Índice | Chave da combinação de classificação e natureza de acesso da via. | Lookup por `(tipo_via, local_via)` (`ETL-21`, `ETL-23`). | `3`, `-1` |
| 11 | `sk_profissao` | `INTEGER` | `NOT NULL` | `FK` → `dim_profissao(sk_profissao)`, Índice | Chave da profissão padronizada e respectivo grupo profissional. | Lookup por `profissao` padronizada (`ETL-17`, `ETL-22`, `ETL-23`). | `15`, `-1` |
| 12 | `sk_local_obito` | `INTEGER` | `NOT NULL` | `FK` → `dim_local_obito(sk_local_obito)`, Índice, `CHECK` coerência | Chave do local de ocorrência do óbito. | Lookup por `local_obito`; assume `-2` quando `flag_obito = 0` e `-1` se óbito sem local informado (`ETL-22`, `ETL-23`). | `2`, `-2` |
| 13 | `idade` | `SMALLINT` | `NULL` | `CHECK (idade IS NULL OR idade BETWEEN 0 AND 120)` | Medida não aditiva: idade da pessoa em anos completos na data do sinistro. | `idade` validada na `ETL-16`; `NULL` quando não informada (`1,04%`). | `34`, `NULL` |
| 14 | `dias_ate_obito` | `SMALLINT` | `NULL` | `CHECK (dias_ate_obito IS NULL OR dias_ate_obito BETWEEN 0 AND 30)`, `CHECK` coerência | Medida não aditiva: dias entre a data do sinistro e a data do óbito (critério Infosiga até 30 dias). | `tempo_sinistro_obito` validado na `ETL-15` contra `data_obito - data_sinistro`; `NULL` quando `flag_obito = 0`. | `0`, `12`, `NULL` |
| 15 | `flag_obito` | `SMALLINT` | `NOT NULL` | `DEFAULT 0`, `CHECK (flag_obito IN (0, 1))`, `CHECK` coerência | Medida aditiva indicadora de óbito (`1` = óbito até 30 dias; `0` = não houve óbito). | Derivada na `ETL-16` (`1` se `data_obito` preenchida, senão `0`). | `0`, `1` |
| 16 | `qtd_pessoas` | `SMALLINT` | `NOT NULL` | `DEFAULT 1`, `CHECK (qtd_pessoas = 1)` | Medida aditiva unitária para contagem de pessoas via `SUM(qtd_pessoas)`. | Coluna constante igual a `1` criada na `ETL-23`. | `1` |

**Restrição de coerência de óbito (`chk_fato_obito_coerencia`):** garante que registros sem óbito (`flag_obito = 0`) possuam obrigatoriamente `sk_data_obito = -2`, `sk_local_obito = -2` e `dias_ate_obito IS NULL`, e que registros com óbito (`flag_obito = 1`) possuam `sk_data_obito <> -2`.

---

### 3.2 `dim_tempo` (13 colunas)

Dimensão de calendário compartilhada (*role-playing*) pelas chaves `sk_data_sinistro` e `sk_data_obito`. Cobre de `01/01/2021` a `24/01/2024` além dos membros `-1` e `-2`.

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_tempo` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_tempo IN (-1, -2) OR sk_tempo > 0)` | Chave substituta inteira no padrão `AAAAMMDD` (ou `-1`/`-2`). | Gerada na `ETL-19` a partir do calendário contínuo. | `20210115`, `-1`, `-2` |
| 2 | `data` | `DATE` | `NULL` | `UNIQUE`, `CHECK` (obrigatório se `sk_tempo > 0`) | Data calendário no formato ISO. | Série diária `2021-01-01` a `2024-01-24`; `NULL` em `-1` e `-2`. | `2021-01-15` |
| 3 | `ano` | `SMALLINT` | `NULL` | `CHECK` (obrigatório se `sk_tempo > 0`) | Ano calendário com 4 dígitos. | Extraído de `data` (`ETL-19`). | `2021`, `2024` |
| 4 | `trimestre` | `SMALLINT` | `NULL` | `CHECK (1..4)`, obrigatório se `sk_tempo > 0` | Trimestre do ano (`1` a `4`). | Derivado de `mes` (`ETL-19`). | `1`, `4` |
| 5 | `mes` | `SMALLINT` | `NULL` | `CHECK (1..12)`, obrigatório se `sk_tempo > 0` | Número do mês (`1` a `12`). | Extraído de `data` (`ETL-19`). | `1`, `12` |
| 6 | `nome_mes` | `VARCHAR(20)` | `NULL` | obrigatório se `sk_tempo > 0` | Nome do mês em português (maiúsculas). | Mapeado de `mes` (`ETL-19`); `'NÃO INFORMADO'` / `'NÃO SE APLICA'` ou `NULL` em `-1`/`-2`. | `JANEIRO`, `DEZEMBRO` |
| 7 | `dia` | `SMALLINT` | `NULL` | `CHECK (1..31)`, obrigatório se `sk_tempo > 0` | Dia do mês (`1` a `31`). | Extraído de `data` (`ETL-19`). | `15` |
| 8 | `ano_mes` | `VARCHAR(15)` | `NULL` | obrigatório se `sk_tempo > 0` | Competência `AAAA-MM` para séries mensais. | Formatado de `data` (`ETL-19`). | `2021-01` |
| 9 | `dia_semana` | `SMALLINT` | `NULL` | `CHECK (1..7)`, obrigatório se `sk_tempo > 0` | Dia da semana numérico (`1` = segunda ... `7` = domingo). | Extraído de `data` (`ETL-19`). | `5`, `7` |
| 10 | `nome_dia_semana` | `VARCHAR(20)` | `NULL` | obrigatório se `sk_tempo > 0` | Nome do dia da semana em português. | Mapeado de `dia_semana` (`ETL-19`). | `SEGUNDA-FEIRA`, `DOMINGO` |
| 11 | `fim_de_semana` | `BOOLEAN` | `NULL` | obrigatório se `sk_tempo > 0` | Indicador booleano de sábado ou domingo (`TRUE`/`FALSE`). | Derivado de `dia_semana IN (6, 7)` (`ETL-19`). | `TRUE`, `FALSE` |
| 12 | `feriado` | `BOOLEAN` | `NULL` | obrigatório se `sk_tempo > 0` | Indicador booleano de feriado nacional (`TRUE`/`FALSE`). | Calculado via calendário de feriados nacionais (`ETL-19`). | `TRUE`, `FALSE` |
| 13 | `nome_feriado` | `VARCHAR(40)` | `NULL` | — | Nome do feriado nacional quando `feriado = TRUE`. | Preenchido pela `ETL-19`; `NULL` nos demais dias. | `Natal`, `NULL` |

---

### 3.3 `dim_gravidade` (3 colunas)

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_gravidade` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_gravidade IN (-1, -2) OR sk_gravidade > 0)` | Chave substituta da gravidade. | Gerada na `ETL-19` (+ `-1` e `-2`). | `1`, `-1` |
| 2 | `gravidade_lesao` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` | Classificação clínica/policial da lesão. | `gravidade_lesao` tratada na `ETL-19` (`NAO DISPONIVEL` → `-1`). | `ILESO`, `LEVE`, `GRAVE`, `FATAL` |
| 3 | `nivel_gravidade` | `SMALLINT` | `NULL` | `CHECK (sk_gravidade IN (-1, -2) OR nivel_gravidade BETWEEN 0 AND 3)` | Escala ordinal (`0` = ileso, `1` = leve, `2` = grave, `3` = fatal) para ordenação e filtros. | Atribuída na `ETL-19`; `NULL` nos membros `-1` e `-2`. | `0`, `3`, `NULL` |

---

### 3.4 `dim_perfil_vitima` (6 colunas)

Dimensão de combinações distintas de atributos demográficos e socioeconômicos da pessoa envolvida.

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_perfil_vitima` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_perfil_vitima IN (-1, -2) OR sk_perfil_vitima > 0)` | Chave substituta do perfil da vítima. | Gerada na `ETL-20` (+ `-1` e `-2`). | `1`, `-1` |
| 2 | `sexo` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (5 colunas) | Sexo registrado da pessoa. | `sexo` tratado na `ETL-16` (`NAO DISPONIVEL` → `NÃO INFORMADO`). | `MASCULINO`, `FEMININO`, `NÃO INFORMADO` |
| 3 | `faixa_etaria_demografica` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (5 colunas) | Faixa etária quinquenal (`00 a 04` ... `90 e +`). | `faixa_etaria_demografica` tratada na `ETL-16`. | `30 a 34`, `NÃO INFORMADO` |
| 4 | `faixa_etaria_legal` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (5 colunas) | Faixa etária com recorte legal (`0-17`, `18-24` ... `80 ou mais`). | `faixa_etaria_legal` tratada na `ETL-16`. | `18-24`, `NÃO INFORMADO` |
| 5 | `nacionalidade` | `VARCHAR(40)` | `NOT NULL` | `UNIQUE` composta (5 colunas) | Nacionalidade da pessoa sem espaços sobrando à direita. | `strip()` na `ETL-14` + nulos como `NÃO INFORMADO` na `ETL-16`. | `BRASILEIRA`, `BOLIVIANA` |
| 6 | `grau_de_instrucao` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (5 colunas) | Nível de escolaridade declarado. | Nulos (`78,35%`) convertidos em `NÃO INFORMADO` na `ETL-16`. | `BÁSICO`, `MÉDIO`, `SUPERIOR`, `NÃO INFORMADO` |

---

### 3.5 `dim_transporte` (4 colunas)

Dimensão de combinações distintas do papel da vítima, modo de transporte e tipo de veículo.

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_transporte` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_transporte IN (-1, -2) OR sk_transporte > 0)` | Chave substituta de transporte. | Gerada na `ETL-20` (+ `-1` e `-2`). | `1`, `-1` |
| 2 | `tipo_de_vitima` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (3 colunas) | Papel da pessoa no sinistro. | `tipo_de_vitima` tratado na `ETL-16` (`NAO DISPONIVEL` → `NÃO INFORMADO`). | `CONDUTOR`, `PASSAGEIRO`, `PEDESTRE` |
| 3 | `modo_transporte_vitima` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (3 colunas) | Modo de transporte da vítima. | `modo_transporte_vitima` tratado na `ETL-16` (pedestres sem veículo → `NÃO SE APLICA`; demais nulos → `NÃO INFORMADO`). | `MOTOCICLETA`, `AUTOMOVEL`, `NÃO SE APLICA` |
| 4 | `tipo_veiculo_vitima` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE` composta (3 colunas) | Categoria do veículo ocupado pela vítima. | `tipo_veiculo_vitima` tratado na `ETL-16` (pedestres sem veículo → `NÃO SE APLICA`; demais nulos → `NÃO INFORMADO`). | `AUTOMOVEL`, `BICICLETA`, `NÃO SE APLICA` |

---

### 3.6 `dim_localidade` (4 colunas)

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_localidade` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_localidade IN (-1, -2) OR sk_localidade > 0)` | Chave substituta da localidade. | Gerada na `ETL-21` (+ `-1` e `-2`). | `1`, `512` |
| 2 | `cod_ibge` | `INTEGER` | `NULL` | `UNIQUE`, `CHECK` (obrigatório se `sk_localidade > 0`) | Código IBGE de 7 dígitos do município paulista (chave natural). | `cod_ibge` validado em relação 1:1 com `municipio` (`ETL-13`, `ETL-21`); `NULL` ou negativo nos membros especiais. | `3550308` |
| 3 | `municipio` | `VARCHAR(60)` | `NOT NULL` | — | Nome padronizado do município paulista (`645` municípios). | Apóstrofos restaurados em 8 municípios na `ETL-14` (`D'OESTE`, `D'ALHO`). | `SAO PAULO`, `SANTA BARBARA D'OESTE` |
| 4 | `regiao_administrativa` | `VARCHAR(40)` | `NOT NULL` | — | Região Administrativa do Estado de São Paulo (`16` regiões). | Validada na `ETL-14` e `ETL-21`. | `METROPOLITANA DE SÃO PAULO`, `CAMPINAS` |

---

### 3.7 `dim_via` (3 colunas)

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_via` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_via IN (-1, -2) OR sk_via > 0)` | Chave substituta da via. | Gerada na `ETL-21` (+ `-1` e `-2`). | `1`, `-1` |
| 2 | `tipo_via` | `VARCHAR(30)` | `NOT NULL` | `UNIQUE (tipo_via, local_via)` | Classificação macro da via. | `tipo_via` tratado na `ETL-16` (`NAO DISPONIVEL` → `NÃO INFORMADO`). | `VIAS URBANAS`, `ESTRADAS E RODOVIAS` |
| 3 | `local_via` | `VARCHAR(20)` | `NOT NULL` | `UNIQUE (tipo_via, local_via)` | Natureza jurídica/acesso da via. | `local_via` tratado na `ETL-16` (nulos e `NAO DISPONIVEL` → `NÃO INFORMADO`). | `PUBLICO`, `PRIVADO`, `NÃO INFORMADO` |

---

### 3.8 `dim_profissao` (3 colunas)

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_profissao` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_profissao IN (-1, -2) OR sk_profissao > 0)` | Chave substituta da profissão. | Gerada na `ETL-22` (+ `-1` e `-2`). | `1`, `-1` |
| 2 | `profissao` | `VARCHAR(80)` | `NOT NULL` | `UNIQUE (profissao, grupo_profissao)` | Ocupação declarada com grafia normalizada. | Unificação léxica de `814` grafias variantes na `ETL-17` (ex.: `MOTO-BOY`/`MOTOBOY`). | `MOTORISTA`, `MOTOBOY`, `NÃO INFORMADO` |
| 3 | `grupo_profissao` | `VARCHAR(40)` | `NOT NULL` | `UNIQUE (profissao, grupo_profissao)` | Classificação macro em cerca de 10 grupos profissionais. | Criada na `ETL-17` e carregada na `ETL-22`. | `TRANSPORTE`, `COMÉRCIO`, `NÃO INFORMADO` |

---

### 3.9 `dim_local_obito` (2 colunas)

| # | Coluna | Tipo PostgreSQL | Nulo? | Chave / Restrição | Descrição | Origem / Regra no ETL | Exemplo |
|---|---|---|---|---|---|---|---|
| 1 | `sk_local_obito` | `INTEGER` | `NOT NULL` | `PK`, `CHECK (sk_local_obito IN (-1, -2) OR sk_local_obito > 0)` | Chave substituta do local do óbito. | Gerada na `ETL-22` (+ `-1` e `-2`). | `1`, `-1`, `-2` |
| 2 | `local_obito` | `VARCHAR(30)` | `NOT NULL` | `UNIQUE` | Tipo de estabelecimento ou local onde ocorreu o óbito. | `local_obito` tratado na `ETL-16` (sem óbito → `NÃO SE APLICA`; `NAO DISPONIVEL` → `NÃO INFORMADO`). | `VIA`, `ESTABELECIMENTO DE SAUDE`, `OUTROS` |

---

## 4. Índices Analíticos Criados no Banco

Para acelerar consultas analíticas com filtros/agrupamentos em `GROUP BY` e a validação pós-carga (`ETL-25`), além das `PRIMARY KEY` e `UNIQUE` (que criam índices implícitos no PostgreSQL), foram criados **10 índices explícitos** em `fato_pessoa_sinistro`:

- `idx_fato_id_sinistro` em `(id_sinistro)` — acelera `COUNT(DISTINCT id_sinistro)` e consultas por sinistro.
- `idx_fato_sk_data_sinistro`, `idx_fato_sk_data_obito`, `idx_fato_sk_gravidade`, `idx_fato_sk_perfil_vitima`, `idx_fato_sk_transporte`, `idx_fato_sk_localidade`, `idx_fato_sk_via`, `idx_fato_sk_profissao`, `idx_fato_sk_local_obito` — cobrem todas as 9 chaves estrangeiras da tabela fato.

---

## 5. Matriz de Linhagem (Fonte → Data Warehouse)

| # | Coluna na Fonte (`dicionario_fonte.md`) | Destino no DW (`tabela.coluna`) | Transformação / Observação |
|---|---|---|---|
| 1 | `id_sinistro` | `fato_pessoa_sinistro.id_sinistro` | Tipagem para `INTEGER` (`ETL-13`) |
| 2 | `id_pessoa` | `fato_pessoa_sinistro.id_pessoa` | `PK` da fato; tipagem e unicidade (`ETL-13`) |
| 3 | `id_veiculo` | `fato_pessoa_sinistro.id_veiculo` | Tipagem para `Int64`/`INTEGER NULL` (`ETL-13`, `ETL-16`) |
| 4 | `cod_ibge` | `dim_localidade.cod_ibge` | Tipagem e conferência 1:1 (`ETL-13`, `ETL-21`) |
| 5 | `municipio` | `dim_localidade.municipio` | Restauração de apóstrofos `D'OESTE`/`D'ALHO` (`ETL-14`, `ETL-21`) |
| 6 | `regiao_administrativa` | `dim_localidade.regiao_administrativa` | Auditoria de texto/encoding (`ETL-14`, `ETL-21`) |
| 7 | `tipo_via` | `dim_via.tipo_via` | `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-21`) |
| 8 | `tipo_veiculo_vitima` | `dim_transporte.tipo_veiculo_vitima` | Pedestre nulo → `NÃO SE APLICA`; demais → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 9 | `tipo_de_vitima` | `dim_transporte.tipo_de_vitima` | `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 10 | `modo_transporte_vitima` | `dim_transporte.modo_transporte_vitima` | Pedestre nulo → `NÃO SE APLICA`; demais → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 11 | `sexo` | `dim_perfil_vitima.sexo` | `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 12 | `idade` | `fato_pessoa_sinistro.idade` | Validação `0..102` e conversão para `SMALLINT NULL` (`ETL-16`) |
| 13 | `gravidade_lesao` | `dim_gravidade.gravidade_lesao` | Mapeamento ordinal `nivel_gravidade` e `-1` (`ETL-19`) |
| 14 | `faixa_etaria_demografica` | `dim_perfil_vitima.faixa_etaria_demografica` | `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 15 | `faixa_etaria_legal` | `dim_perfil_vitima.faixa_etaria_legal` | `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 16 | `profissao` | `dim_profissao.profissao` (+ `grupo_profissao`) | Espaços (`ETL-14`), nulos (`ETL-16`), unificação e grupos (`ETL-17`, `ETL-22`) |
| 17 | `grau_de_instrucao` | `dim_perfil_vitima.grau_de_instrucao` | Nulos (`78,35%`) → `NÃO INFORMADO` (`ETL-16`, `ETL-20`) |
| 18 | `nacionalidade` | `dim_perfil_vitima.nacionalidade` | Remoção de espaços à direita (`ETL-14`, `ETL-16`, `ETL-20`) |
| 19 | `data_sinistro` | `fato_pessoa_sinistro.sk_data_sinistro` → `dim_tempo` | Conversão `DATE` (`ETL-15`) e chave `AAAAMMDD` (`ETL-19`) |
| 20–23 | `ano_sinistro`, `mes_sinistro`, `dia_sinistro`, `ano_mes_sinistro` | *Descartadas* | Conferidas contra `data_sinistro` e removidas na `ETL-15` (substituídas por `dim_tempo`) |
| 24 | `data_obito` | `fato_pessoa_sinistro.sk_data_obito` → `dim_tempo` (+ `flag_obito`) | Conversão `DATE` (`ETL-15`), `flag_obito` (`ETL-16`), `-2` sem óbito (`ETL-19`, `ETL-23`) |
| 25–28 | `ano_obito`, `mes_obito`, `dia_obito`, `ano_mes_obito` | *Descartadas* | Conferidas contra `data_obito` e removidas na `ETL-15` (substituídas por `dim_tempo`) |
| 29 | `local_obito` | `dim_local_obito.local_obito` | Nulo sem óbito → `NÃO SE APLICA` / `-2`; `NAO DISPONIVEL` → `-1` (`ETL-16`, `ETL-22`) |
| 30 | `local_via` | `dim_via.local_via` | Nulo e `NAO DISPONIVEL` → `NÃO INFORMADO` (`ETL-16`, `ETL-21`) |
| 31 | `tempo_sinistro_obito` | `fato_pessoa_sinistro.dias_ate_obito` | Validado contra `data_obito - data_sinistro` (`ETL-15`) |
| 32–33 | `ano_origem`, `arquivo_origem` | *Descartadas (auditoria)* | Geradas na extração (`ETL-05`) apenas para rastreabilidade no pipeline |
| — | *(Derivada no ETL)* | `fato_pessoa_sinistro.qtd_pessoas` | Medida unitária (`1`) gerada na `ETL-23` |

---

## 6. Decisões Físicas e Ajustes Preventivos sobre o Modelo Lógico

Na tradução do modelo conceitual/lógico ([`modelo_estrela.md`](../modelagem/modelo_estrela.md)) para o DDL PostgreSQL ([`etl_star_schema.sql`](../../sql/ddl/etl_star_schema.sql)), foram aplicados três ajustes preventivos para evitar falhas na etapa de carga (`ETL-24`):

1. **Largura de colunas textuais em `dim_tempo`:** `nome_mes` e `nome_dia_semana` foram definidos como `VARCHAR(20)` (em vez de `VARCHAR(10)`) e `ano_mes` como `VARCHAR(15)` (em vez de `CHAR(7)`), pois valores válidos como `'SEGUNDA-FEIRA'` (13 caracteres) e os rótulos dos membros especiais `'NÃO INFORMADO'` / `'NÃO SE APLICA'` (13 caracteres) excederiam o limite de 10 e 7 caracteres.
2. **Nulabilidade condicional para membros especiais (`-1` e `-2`):** atributos não textuais de `dim_tempo` (`data`, `ano`, `trimestre`, `mes`, `dia`, `dia_semana`, `fim_de_semana`, `feriado`), `dim_gravidade.nivel_gravidade` e `dim_localidade.cod_ibge` aceitam `NULL` exclusivamente quando a chave substituta é `-1` ou `-2`, mantendo obrigatoriedade (`CHECK`) para todos os registros reais (`sk > 0`).
3. **Compatibilidade de drivers na execução do DDL:** os comentários `COMMENT ON` evitam o caractere literal `%` para permitir que o arquivo `.sql` seja executado diretamente tanto via `psycopg2` quanto via SQLAlchemy (`text()` / `exec_driver_sql()`).
