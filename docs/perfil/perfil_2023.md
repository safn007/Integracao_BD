# Perfil da base: 2023

> Gerado por `src/perfil.py` (ETL-06). As seções 1 a 10 respondem as 10 perguntas padrão e aparecem sempre na mesma ordem, em todos os anos. Escreva as respostas depois de gerar e não gere de novo por cima do arquivo editado.

## 1. Quantas linhas e quantos sinistros distintos há? Qual a média de pessoas por sinistro?

| métrica | valor |
| --- | --- |
| Linhas | 279.963 |
| Colunas | 32 |
| Sinistros distintos (id_sinistro) | 142.130 |
| Pessoas por sinistro: média | 1,97 |
| Pessoas por sinistro: mediana | 2,00 |
| Pessoas por sinistro: máximo | 45 |

**Resposta:** A base de 2023 tem 279.963 linhas e 142.130 sinistros distintos, com média de 1,97 pessoas por sinistro (mediana 2, máximo 45). As 32 colunas são as 31 da fonte mais `arquivo_origem`, criada para identificar o mês de cada linha.

## 2. Qual o % de nulos de cada coluna?

| coluna | nulos | % nulos |
| --- | --- | --- |
| id_sinistro | 0 | 0,00 |
| id_pessoa | 0 | 0,00 |
| id_veiculo | 60.951 | 21,77 |
| cod_ibge | 0 | 0,00 |
| municipio | 0 | 0,00 |
| regiao_administrativa | 0 | 0,00 |
| tipo_via | 0 | 0,00 |
| tipo_veiculo_vitima | 60.843 | 21,73 |
| tipo_de_vitima | 0 | 0,00 |
| modo_transporte_vitima | 59.606 | 21,29 |
| sexo | 0 | 0,00 |
| idade | 1.117 | 0,40 |
| gravidade_lesao | 0 | 0,00 |
| faixa_etaria_demografica | 0 | 0,00 |
| faixa_etaria_legal | 0 | 0,00 |
| profissao | 34.158 | 12,20 |
| grau_de_instrucao | 220.921 | 78,91 |
| nacionalidade | 36.756 | 13,13 |
| data_sinistro | 0 | 0,00 |
| ano_sinistro | 0 | 0,00 |
| mes_sinistro | 0 | 0,00 |
| dia_sinistro | 0 | 0,00 |
| ano_mes_sinistro | 0 | 0,00 |
| data_obito | 274.473 | 98,04 |
| ano_obito | 274.473 | 98,04 |
| mes_obito | 274.473 | 98,04 |
| dia_obito | 274.473 | 98,04 |
| ano_mes_obito | 274.473 | 98,04 |
| local_obito | 274.473 | 98,04 |
| local_via | 3.856 | 1,38 |
| tempo_sinistro_obito | 274.473 | 98,04 |
| arquivo_origem | 0 | 0,00 |

**Resposta:** A maioria das colunas não tem nulos. As exceções são `grau_de_instrucao` (78,91%), `id_veiculo` (21,77%), `tipo_veiculo_vitima` (21,73%), `modo_transporte_vitima` (21,29%), `nacionalidade` (13,13%), `profissao` (12,20%), `local_via` (1,38%) e `idade` (0,40%). As 7 colunas de óbito têm 274.473 nulos cada (98,04%), nas mesmas linhas, porque só quem morreu tem data, local e tempo de óbito.

## 3. Quais os domínios (valores e contagens) de gravidade_lesao, tipo_de_vitima, sexo, tipo_via, tipo_veiculo_vitima e regiao_administrativa?

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 122.521 | 43,76 |
| ILESO | 110.222 | 39,37 |
| NAO DISPONIVEL | 27.739 | 9,91 |
| GRAVE | 13.991 | 5,00 |
| FATAL | 5.490 | 1,96 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 128.962 | 46,06 |
| PASSAGEIRO | 93.295 | 33,32 |
| NAO DISPONIVEL | 42.182 | 15,07 |
| PEDESTRE | 15.524 | 5,55 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 200.219 | 71,52 |
| FEMININO | 79.154 | 28,27 |
| NAO DISPONIVEL | 590 | 0,21 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 232.761 | 83,14 |
| ESTRADAS E RODOVIAS | 46.905 | 16,75 |
| NAO DISPONIVEL | 297 | 0,11 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 107.138 | 38,27 |
| MOTOCICLETA | 95.084 | 33,96 |
| (nulo) | 60.843 | 21,73 |
| CAMINHAO | 7.554 | 2,70 |
| ONIBUS | 5.960 | 2,13 |
| OUTROS | 2.843 | 1,02 |
| BICICLETA | 391 | 0,14 |
| NAO DISPONIVEL | 150 | 0,05 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 105.501 | 37,68 |
| CAMPINAS | 44.427 | 15,87 |
| SOROCABA | 18.321 | 6,54 |
| SÃO JOSÉ DOS CAMPOS | 15.860 | 5,67 |
| SÃO JOSÉ DO RIO PRETO | 15.505 | 5,54 |
| BAIXADA SANTISTA | 13.428 | 4,80 |
| RIBEIRÃO PRETO | 11.614 | 4,15 |
| MARÍLIA | 9.092 | 3,25 |
| CENTRAL | 8.132 | 2,90 |
| PRESIDENTE PRUDENTE | 8.123 | 2,90 |
| BAURU | 7.910 | 2,83 |
| ARAÇATUBA | 7.569 | 2,70 |
| FRANCA | 6.183 | 2,21 |
| BARRETOS | 3.526 | 1,26 |
| ITAPEVA | 2.964 | 1,06 |
| REGISTRO | 1.808 | 0,65 |

**Resposta:** `gravidade_lesao` tem 5 valores (LEVE 43,76%, ILESO 39,37%, NAO DISPONIVEL 9,91%, GRAVE 5,00%, FATAL 1,96%). `tipo_de_vitima` tem 4 (CONDUTOR 46,06%, PASSAGEIRO 33,32%, NAO DISPONIVEL 15,07%, PEDESTRE 5,55%). `sexo` tem 3 (MASCULINO 71,52%, FEMININO 28,27%, NAO DISPONIVEL 0,21%). `tipo_via` tem 3 (VIAS URBANAS 83,14%, ESTRADAS E RODOVIAS 16,75%, NAO DISPONIVEL 0,11%). `tipo_veiculo_vitima` tem 7 valores mais nulo (AUTOMOVEL 38,27%, MOTOCICLETA 33,96%, nulo 21,73%). `regiao_administrativa` tem 16 regiões, lideradas pela Metropolitana de São Paulo (37,68%) e por Campinas (15,87%). "NAO DISPONIVEL" aparece em várias colunas e é um nulo disfarçado de texto.

## 4. Há valores com caractere inválido/acento corrompido ou com espaço sobrando?

Nomes de coluna com espaço: nenhuma.

75 valores distintos suspeitos. Motivos: `espaco_nas_pontas`, `espaco_duplo`, `caractere_invalido` (U+FFFD, controle, UTF-8 lido como latin-1) e `letra_isolada` (ex.: `S O PAULO`; pode ter falso positivo).

| coluna | motivo | valores distintos | linhas |
| --- | --- | --- | --- |
| profissao | letra_isolada | 1 | 1 |
| nacionalidade | espaco_nas_pontas | 74 | 243.207 |

Detalhe (as 40 primeiras de 75):

| coluna | valor | n | motivo |
| --- | --- | --- | --- |
| profissao | `'Tecnico em raio x'` | 1 | letra_isolada |
| nacionalidade | `'BRASILEIRA          '` | 241.592 | espaco_nas_pontas |
| nacionalidade | `'BOLIVIANA           '` | 257 | espaco_nas_pontas |
| nacionalidade | `'COLOMBIANA          '` | 219 | espaco_nas_pontas |
| nacionalidade | `'PORTUGUÊS           '` | 137 | espaco_nas_pontas |
| nacionalidade | `'VENEZUELANO         '` | 113 | espaco_nas_pontas |
| nacionalidade | `'CHINÊS              '` | 87 | espaco_nas_pontas |
| nacionalidade | `'BENGALI             '` | 74 | espaco_nas_pontas |
| nacionalidade | `'JAPONÊS             '` | 74 | espaco_nas_pontas |
| nacionalidade | `'HAITIANA            '` | 49 | espaco_nas_pontas |
| nacionalidade | `'PERUANO             '` | 49 | espaco_nas_pontas |
| nacionalidade | `'ARGENTINA           '` | 47 | espaco_nas_pontas |
| nacionalidade | `'CHILENA             '` | 46 | espaco_nas_pontas |
| nacionalidade | `'ITALIANA            '` | 43 | espaco_nas_pontas |
| nacionalidade | `'BRITANICO           '` | 39 | espaco_nas_pontas |
| nacionalidade | `'ANGOLANA            '` | 38 | espaco_nas_pontas |
| nacionalidade | `'ESPANHOL            '` | 33 | espaco_nas_pontas |
| nacionalidade | `'PARAGUAIO           '` | 32 | espaco_nas_pontas |
| nacionalidade | `'LIBANÊS             '` | 29 | espaco_nas_pontas |
| nacionalidade | `'CUBANA              '` | 27 | espaco_nas_pontas |
| nacionalidade | `'ALBANÊS             '` | 25 | espaco_nas_pontas |
| nacionalidade | `'EQUATORIANA         '` | 20 | espaco_nas_pontas |
| nacionalidade | `'ALEMÃ               '` | 19 | espaco_nas_pontas |
| nacionalidade | `'ESTADUNIDENSE       '` | 14 | espaco_nas_pontas |
| nacionalidade | `'NIGERIANO           '` | 13 | espaco_nas_pontas |
| nacionalidade | `'FRANCÊS             '` | 7 | espaco_nas_pontas |
| nacionalidade | `'URUGUAIO            '` | 7 | espaco_nas_pontas |
| nacionalidade | `'TURCO               '` | 6 | espaco_nas_pontas |
| nacionalidade | `'BELGA               '` | 5 | espaco_nas_pontas |
| nacionalidade | `'BELIZENHA           '` | 5 | espaco_nas_pontas |
| nacionalidade | `'MEXICANO            '` | 5 | espaco_nas_pontas |
| nacionalidade | `'SENEGALÊS           '` | 5 | espaco_nas_pontas |
| nacionalidade | `'SUL-AFRICANO        '` | 5 | espaco_nas_pontas |
| nacionalidade | `'SUÍÇO               '` | 5 | espaco_nas_pontas |
| nacionalidade | `'SÍRIO               '` | 5 | espaco_nas_pontas |
| nacionalidade | `'TAIWANÊS            '` | 5 | espaco_nas_pontas |
| nacionalidade | `'AUSTRÍACA           '` | 4 | espaco_nas_pontas |
| nacionalidade | `'BARBADIANA          '` | 4 | espaco_nas_pontas |
| nacionalidade | `'CANADENSE           '` | 4 | espaco_nas_pontas |
| nacionalidade | `'EGÍPCIO             '` | 4 | espaco_nas_pontas |

**Resposta:** Não há caractere inválido nem acento quebrado (PORTUGUÊS, CHINÊS e outros estão corretos). O problema encontrado é espaço sobrando: os 74 valores distintos de `nacionalidade` têm espaços no fim (243.207 linhas, ex.: "BRASILEIRA" com espaços), o que exige `strip` na limpeza. O valor suspeito de `profissao` ("Tecnico em raio x") é provável falso positivo. Além disso, a verificação do notebook achou 8 municípios com o apóstrofo trocado por espaço (ex.: SANTA BARBARA D OESTE), listados em `corrompidos_2023.csv`.

## 5. Qual o % de grau_de_instrucao preenchido em cada mês?

| mês | linhas | preenchidos | % preenchido |
| --- | --- | --- | --- |
| 2023-01 | 19.286 | 4.365 | 22,63 |
| 2023-02 | 19.079 | 4.077 | 21,37 |
| 2023-03 | 23.183 | 5.030 | 21,70 |
| 2023-04 | 22.654 | 5.151 | 22,74 |
| 2023-05 | 25.582 | 5.239 | 20,48 |
| 2023-06 | 25.725 | 5.227 | 20,32 |
| 2023-07 | 25.379 | 5.252 | 20,69 |
| 2023-08 | 24.656 | 5.062 | 20,53 |
| 2023-09 | 24.337 | 4.960 | 20,38 |
| 2023-10 | 23.282 | 4.617 | 19,83 |
| 2023-11 | 22.644 | 4.843 | 21,39 |
| 2023-12 | 24.156 | 5.219 | 21,61 |

**Resposta:** `grau_de_instrucao` é preenchido em cerca de 20% a 23% das linhas em todos os meses (mínimo 19,83% em outubro, máximo 22,74% em abril). Nenhum mês é muito diferente dos outros, então o nulo não vem de um mês faltando, e sim da fonte como um todo.

## 6. Quantos óbitos há e qual o % do total? As colunas de óbito são nulas nas mesmas linhas?

| métrica | valor |
| --- | --- |
| Óbitos (data_obito preenchida) | 5.490 |
| % do total de linhas | 1,96 |
| Linhas com gravidade_lesao = FATAL | 5.490 |
| Colunas de óbito encontradas | 7 |
| Nulas nas mesmas linhas? | sim |
| Linhas com óbito parcial (inconsistentes) | 0 |

**Resposta:** Há 5.490 óbitos (1,96% do total), o mesmo número de linhas com gravidade FATAL. As 7 colunas de óbito são nulas nas mesmas linhas e não há óbito parcial (0 linhas inconsistentes).

## 7. Há id_pessoa repetido? E linhas 100% idênticas?

| métrica | valor |
| --- | --- |
| id_pessoa nulo | 0 |
| id_pessoa que aparece mais de uma vez | 0 |
| Linhas com id_pessoa repetido | 0 |
| Linhas excedentes por id_pessoa | 0 |
| Linhas 100% idênticas (excedentes, sem as colunas de rastreio) | 0 |

**Resposta:** Não. `id_pessoa` é único (0 repetidos e 0 nulos) e não há linhas 100% idênticas.

## 8. Há linhas cujo mês de data_sinistro difere do mês do arquivo de origem?

| métrica | valor |
| --- | --- |
| Linhas comparáveis (mês do arquivo e da data conhecidos) | 279.963 |
| Linhas com mês divergente | 0 |
| % divergente | 0,00 |
| data_sinistro nula | 0 |
| data_sinistro preenchida mas inválida | 0 |
| arquivo_origem fora do padrão pessoas_MM-AAAA | 0 |

**Resposta:** Não. Nas 279.963 linhas, nenhuma (0,00%) tem o mês de `data_sinistro` diferente do mês do arquivo. Não há datas nulas nem inválidas, e todos os arquivos seguem o padrão `pessoas_MM-AAAA`.

## 9. Quais o mínimo, o máximo e os valores impossíveis de idade?

| métrica | valor |
| --- | --- |
| Mínimo observado | 0,00 |
| Máximo observado | 100,00 |
| Fora de 0 a 110 | 0 |
| Exemplos fora do intervalo | — |
| Nulas | 1.117 |
| Preenchidas mas não numéricas | 0 |

**Resposta:** A idade mínima é 0 e a máxima é 100. Nenhum valor fica fora de 0 a 110 e nenhum é não numérico. Há 1.117 idades nulas (0,40%).

## 10. Há algo novo ou estranho (colunas novas ou ausentes, colunas constantes ou 100% nulas)?

- Colunas esperadas que faltam: nenhuma
- Colunas novas (fora das 31 da fonte e do rastreio): nenhuma
- Ordem das colunas diferente da fonte: não
- Colunas com um único valor: `ano_sinistro` (em um perfil de um ano ou de um mês, as colunas de ano e de mês são constantes: é esperado)
- Colunas 100% nulas: nenhuma

**Resposta:** Nada novo ou estranho. Não faltam colunas, não há colunas novas, a ordem é a mesma da fonte e nenhuma coluna é 100% nula. A única coluna constante é `ano_sinistro` (2023), o que é esperado em um perfil de um ano só.

## Anexo A. Linhas por mês de data_sinistro

| mês | linhas | % |
| --- | --- | --- |
| 2023-01 | 19.286 | 6,89 |
| 2023-02 | 19.079 | 6,81 |
| 2023-03 | 23.183 | 8,28 |
| 2023-04 | 22.654 | 8,09 |
| 2023-05 | 25.582 | 9,14 |
| 2023-06 | 25.725 | 9,19 |
| 2023-07 | 25.379 | 9,07 |
| 2023-08 | 24.656 | 8,81 |
| 2023-09 | 24.337 | 8,69 |
| 2023-10 | 23.282 | 8,32 |
| 2023-11 | 22.644 | 8,09 |
| 2023-12 | 24.156 | 8,63 |

## Anexo B. Valores distintos por coluna

| coluna | valores distintos |
| --- | --- |
| id_sinistro | 142.130 |
| id_pessoa | 279.963 |
| id_veiculo | 190.652 |
| cod_ibge | 645 |
| municipio | 645 |
| regiao_administrativa | 16 |
| tipo_via | 3 |
| tipo_veiculo_vitima | 7 |
| tipo_de_vitima | 4 |
| modo_transporte_vitima | 8 |
| sexo | 3 |
| idade | 100 |
| gravidade_lesao | 5 |
| faixa_etaria_demografica | 20 |
| faixa_etaria_legal | 15 |
| profissao | 658 |
| grau_de_instrucao | 3 |
| nacionalidade | 74 |
| data_sinistro | 365 |
| ano_sinistro | 1 |
| mes_sinistro | 12 |
| dia_sinistro | 31 |
| ano_mes_sinistro | 12 |
| data_obito | 379 |
| ano_obito | 2 |
| mes_obito | 12 |
| dia_obito | 31 |
| ano_mes_obito | 13 |
| local_obito | 4 |
| local_via | 3 |
| tempo_sinistro_obito | 31 |
| arquivo_origem | 12 |

## Anexo C. Os 10 valores mais frequentes de cada coluna categórica

### municipio

| valor | n | % |
| --- | --- | --- |
| SAO PAULO | 63.692 | 22,75 |
| RIBEIRAO PRETO | 7.512 | 2,68 |
| CAMPINAS | 7.111 | 2,54 |
| GUARULHOS | 6.688 | 2,39 |
| SAO JOSE DO RIO PRETO | 5.693 | 2,03 |
| SAO BERNARDO DO CAMPO | 5.096 | 1,82 |
| SOROCABA | 4.739 | 1,69 |
| SANTO ANDRE | 4.076 | 1,46 |
| SAO JOSE DOS CAMPOS | 4.068 | 1,45 |
| FRANCA | 3.803 | 1,36 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 105.501 | 37,68 |
| CAMPINAS | 44.427 | 15,87 |
| SOROCABA | 18.321 | 6,54 |
| SÃO JOSÉ DOS CAMPOS | 15.860 | 5,67 |
| SÃO JOSÉ DO RIO PRETO | 15.505 | 5,54 |
| BAIXADA SANTISTA | 13.428 | 4,80 |
| RIBEIRÃO PRETO | 11.614 | 4,15 |
| MARÍLIA | 9.092 | 3,25 |
| CENTRAL | 8.132 | 2,90 |
| PRESIDENTE PRUDENTE | 8.123 | 2,90 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 232.761 | 83,14 |
| ESTRADAS E RODOVIAS | 46.905 | 16,75 |
| NAO DISPONIVEL | 297 | 0,11 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 107.138 | 38,27 |
| MOTOCICLETA | 95.084 | 33,96 |
| (nulo) | 60.843 | 21,73 |
| CAMINHAO | 7.554 | 2,70 |
| ONIBUS | 5.960 | 2,13 |
| OUTROS | 2.843 | 1,02 |
| BICICLETA | 391 | 0,14 |
| NAO DISPONIVEL | 150 | 0,05 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 128.962 | 46,06 |
| PASSAGEIRO | 93.295 | 33,32 |
| NAO DISPONIVEL | 42.182 | 15,07 |
| PEDESTRE | 15.524 | 5,55 |

### modo_transporte_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 107.138 | 38,27 |
| MOTOCICLETA | 95.084 | 33,96 |
| (nulo) | 59.606 | 21,29 |
| CAMINHAO | 7.554 | 2,70 |
| ONIBUS | 5.960 | 2,13 |
| OUTROS | 2.843 | 1,02 |
| PEDESTRE | 1.268 | 0,45 |
| BICICLETA | 360 | 0,13 |
| NAO DISPONIVEL | 150 | 0,05 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 200.219 | 71,52 |
| FEMININO | 79.154 | 28,27 |
| NAO DISPONIVEL | 590 | 0,21 |

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 122.521 | 43,76 |
| ILESO | 110.222 | 39,37 |
| NAO DISPONIVEL | 27.739 | 9,91 |
| GRAVE | 13.991 | 5,00 |
| FATAL | 5.490 | 1,96 |

### faixa_etaria_demografica

| valor | n | % |
| --- | --- | --- |
| 20 a 24 | 42.064 | 15,02 |
| 25 a 29 | 37.175 | 13,28 |
| 30 a 34 | 32.047 | 11,45 |
| 35 a 39 | 31.302 | 11,18 |
| 40 a 44 | 30.445 | 10,87 |
| 45 a 49 | 23.788 | 8,50 |
| 50 a 54 | 18.761 | 6,70 |
| 15 a 19 | 15.648 | 5,59 |
| 55 a 59 | 14.509 | 5,18 |
| 60 a 64 | 10.641 | 3,80 |

### faixa_etaria_legal

| valor | n | % |
| --- | --- | --- |
| 18-24 | 53.039 | 18,95 |
| 25-29 | 37.175 | 13,28 |
| 30-34 | 32.047 | 11,45 |
| 35-39 | 31.302 | 11,18 |
| 40-44 | 30.445 | 10,87 |
| 45-49 | 23.788 | 8,50 |
| 50-54 | 18.761 | 6,70 |
| 55-59 | 14.509 | 5,18 |
| 60-64 | 10.641 | 3,80 |
| 0-17 | 10.241 | 3,66 |

### profissao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 34.158 | 12,20 |
| MOTORISTA | 24.786 | 8,85 |
| AUTONOMO(A) | 16.015 | 5,72 |
| MOTO-BOY | 14.362 | 5,13 |
| APOSENTADO(A) | 13.038 | 4,66 |
| ESTUDANTE | 10.823 | 3,87 |
| AJUDANTE | 7.585 | 2,71 |
| OUTRA | 7.028 | 2,51 |
| DO LAR | 5.922 | 2,12 |
| VENDEDOR(A) | 5.576 | 1,99 |

### grau_de_instrucao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 220.921 | 78,91 |
| SUPERIOR | 35.463 | 12,67 |
| MÉDIO | 15.711 | 5,61 |
| BÁSICO | 7.868 | 2,81 |

### nacionalidade

| valor | n | % |
| --- | --- | --- |
| BRASILEIRA           | 241.592 | 86,29 |
| (nulo) | 36.756 | 13,13 |
| BOLIVIANA            | 257 | 0,09 |
| COLOMBIANA           | 219 | 0,08 |
| PORTUGUÊS            | 137 | 0,05 |
| VENEZUELANO          | 113 | 0,04 |
| CHINÊS               | 87 | 0,03 |
| BENGALI              | 74 | 0,03 |
| JAPONÊS              | 74 | 0,03 |
| HAITIANA             | 49 | 0,02 |

### ano_mes_sinistro

| valor | n | % |
| --- | --- | --- |
| 2023/06 | 25.725 | 9,19 |
| 2023/05 | 25.582 | 9,14 |
| 2023/07 | 25.379 | 9,07 |
| 2023/08 | 24.656 | 8,81 |
| 2023/09 | 24.337 | 8,69 |
| 2023/12 | 24.156 | 8,63 |
| 2023/10 | 23.282 | 8,32 |
| 2023/03 | 23.183 | 8,28 |
| 2023/04 | 22.654 | 8,09 |
| 2023/11 | 22.644 | 8,09 |

### ano_mes_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 274.473 | 98,04 |
| 2023/12 | 576 | 0,21 |
| 2023/10 | 542 | 0,19 |
| 2023/09 | 532 | 0,19 |
| 2023/11 | 468 | 0,17 |
| 2023/08 | 456 | 0,16 |
| 2023/07 | 453 | 0,16 |
| 2023/06 | 449 | 0,16 |
| 2023/03 | 440 | 0,16 |
| 2023/05 | 415 | 0,15 |

### local_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 274.473 | 98,04 |
| ESTABELECIMENTO DE SAUDE | 2.801 | 1,00 |
| VIA | 2.489 | 0,89 |
| OUTROS | 175 | 0,06 |
| NAO DISPONIVEL | 25 | 0,01 |

### local_via

| valor | n | % |
| --- | --- | --- |
| PUBLICO | 199.603 | 71,30 |
| NAO DISPONIVEL | 75.067 | 26,81 |
| (nulo) | 3.856 | 1,38 |
| PRIVADO | 1.437 | 0,51 |
