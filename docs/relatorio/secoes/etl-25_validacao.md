## ETL-25 · Validação pós-carga

Depois da carga no PostgreSQL (ETL-24), o banco foi conferido com consultas SQL rodadas pelo notebook `notebooks/etl/10_validacao.ipynb`. As consultas ficam salvas em `sql/validacao/etl_checks.sql` e podem ser rodadas de novo a qualquer momento.

### Contagem de linhas

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

A fato tem o mesmo número de linhas da base tratada.

### Chaves estrangeiras

Para cada uma das 9 chaves da fato (a `dim_tempo` aparece duas vezes, na data do sinistro e na data do óbito) foi feito um `LEFT JOIN` procurando linhas sem correspondência na dimensão. O resultado foi 0 em todas, ou seja, nenhuma chave ficou órfã.

### Total de óbitos

A soma de `flag_obito` na fato é 15.793, o mesmo total da base original.

### Consultas de exemplo

Três consultas juntando a fato com as dimensões mostram que os relacionamentos funcionam:

- óbitos e vítimas por ano (2021: 4.858 óbitos; 2022: 5.445; 2023: 5.490);
- os 10 municípios com mais óbitos (São Paulo lidera, com 2.525);
- vítimas e óbitos por sexo e tipo de vítima.

### Arquivos

- Notebook: `notebooks/etl/10_validacao.ipynb`
- Consultas: `sql/validacao/etl_checks.sql`