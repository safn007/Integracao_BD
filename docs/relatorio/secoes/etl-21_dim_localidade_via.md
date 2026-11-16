## dim_localidade e dim_via (ETL-21)

**O que foi feito:** criação das dimensões `dim_localidade` e `dim_via` do modelo estrela no notebook [`notebooks/etl/07c_dim_localidade_via.ipynb`](../../../notebooks/etl/07c_dim_localidade_via.ipynb). Ambas possuem chave substituta `sk_*` sequencial a partir de `1`, ordenação determinística e os membros especiais `-1` (`NÃO INFORMADO`) e `-2` (`NÃO SE APLICA`). Os arquivos foram salvos em `data/intermediarios/dims/`.

**Entradas:** para refletir as limpezas já consolidadas nas etapas anteriores, `dim_localidade` lê `data/intermediarios/03_texto.parquet` (saída da `ETL-14`, com apóstrofos `D'OESTE` / `D'ALHO` e espaços normalizados) e `dim_via` lê `data/intermediarios/05_nulos_categorias.parquet` (saída da `ETL-16`, com nulos e `NAO DISPONIVEL` padronizados para `NÃO INFORMADO`). Na execução encadeada final (`ETL-26`), ambas passam a apontar para `06_limpo.parquet`.

**Resultado:**
- `dim_localidade`: **647 linhas**, sendo **645 municípios** paulistas ordenados por `cod_ibge` crescente (`3500105` a `3557303`, distribuídos em 16 regiões administrativas) e os **2 membros especiais** (`-1` e `-2` com `cod_ibge` nulo em `Int64`, compatível com o DDL em [`sql/ddl/etl_star_schema.sql`](../../../sql/ddl/etl_star_schema.sql)).
- `dim_via`: **10 linhas**, sendo **8 combinações reais** de `(tipo_via, local_via)` ordenadas alfabeticamente e os **2 membros especiais** (`-1` e `-2`).

**Tratamento de `('NÃO INFORMADO', 'NÃO INFORMADO')` em `dim_via`:** das 9 combinações presentes na base tratada pela `ETL-16`, a combinação dupla `('NÃO INFORMADO', 'NÃO INFORMADO')` (**663 pessoas**) não recebe chave positiva própria e passa a apontar diretamente para o membro **`-1`**, respeitando a restrição `UNIQUE (tipo_via, local_via)` do PostgreSQL. As combinações parciais em que apenas um atributo é conhecido (ex.: `VIAS URBANAS` + `NÃO INFORMADO`, com 107.156 pessoas; `ESTRADAS E RODOVIAS` + `NÃO INFORMADO`, com 19.757; `NÃO INFORMADO` + `PUBLICO`, com 303; `NÃO INFORMADO` + `PRIVADO`, com 7) permanecem com `sk_via > 0`. Por essa razão, a tabela final tem **10 linhas** (frente à estimativa inicial de ~11 linhas no modelo lógico).

**Como foi validado:**
- alinhamento de `id_pessoa` entre as duas entradas (`806.977` pessoas);
- relação 1:1 confirmada entre `cod_ibge` e `municipio`, e 1 única `regiao_administrativa` por município;
- ausência de municípios com `D OESTE` / `D ALHO` sem apóstrofo e ausência de `NaN` ou `NAO DISPONIVEL` em `tipo_via` e `local_via`;
- chaves `sk_localidade` e `sk_via` únicas e sequenciais, zero duplicatas nas chaves naturais e comprimentos dentro dos limites `VARCHAR` do DDL;
- cobertura de **100%** na base: todas as `806.977` pessoas recebem chave válida (`0` sem chave; em `dim_localidade`, todas usam `sk > 0`; em `dim_via`, `806.314` usam `sk > 0` e `663` usam `-1`).

**Para a ETL-23 (tabela fato):** o notebook disponibiliza as funções `atribuir_sk_localidade` e `atribuir_sk_via`, que mapeiam cada registro da base limpa para as respectivas chaves substitutas.
