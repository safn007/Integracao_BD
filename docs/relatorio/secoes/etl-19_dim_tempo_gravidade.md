## dim_tempo e dim_gravidade (ETL-19)

**O que foi feito:** criação da `dim_tempo` e da `dim_gravidade` no notebook `notebooks/etl/07a_dim_tempo_gravidade.ipynb`, com as colunas do DDL da ETL-18 e os membros especiais -1 (NÃO INFORMADO) e -2 (NÃO SE APLICA). Os arquivos foram salvos em `data/intermediarios/dims/`. A tarefa era do Samuel e foi assumida pelo Davi.

**Entradas:** as datas vêm da saída da ETL-15 e a `gravidade_lesao` vem da saída da ETL-16, que deixou o `NAO DISPONIVEL` dessa coluna para esta etapa.

**Resultado:**
- `dim_tempo`: 1.121 linhas, sendo 1.119 dias (de 01/01/2021 a 24/01/2024, a maior data de óbito) e os 2 membros especiais. A chave é a data no formato `AAAAMMDD`. A tabela tem trimestre, nome do mês, `ano_mes`, dia da semana (1 = segunda ... 7 = domingo), fim de semana e feriado.
- `dim_gravidade`: 6 linhas, sendo ILESO, LEVE, GRAVE e FATAL, com `nivel_gravidade` de 0 a 3, e os 2 membros especiais.

**Feriados:** entram só os nacionais, como proposto no modelo estrela. São 28 no período: 9 por ano de 2021 a 2023 e 1 em janeiro de 2024. Os 9 de cada ano são os 8 de data fixa e a Sexta-feira Santa, calculada a partir da Páscoa. Ficam de fora:
- Carnaval e Corpus Christi, que são ponto facultativo;
- os feriados estaduais de SP;
- o Dia da Consciência Negra, que só virou feriado nacional em 2024.

**Membros especiais:**
- O `NAO DISPONIVEL` da gravidade vai para o -1 (70.314 pessoas, 8,71%).
- Na data do óbito, o -2 é exatamente quem não morreu (791.184 pessoas).
- Na `dim_tempo`, os membros especiais têm data e números nulos, e os textos recebem o rótulo, como permite o DDL.

**Como foi validado:**
- o calendário não tem buracos e as chaves são únicas;
- os textos cabem nos tamanhos do DDL;
- os dias reais têm todos os campos obrigatórios da regra `chk_dim_tempo_campos_validos`;
- as 806.977 pessoas acham chave nas duas datas e na gravidade;
- a gravidade FATAL coincide com os 15.793 óbitos;
- o notebook rodou com pandas 3 e 2.3.3 sem avisos.

**Achado:** nos feriados há menos pessoas envolvidas por dia (642) do que nos dias úteis (730) e nos fins de semana (763).
