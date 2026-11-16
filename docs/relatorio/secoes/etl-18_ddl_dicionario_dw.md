## DDL do esquema estrela e dicionário do DW (ETL-18)

**O que foi feito:** criação do script DDL [`sql/ddl/etl_star_schema.sql`](../../../sql/ddl/etl_star_schema.sql) para o esquema estrela no PostgreSQL (Supabase), execução idempotente no banco em nuvem e elaboração do dicionário físico e lógico do Data Warehouse em [`docs/dicionario/dicionario_dw.md`](../../dicionario/dicionario_dw.md).

**Por quê:** materializar no banco a modelagem definida na ETL-10 (`modelo_estrela.md`) com integridade referencial, restrições de domínio e metadados no catálogo antes da carga dos dados (ETL-24), além de documentar todas as tabelas, colunas, tipos físicos e regras de linhagem para consulta na etapa de análise e no relatório final.

**Estrutura criada e validada no PostgreSQL (Supabase):**
- **9 tabelas (54 colunas no total):** `fato_pessoa_sinistro` (16 colunas) + 8 dimensões (`dim_tempo` com 13, `dim_perfil_vitima` com 6, `dim_transporte` com 4, `dim_localidade` com 4, `dim_gravidade` com 3, `dim_via` com 3, `dim_profissao` com 3 e `dim_local_obito` com 2).
- **Integridade e restrições:** 9 chaves primárias (`PK`), 9 chaves estrangeiras `NOT NULL` ligando a fato às dimensões (com *role-playing* de `dim_tempo` em `sk_data_sinistro` e `sk_data_obito`), 8 restrições `UNIQUE` nas chaves naturais ou combinações de dimensão, e 21 restrições `CHECK` (cobrindo faixas de `idade` 0–120, `dias_ate_obito` 0–30, `flag_obito` ∈ {0, 1}, `qtd_pessoas = 1`, coerência entre `flag_obito` e colunas de óbito, e obrigatoriedade de atributos reais quando `sk > 0`).
- **Índices e catálogo:** 10 índices explícitos na tabela fato (`idx_fato_id_sinistro` e 1 índice por FK) e `COMMENT ON TABLE`/`COMMENT ON COLUMN` gravados nas 9 tabelas e nas 54 colunas do schema `public`.
- **Idempotência e teste de carga:** bloco inicial `DROP TABLE IF EXISTS ... CASCADE` testado em execuções sucessivas via SQLAlchemy/PostgreSQL (`exec_driver_sql`, `text()` em `AUTOCOMMIT` e transação `engine.begin()`), além de *smoke test* transacional (com *rollback*) validando a inserção dos membros especiais `-1` (`NÃO INFORMADO`) e `-2` (`NÃO SE APLICA`) junto a registros de exemplo com e sem óbito.

**Ajustes preventivos em relação à especificação lógica (`ETL-10`):**
- Ampliação de `dim_tempo.nome_mes` e `dim_tempo.nome_dia_semana` para `VARCHAR(20)` e de `dim_tempo.ano_mes` para `VARCHAR(15)` (comportando `'SEGUNDA-FEIRA'`, `'NÃO INFORMADO'` e `'NÃO SE APLICA'`, todos com 13 caracteres).
- Nulabilidade condicional nos atributos não textuais dos membros especiais `-1` e `-2` em `dim_tempo`, `dim_gravidade.nivel_gravidade` e `dim_localidade.cod_ibge`, protegida por `CHECK` para `sk > 0`.

**Entregáveis:** [`sql/ddl/etl_star_schema.sql`](../../../sql/ddl/etl_star_schema.sql) e [`docs/dicionario/dicionario_dw.md`](../../dicionario/dicionario_dw.md).
