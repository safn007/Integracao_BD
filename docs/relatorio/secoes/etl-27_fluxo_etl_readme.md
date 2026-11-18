## ETL-27 · Fluxo da ETL e guia de execução

**Responsável:** Samuel de Almeida (`@safn007`). **Revisor previsto:** Pedro Wellington (`@PedroWellington`). **Dependência:** ETL-26.

### O que foi feito e por quê

O [diagrama editável](../../diagramas/fluxo_etl.drawio) e a [versão em PNG](../../diagramas/fluxo_etl.png) documentam a ordem em que a ETL recebe, transforma e carrega os dados. O [README](../../../README.md) passou a indicar os arquivos de entrada, a configuração do ambiente, a execução do notebook final, os resultados de referência e as contribuições dos integrantes. O objetivo é que outra pessoa consiga entender e reproduzir a execução sem depender dos notebooks avulsos ou de Parquets já gerados.

### Como o fluxo funciona

1. **Extração (ETL-05).** Os 36 CSVs mensais são lidos, identificados pelo ano e pelo arquivo de origem e consolidados em `01_bruto.parquet`.
2. **Transformação (ETL-13 a ETL-17).** A sequência confere chaves e duplicatas, normaliza texto, converte datas, trata nulos e categorias e padroniza profissões. O produto comum dessas etapas é `06_limpo.parquet`.
3. **Modelo estrela (ETL-19 a ETL-23).** A base limpa alimenta as oito dimensões em `data/intermediarios/dims/`. A tabela fato combina essa mesma base com as oito dimensões e é gravada em `fato.parquet`. Cada linha da fato representa uma pessoa envolvida em um sinistro.
4. **Carga e validação (ETL-24 e ETL-25).** O DDL da ETL-18 recria as tabelas no PostgreSQL. A carga usa `COPY`, primeiro nas dimensões e depois na fato. A validação compara contagens e confere referências das chaves estrangeiras e o total de óbitos. As consultas são registradas em [`sql/validacao/etl_checks.sql`](../../../sql/validacao/etl_checks.sql).

### Evidência e escopo

As saídas salvas em [`notebooks/ETL.ipynb`](../../../notebooks/ETL.ipynb) registram 806.977 linhas na fato, 15.793 óbitos e zero chaves estrangeiras sem correspondência nas nove verificações. Os resultados são da [execução documentada na ETL-26](etl-26_notebook_completo.md). A ETL-27 documenta o fluxo e não cria nem altera notebooks, dados de entrada ou scripts de carga.
