## dim_profissao e dim_local_obito (ETL-22)

**O que foi feito:** criação das duas últimas dimensões descritivas do modelo estrela, `dim_profissao` e `dim_local_obito`, no notebook `notebooks/etl/07d_dim_profissao_local_obito.ipynb`. Cada uma tem chave substituta `sk_` e os membros especiais -1 (NÃO INFORMADO) e -2 (NÃO SE APLICA). Os arquivos foram salvos em `data/intermediarios/dims/`.

**Entradas:** a profissão e o `grupo_profissao` vêm da saída da ETL-17, e o local do óbito vem da saída da ETL-16.

**Resultado:**
- `dim_profissao`: 561 linhas, sendo 559 profissões padronizadas (cada uma com seu `grupo_profissao`, em 12 grupos) e os 2 membros especiais.
- `dim_local_obito`: 5 linhas, sendo 3 locais (estabelecimento de saúde, via e outros) e os 2 membros especiais.

**Nulos escondidos na profissão:** as grafias `NAO INFORMADA` (636 pessoas) e `NAO INFORMADO` (298) são "não informado" escrito como se fosse profissão, e a ETL-17 as deixou no grupo `OUTROS`. Elas passam a usar o membro -1, que reúne 86.834 pessoas: 85.900 com o campo vazio e 934 com essas grafias. `SEM PROFISSAO DEFINIDA` (9 pessoas) é uma resposta e continua como profissão.

**Local do óbito:** 791.184 pessoas usam o -2 (não morreram) e 105 usam o -1 (morreram, sem local informado). Os 15.793 óbitos se dividem em 7.940 em estabelecimento de saúde, 7.214 na via e 534 em outros locais.

**Como foi validado:**
- as chaves são únicas e nenhum nome se repete;
- cada profissão tem um grupo só;
- as 806.977 pessoas encontram uma chave nas duas dimensões;
- `NÃO SE APLICA` no local do óbito é exatamente quem não morreu;
- o notebook rodou com pandas 3.0.5 e 2.3.3, com os mesmos resultados.

**Limitação conhecida:** o membro -2 da `dim_profissao` não é usado, porque todas as pessoas têm profissão ou "não informada". Ele existe só para seguir a regra do modelo de que toda dimensão tem os dois membros.

**Para a ETL-23:** o notebook traz as funções `atribuir_sk_profissao` e `atribuir_sk_local_obito`, que ligam cada pessoa à sua chave. Se a ETL-17 passar a tratar `NAO INFORMADA` e `NAO INFORMADO` como nulo, esta etapa continua valendo sem mudar.
