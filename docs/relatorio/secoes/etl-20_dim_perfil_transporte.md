## dim_perfil_vitima e dim_transporte (ETL-20)

**O que foi feito:** criação das duas dimensões de combinações do modelo estrela, a partir da saída da ETL-16. Cada uma tem uma linha por combinação que existe nos dados, uma chave substituta `sk_` e os membros especiais -1 (NÃO INFORMADO) e -2 (NÃO SE APLICA). Os arquivos foram salvos em `data/intermediarios/dims/`.

**Resultado:**
- `dim_transporte`: 25 linhas (23 combinações de tipo de vítima, modo de transporte e tipo de veículo)
- `dim_perfil_vitima`: 1.500 linhas (1.498 combinações de sexo, faixas etárias, nacionalidade e grau de instrução)

**O que foi conferido:** as chaves são únicas, nenhuma combinação se repete e as 806.977 pessoas encontram uma chave nas duas dimensões.

**Observação:** combinações em que todas as colunas são NÃO INFORMADO não viram linha própria, elas usam o membro -1. A idade exata fica na tabela fato, como no modelo.

**Observação 2:** `nacionalidade` ainda pode ter espaços no fim do texto, que são tratados na ETL-14. Quando essa etapa entrar, o número de combinações pode diminuir um pouco.