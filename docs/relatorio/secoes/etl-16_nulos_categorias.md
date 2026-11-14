## Nulos e categorias (ETL-16)

**O que foi feito:** tratamento dos nulos e das categorias dos 36 arquivos (2021 a 2023, 806.977 linhas). Nenhuma linha foi removida. O resultado foi salvo em `data/intermediarios/05_nulos_categorias.parquet` (806.977 linhas × 34 colunas).

**Por quê:** um campo vazio pode significar "não se aplica" ou "não informado". Separar os dois evita que o banco trate como a mesma coisa casos diferentes.

**O que mudou:**
- Criada a coluna `flag_obito` (True se `data_obito` está preenchida): 15.793 óbitos (1,96%) e 791.184 sem óbito.
- Veículo nulo (169.301 linhas, 20,98%): em `tipo_veiculo_vitima` e `modo_transporte_vitima`, pedestre virou `NÃO SE APLICA` (46.173 linhas em `tipo_veiculo_vitima`) e os demais viraram `NÃO INFORMADO` (123.128 linhas).
- Hipótese dos pedestres: só se confirma em parte. Entre as linhas sem veículo, 27,3% são pedestres (26,2% em 2021, 30,4% em 2022, 25,5% em 2023), 58,2% têm tipo de vítima `NAO DISPONIVEL` e 14,5% são passageiros ou condutores, que deveriam ter veículo.
- `profissao`, `nacionalidade` e `local_via` vazios viraram `NÃO INFORMADO`. `local_obito` vazio virou `NÃO SE APLICA` para quem não morreu.
- `grau_de_instrucao`: está preenchido em apenas 20% a 23% das linhas em todos os 36 meses, então não existe período confiável. Os 632.289 nulos (78,35%) viraram `NÃO INFORMADO`.
- Idades: nenhuma inválida (mínimo 0 e máximo 102, 99 e 100 por ano). 8.389 idades nulas (1,04%) foram mantidas como nulo.
- `idade`, `id_veiculo`, `ano_obito`, `mes_obito` e `dia_obito` passaram de decimal para inteiro (`Int64`, que aceita nulo).

**O que continua nulo, de propósito:** `id_veiculo` (21,04%, identificador numérico), `idade` (1,04%) e as colunas de data e tempo de óbito (98,04%, quem não morreu).