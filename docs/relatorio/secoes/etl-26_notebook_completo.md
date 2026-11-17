## Notebook ETL completo, rodado do zero (ETL-26)

**O que foi feito:** criação do script [`scripts/montar_notebook_etl.py`](../../../scripts/montar_notebook_etl.py), geração do notebook unificado [`notebooks/ETL.ipynb`](../../../notebooks/ETL.ipynb) (266 células: 135 Markdown e 131 código) e execução integral do pipeline **do zero**, partindo apenas dos 36 CSVs brutos em `data/` (com `data/intermediarios/` previamente removida) até a carga completa e validação pós-carga no PostgreSQL (Supabase).

**Por quê:** consolidar em um único entregável reproduzível todas as etapas desenvolvidas de forma modular entre a ETL-05 e a ETL-25, garantindo que cada transformação e dimensão consuma a saída real da etapa anterior e que o banco final reflita exatamente o encadeamento completo.

**Decisões de implementação e encadeamento:**
- **Preservação dos notebooks individuais:** em conformidade com o [`CONTRIBUTING.md`](../../../CONTRIBUTING.md) (*"ninguém edita o notebook de outro"*), os 13 notebooks em `notebooks/etl/` foram mantidos intactos como arquivos de trabalho; o script `scripts/montar_notebook_etl.py` aplica o encadeamento de forma determinística (com verificação exata de cada substituição) ao montar `notebooks/ETL.ipynb`.
- **Setup global unificado:** imports compartilhados, localização da raiz do repositório (`RAIZ`), caminhos (`DADOS`, `INTERM`, `DIMS`), carregamento de `src/conexao.py` e `src/perfil.py` e a função `diagnostico()` foram centralizados no início do notebook, mantendo nas etapas apenas suas constantes e lógicas específicas.
- **Encadeamento das entradas (`01` → `10`):**
  - `03_texto_encoding` passou a ler `02_chaves_duplicatas.parquet` (em vez de `01_bruto.parquet`);
  - `04_datas` passou a ler `03_texto.parquet`;
  - `05_nulos_categorias` passou a ler `04_datas.parquet` (substituindo a leitura direta dos 36 CSVs) e recebeu dois ajustes de compatibilidade com as colunas já removidas na ETL-15: `converter_inteiros` filtra apenas as colunas presentes (`idade`, `id_veiculo`), e o acompanhamento mensal de `grau_de_instrucao` deriva `AAAA-MM` de `data_sinistro` na ausência de `ano_mes_sinistro`;
  - `06_profissao` passou a ler `05_nulos_categorias.parquet` e passou a classificar `'NAO INFORMADO'` (resultante da normalização sem acento sobre nulos preenchidos na ETL-16) no grupo `'NÃO INFORMADO'` em `grupo_profissao`;
  - As etapas de dimensões (`07a`, `07b`, `07c`, `07d`) e a montagem da tabela fato (`08_fato`) passaram a apontar todas as suas fontes para `06_limpo.parquet`.

**Resultados da execução do zero:**
- **Execução sem erros:** todas as **266 células** executaram em sequência com **0 erros** e **0 avisos** (tempo total: **220,9 s**).
- **Integridade na camada limpa (`06_limpo.parquet`):** `806.977` linhas preservadas (`260.886` em 2021, `266.128` em 2022 e `279.963` em 2023), `402.695` sinistros distintos e `15.793` óbitos.
- **Dimensões, fato e carga no PostgreSQL (Supabase):** recriação idempotente via [`sql/ddl/etl_star_schema.sql`](../../../sql/ddl/etl_star_schema.sql) e carga via `COPY` com conferência linha a linha:
  - `dim_tempo`: `1.121` linhas (`01/01/2021` a `24/01/2024` + membros `-1` e `-2`)
  - `dim_gravidade`: `6` linhas
  - `dim_perfil_vitima`: `1.500` linhas (com `nacionalidade` já sem espaços à direita)
  - `dim_transporte`: `25` linhas
  - `dim_localidade`: `647` linhas
  - `dim_via`: `10` linhas
  - `dim_profissao`: `561` linhas
  - `dim_local_obito`: `5` linhas
  - `fato_pessoa_sinistro`: `806.977` linhas × `16` colunas
- **Validação pós-carga:** `0` chaves estrangeiras órfãs nas 9 FKs da fato, `0` divergências na verificação de ida e volta nas 16 colunas comparadas contra `06_limpo.parquet`, `15.793` óbitos confirmados no banco (`4.858` em 2021, `5.445` em 2022 e `5.490` em 2023) e consultas de [`sql/validacao/etl_checks.sql`](../../../sql/validacao/etl_checks.sql) reproduzidas integralmente.

**Entregáveis:** [`scripts/montar_notebook_etl.py`](../../../scripts/montar_notebook_etl.py) e [`notebooks/ETL.ipynb`](../../../notebooks/ETL.ipynb) (com todas as saídas salvas).
