## Carga no PostgreSQL (ETL-24)

**O que foi feito:** criação das 9 tabelas do modelo estrela no PostgreSQL (Supabase) pelo DDL da ETL-18 e carga das 8 dimensões e da fato.

**Como foi carregado:** `COPY` em lotes de 100 mil linhas, a partir dos parquets. As dimensões entram primeiro e a fato por último, porque ela aponta para as chaves delas.

**Rodar mais de uma vez:** o DDL começa apagando e recriando as tabelas, então cada execução carrega do zero e não duplica nada.

**Resultado:**

| Tabela | Linhas |
|---|---|
| dim_tempo | 1.121 |
| dim_gravidade | 6 |
| dim_perfil_vitima | 1.500 |
| dim_transporte | 25 |
| dim_localidade | 647 |
| dim_via | 10 |
| dim_profissao | 561 |
| dim_local_obito | 5 |
| fato_pessoa_sinistro | 806.977 |

**O que foi conferido:** a contagem de cada tabela no banco bate com a do parquet de origem.

**Observação:** colunas que vinham como float com valores inteiros (por exemplo 12.0) são convertidas antes da carga, senão o banco recusa. A senha do banco fica só no `.env`, que não vai para o Git.