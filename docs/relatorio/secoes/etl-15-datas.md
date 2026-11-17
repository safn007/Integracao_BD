## Remoção das colunas derivadas das datas e nova coluna dias_ate_obito (ETL-15)

**O que foi feito:** Uso do arquivo 01_bruro.parquet para analisar as colunas de data_sinistro e data_obito e suas derivadas. Por fim, após a análise de possíveis inconsistências, foi feita a remoção das colunas derivadas (8 no total) e o cálculo da coluna dias até óbito.

**Por quê:** O objetivo foi observar se havia divergências entre colunas do tipo datas_XXX e suas derivadas (ano_XXX, mes_XXX, dia_XXX, ano_mes_XXX), datas ausentes e registros de óbitos anteriores ao sinistro. 

**O que foi conferido:**
- Não houve inconsistências dos tipos citados acima, permitindo a remoção das colunas derivadas sem receio.
- o total de linhas permanece o mesmo (806977).

**O que foi acrescentado:** `dias_ate_obito` (tipo Int64), para melhorar a visualização da relação entre data_sinistro e data_obito. A tabela final tem 26 colunas.

**Observação:** o `.parquet` não vai para o Git. Quem precisar dele roda este notebook.