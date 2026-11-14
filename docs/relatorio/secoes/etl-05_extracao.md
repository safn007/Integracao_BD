## Extração dos 36 CSVs (ETL-05)

**O que foi feito:** leitura dos 36 arquivos mensais (2021 a 2023) e junção em uma única tabela de 806.977 linhas. Nenhum dado foi alterado. O resultado foi salvo em `data/intermediarios/01_bruto.parquet`.

**Por quê:** as etapas seguintes leem essa tabela, em vez de abrir os 36 CSVs de novo. O parquet ocupa menos espaço e carrega mais rápido.

**O que foi conferido:**
- os 36 arquivos têm as mesmas 31 colunas, na mesma ordem
- o total é de 806.977 linhas

**O que foi acrescentado:** `ano_origem` e `arquivo_origem`, para saber de qual arquivo cada linha veio. A tabela final tem 33 colunas.

**Observação:** o `.parquet` não vai para o Git. Quem precisar dele roda este notebook.