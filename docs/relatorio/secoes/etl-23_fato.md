## Tabela fato (ETL-23)

**O que foi feito:** montagem da `fato_pessoa_sinistro` no notebook `notebooks/etl/08_fato.ipynb`, com uma linha por pessoa envolvida em um sinistro. As 23 colunas aproveitadas da fonte viraram:
- 3 identificadores: `id_pessoa`, `id_sinistro` e `id_veiculo`;
- 9 chaves para as 8 dimensões, sendo duas para a `dim_tempo` (data do sinistro e data do óbito);
- 4 medidas: `idade`, `dias_ate_obito`, `flag_obito` e `qtd_pessoas`.

A saída foi salva em `data/intermediarios/fato.parquet`, com 806.977 linhas e 16 colunas, na ordem do DDL da ETL-18.

**Entradas:** cada grupo de colunas vem do mesmo arquivo que gerou a sua dimensão (saídas das ETL-13 a ETL-17) e é juntado pelo `id_pessoa`. Na execução final (ETL-26), todos apontam para o mesmo arquivo.

**Como foi validado:**
- **Totais:** 806.977 pessoas, 402.695 sinistros e 15.793 óbitos, iguais aos da base limpa. Por ano, são 260.886, 266.128 e 279.963 pessoas, iguais aos da fonte.
- **Chaves:** as 9 chaves existem nas suas dimensões e nenhuma é nula. As funções de busca param com erro se alguma pessoa não achar chave, em vez de mandar um valor inesperado para o -1.
- **Regras do DDL:** todas as `CHECK` da tabela valem, inclusive a coerência do óbito: quem não morreu tem data e local do óbito -2 e `dias_ate_obito` nulo.
- **Medidas:** `dias_ate_obito` é igual à diferença entre as duas datas nos 15.793 óbitos.
- **Ida e volta:** ligando a fato às dimensões, cada pessoa recupera exatamente os valores da base limpa nas 16 colunas comparadas (gravidade, perfil, transporte, via, município, profissão, local do óbito e datas).
- **Compatibilidade:** o notebook rodou com pandas 3 e 2.3.3 sem avisos.

**Membros especiais na fato:**

| Chave | -1 (NÃO INFORMADO) | -2 (NÃO SE APLICA) |
| --- | --- | --- |
| `sk_data_obito` | 0 | 791.184 |
| `sk_local_obito` | 105 | 791.184 |
| `sk_gravidade` | 70.314 | 0 |
| `sk_transporte` | 98.947 | 0 |
| `sk_profissao` | 86.834 | 0 |
| `sk_perfil_vitima` | 3.395 | 0 |
| `sk_via` | 663 | 0 |
| `sk_data_sinistro`, `sk_localidade` | 0 | 0 |

**Consulta de teste no esquema estrela:** a letalidade é maior nos feriados que nos fins de semana, e nos fins de semana maior que nos dias úteis.

| Tipo de dia | Pessoas | Óbitos | Letalidade |
| --- | --- | --- | --- |
| Dia útil | 554.750 | 9.243 | 1,67% |
| Fim de semana | 234.889 | 6.039 | 2,57% |
| Feriado | 17.338 | 511 | 2,95% |

**Próximo passo:** a ETL-24 carrega no PostgreSQL primeiro as 8 dimensões e depois a fato, por causa das chaves estrangeiras.
