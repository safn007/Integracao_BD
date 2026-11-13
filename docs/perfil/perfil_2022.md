# Perfil da base: 2022

> Gerado por `src/perfil.py` (ETL-06). As seções 1 a 10 respondem as 10 perguntas padrão e aparecem sempre na mesma ordem, em todos os anos. Escreva as respostas depois de gerar e não gere de novo por cima do arquivo editado.

## 1. Quantas linhas e quantos sinistros distintos há? Qual a média de pessoas por sinistro?

| métrica | valor |
| --- | --- |
| Linhas | 266.128 |
| Colunas | 32 |
| Sinistros distintos (id_sinistro) | 132.358 |
| Pessoas por sinistro: média | 2,01 |
| Pessoas por sinistro: mediana | 2,00 |
| Pessoas por sinistro: máximo | 22 |

**Resposta:** A base de 2022 tem 266.128 linhas e 132.358 sinistros distintos, com média de 2,01 pessoas por sinistro (mediana 2, máximo 22). As 32 colunas são as 31 da fonte mais `arquivo_origem`, criada para identificar o mês de cada linha.

## 2. Qual o % de nulos de cada coluna?

| coluna | nulos | % nulos |
| --- | --- | --- |
| id_sinistro | 0 | 0,00 |
| id_pessoa | 0 | 0,00 |
| id_veiculo | 53.465 | 20,09 |
| cod_ibge | 0 | 0,00 |
| municipio | 0 | 0,00 |
| regiao_administrativa | 0 | 0,00 |
| tipo_via | 0 | 0,00 |
| tipo_veiculo_vitima | 53.266 | 20,02 |
| tipo_de_vitima | 0 | 0,00 |
| modo_transporte_vitima | 52.009 | 19,54 |
| sexo | 0 | 0,00 |
| idade | 3.797 | 1,43 |
| gravidade_lesao | 0 | 0,00 |
| faixa_etaria_demografica | 0 | 0,00 |
| faixa_etaria_legal | 0 | 0,00 |
| profissao | 24.816 | 9,32 |
| grau_de_instrucao | 207.112 | 77,82 |
| nacionalidade | 27.775 | 10,44 |
| data_sinistro | 0 | 0,00 |
| ano_sinistro | 0 | 0,00 |
| mes_sinistro | 0 | 0,00 |
| dia_sinistro | 0 | 0,00 |
| ano_mes_sinistro | 0 | 0,00 |
| data_obito | 260.683 | 97,95 |
| ano_obito | 260.683 | 97,95 |
| mes_obito | 260.683 | 97,95 |
| dia_obito | 260.683 | 97,95 |
| ano_mes_obito | 260.683 | 97,95 |
| local_obito | 260.683 | 97,95 |
| local_via | 3.381 | 1,27 |
| tempo_sinistro_obito | 260.683 | 97,95 |
| arquivo_origem | 0 | 0,00 |

**Resposta:** A maioria das colunas não tem nulos. As exceções são `grau_de_instrucao` (77,82%), `id_veiculo` (20,09%), `tipo_veiculo_vitima` (20,02%), `modo_transporte_vitima` (19,54%), `nacionalidade` (10,44%), `profissao` (9,32%), `idade` (1,43%) e `local_via` (1,27%). As 7 colunas de óbito têm 260.683 nulos cada (97,95%), nas mesmas linhas, porque só quem morreu tem data, local e tempo de óbito.

## 3. Quais os domínios (valores e contagens) de gravidade_lesao, tipo_de_vitima, sexo, tipo_via, tipo_veiculo_vitima e regiao_administrativa?

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 119.917 | 45,06 |
| ILESO | 108.016 | 40,59 |
| NAO DISPONIVEL | 19.027 | 7,15 |
| GRAVE | 13.723 | 5,16 |
| FATAL | 5.445 | 2,05 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 125.971 | 47,33 |
| PASSAGEIRO | 90.562 | 34,03 |
| NAO DISPONIVEL | 33.414 | 12,56 |
| PEDESTRE | 16.181 | 6,08 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 191.396 | 71,92 |
| FEMININO | 74.443 | 27,97 |
| NAO DISPONIVEL | 289 | 0,11 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 220.715 | 82,94 |
| ESTRADAS E RODOVIAS | 45.063 | 16,93 |
| NAO DISPONIVEL | 350 | 0,13 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 105.909 | 39,80 |
| MOTOCICLETA | 91.058 | 34,22 |
| (nulo) | 53.266 | 20,02 |
| CAMINHAO | 7.251 | 2,72 |
| ONIBUS | 5.703 | 2,14 |
| OUTROS | 2.387 | 0,90 |
| BICICLETA | 388 | 0,15 |
| NAO DISPONIVEL | 166 | 0,06 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 101.150 | 38,01 |
| CAMPINAS | 41.806 | 15,71 |
| SOROCABA | 17.992 | 6,76 |
| SÃO JOSÉ DO RIO PRETO | 14.872 | 5,59 |
| SÃO JOSÉ DOS CAMPOS | 14.293 | 5,37 |
| BAIXADA SANTISTA | 12.755 | 4,79 |
| RIBEIRÃO PRETO | 10.630 | 3,99 |
| MARÍLIA | 9.180 | 3,45 |
| CENTRAL | 7.797 | 2,93 |
| PRESIDENTE PRUDENTE | 7.748 | 2,91 |
| BAURU | 7.582 | 2,85 |
| ARAÇATUBA | 6.985 | 2,62 |
| FRANCA | 5.852 | 2,20 |
| BARRETOS | 3.262 | 1,23 |
| ITAPEVA | 2.579 | 0,97 |
| REGISTRO | 1.645 | 0,62 |

**Resposta:** `gravidade_lesao` tem 5 valores (LEVE 45,06%, ILESO 40,59%, NAO DISPONIVEL 7,15%, GRAVE 5,16%, FATAL 2,05%). `tipo_de_vitima` tem 4 (CONDUTOR 47,33%, PASSAGEIRO 34,03%, NAO DISPONIVEL 12,56%, PEDESTRE 6,08%). `sexo` tem 3 (MASCULINO 71,92%, FEMININO 27,97%, NAO DISPONIVEL 0,11%). `tipo_via` tem 3 (VIAS URBANAS 82,94%, ESTRADAS E RODOVIAS 16,93%, NAO DISPONIVEL 0,13%). `tipo_veiculo_vitima` tem 7 valores mais nulo (AUTOMOVEL 39,80%, MOTOCICLETA 34,22%, nulo 20,02%). `regiao_administrativa` tem 16 regiões, lideradas pela Metropolitana de São Paulo (38,01%) e por Campinas (15,71%). "NAO DISPONIVEL" aparece em várias colunas e é um nulo disfarçado de texto.

## 4. Há valores com caractere inválido/acento corrompido ou com espaço sobrando?

Nomes de coluna com espaço: nenhuma.

68 valores distintos suspeitos. Motivos: `espaco_nas_pontas`, `espaco_duplo`, `caractere_invalido` (U+FFFD, controle, UTF-8 lido como latin-1) e `letra_isolada` (ex.: `S O PAULO`; pode ter falso positivo).

| coluna | motivo | valores distintos | linhas |
| --- | --- | --- | --- |
| nacionalidade | espaco_nas_pontas | 68 | 238.353 |

Detalhe (as 40 primeiras de 68):

| coluna | valor | n | motivo |
| --- | --- | --- | --- |
| nacionalidade | `'BRASILEIRA          '` | 236.860 | espaco_nas_pontas |
| nacionalidade | `'BOLIVIANA           '` | 276 | espaco_nas_pontas |
| nacionalidade | `'COLOMBIANA          '` | 205 | espaco_nas_pontas |
| nacionalidade | `'PORTUGUÊS           '` | 151 | espaco_nas_pontas |
| nacionalidade | `'CHINÊS              '` | 85 | espaco_nas_pontas |
| nacionalidade | `'HAITIANA            '` | 69 | espaco_nas_pontas |
| nacionalidade | `'JAPONÊS             '` | 64 | espaco_nas_pontas |
| nacionalidade | `'VENEZUELANO         '` | 62 | espaco_nas_pontas |
| nacionalidade | `'ARGENTINA           '` | 54 | espaco_nas_pontas |
| nacionalidade | `'BRITANICO           '` | 41 | espaco_nas_pontas |
| nacionalidade | `'PERUANO             '` | 41 | espaco_nas_pontas |
| nacionalidade | `'PARAGUAIO           '` | 40 | espaco_nas_pontas |
| nacionalidade | `'BENGALI             '` | 38 | espaco_nas_pontas |
| nacionalidade | `'ITALIANA            '` | 36 | espaco_nas_pontas |
| nacionalidade | `'LIBANÊS             '` | 32 | espaco_nas_pontas |
| nacionalidade | `'CHILENA             '` | 30 | espaco_nas_pontas |
| nacionalidade | `'ESPANHOL            '` | 27 | espaco_nas_pontas |
| nacionalidade | `'ANGOLANA            '` | 21 | espaco_nas_pontas |
| nacionalidade | `'AFEGANE             '` | 19 | espaco_nas_pontas |
| nacionalidade | `'ALBANÊS             '` | 19 | espaco_nas_pontas |
| nacionalidade | `'CUBANA              '` | 18 | espaco_nas_pontas |
| nacionalidade | `'ESTADUNIDENSE       '` | 18 | espaco_nas_pontas |
| nacionalidade | `'FRANCÊS             '` | 12 | espaco_nas_pontas |
| nacionalidade | `'SÍRIO               '` | 12 | espaco_nas_pontas |
| nacionalidade | `'URUGUAIO            '` | 12 | espaco_nas_pontas |
| nacionalidade | `'ALEMÃ               '` | 11 | espaco_nas_pontas |
| nacionalidade | `'BARBADIANA          '` | 10 | espaco_nas_pontas |
| nacionalidade | `'BELGA               '` | 9 | espaco_nas_pontas |
| nacionalidade | `'NIGERIANO           '` | 8 | espaco_nas_pontas |
| nacionalidade | `'EQUATORIANA         '` | 7 | espaco_nas_pontas |
| nacionalidade | `'PAQUISTANÊS         '` | 5 | espaco_nas_pontas |
| nacionalidade | `'SUL-AFRICANO        '` | 5 | espaco_nas_pontas |
| nacionalidade | `'EGÍPCIO             '` | 4 | espaco_nas_pontas |
| nacionalidade | `'TAIWANÊS            '` | 4 | espaco_nas_pontas |
| nacionalidade | `'AUSTRÍACA           '` | 3 | espaco_nas_pontas |
| nacionalidade | `'MARROQUINO          '` | 3 | espaco_nas_pontas |
| nacionalidade | `'SUÍÇO               '` | 3 | espaco_nas_pontas |
| nacionalidade | `'BELIZENHA           '` | 2 | espaco_nas_pontas |
| nacionalidade | `'BRASILEIRO          '` | 2 | espaco_nas_pontas |
| nacionalidade | `'DINAMARQUÊS         '` | 2 | espaco_nas_pontas |

**Resposta:** Não há caractere inválido nem acento quebrado (PORTUGUÊS, CHINÊS e outros estão corretos). O problema encontrado é espaço sobrando: os 68 valores distintos de `nacionalidade` têm espaços no fim (238.353 linhas, ex.: "BRASILEIRA" com espaços), o que exige `strip` na limpeza. Além disso, a verificação do notebook achou 8 municípios com o apóstrofo trocado por espaço (ex.: SANTA BARBARA D OESTE), listados em `corrompidos_2022.csv`.

## 5. Qual o % de grau_de_instrucao preenchido em cada mês?

| mês | linhas | preenchidos | % preenchido |
| --- | --- | --- | --- |
| 2022-01 | 17.114 | 3.893 | 22,75 |
| 2022-02 | 20.164 | 4.433 | 21,98 |
| 2022-03 | 22.799 | 5.012 | 21,98 |
| 2022-04 | 22.761 | 5.178 | 22,75 |
| 2022-05 | 24.391 | 5.329 | 21,85 |
| 2022-06 | 23.503 | 5.164 | 21,97 |
| 2022-07 | 23.739 | 5.416 | 22,81 |
| 2022-08 | 23.696 | 5.099 | 21,52 |
| 2022-09 | 22.377 | 4.791 | 21,41 |
| 2022-10 | 23.644 | 5.254 | 22,22 |
| 2022-11 | 21.840 | 4.705 | 21,54 |
| 2022-12 | 20.100 | 4.742 | 23,59 |

**Resposta:** `grau_de_instrucao` é preenchido em cerca de 21% a 24% das linhas em todos os meses (mínimo 21,41% em setembro, máximo 23,59% em dezembro). Nenhum mês destoa dos demais, indicando que a alta proporção de nulos vem da fonte como um todo.

## 6. Quantos óbitos há e qual o % do total? As colunas de óbito são nulas nas mesmas linhas?

| métrica | valor |
| --- | --- |
| Óbitos (data_obito preenchida) | 5.445 |
| % do total de linhas | 2,05 |
| Linhas com gravidade_lesao = FATAL | 5.445 |
| Colunas de óbito encontradas | 7 |
| Nulas nas mesmas linhas? | sim |
| Linhas com óbito parcial (inconsistentes) | 0 |

**Resposta:** Há 5.445 óbitos (2,05% do total), o mesmo número de linhas com gravidade FATAL. As 7 colunas de óbito são nulas nas mesmas linhas e não há óbito parcial (0 linhas inconsistentes).

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
| Linhas comparáveis (mês do arquivo e da data conhecidos) | 266.128 |
| Linhas com mês divergente | 0 |
| % divergente | 0,00 |
| data_sinistro nula | 0 |
| data_sinistro preenchida mas inválida | 0 |
| arquivo_origem fora do padrão pessoas_MM-AAAA | 0 |

**Resposta:** Não. Nas 266.128 linhas, nenhuma (0,00%) tem o mês de `data_sinistro` diferente do mês do arquivo. Não há datas nulas nem inválidas, e todos os arquivos seguem o padrão `pessoas_MM-AAAA`.

## 9. Quais o mínimo, o máximo e os valores impossíveis de idade?

| métrica | valor |
| --- | --- |
| Mínimo observado | 0,00 |
| Máximo observado | 99,00 |
| Fora de 0 a 110 | 0 |
| Exemplos fora do intervalo | — |
| Nulas | 3.797 |
| Preenchidas mas não numéricas | 0 |

**Resposta:** A idade mínima é 0 e a máxima é 99. Nenhum valor fica fora de 0 a 110 e nenhum é não numérico. Há 3.797 idades nulas (1,43%).

## 10. Há algo novo ou estranho (colunas novas ou ausentes, colunas constantes ou 100% nulas)?

- Colunas esperadas que faltam: nenhuma
- Colunas novas (fora das 31 da fonte e do rastreio): nenhuma
- Ordem das colunas diferente da fonte: não
- Colunas com um único valor: `ano_sinistro` (em um perfil de um ano ou de um mês, as colunas de ano e de mês são constantes: é esperado)
- Colunas 100% nulas: nenhuma

**Resposta:** Nada novo ou estranho. Não faltam colunas, não há colunas novas, a ordem é a mesma da fonte e nenhuma coluna é 100% nula. A única coluna constante é `ano_sinistro` (2022), o que é esperado em um perfil de um ano só.

## Anexo A. Linhas por mês de data_sinistro

| mês | linhas | % |
| --- | --- | --- |
| 2022-01 | 17.114 | 6,43 |
| 2022-02 | 20.164 | 7,58 |
| 2022-03 | 22.799 | 8,57 |
| 2022-04 | 22.761 | 8,55 |
| 2022-05 | 24.391 | 9,17 |
| 2022-06 | 23.503 | 8,83 |
| 2022-07 | 23.739 | 8,92 |
| 2022-08 | 23.696 | 8,90 |
| 2022-09 | 22.377 | 8,41 |
| 2022-10 | 23.644 | 8,88 |
| 2022-11 | 21.840 | 8,21 |
| 2022-12 | 20.100 | 7,55 |

## Anexo B. Valores distintos por coluna

| coluna | valores distintos |
| --- | --- |
| id_sinistro | 132.358 |
| id_pessoa | 266.128 |
| id_veiculo | 185.205 |
| cod_ibge | 642 |
| municipio | 642 |
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
| profissao | 588 |
| grau_de_instrucao | 3 |
| nacionalidade | 68 |
| data_sinistro | 365 |
| ano_sinistro | 1 |
| mes_sinistro | 12 |
| dia_sinistro | 31 |
| ano_mes_sinistro | 12 |
| data_obito | 374 |
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
| SAO PAULO | 61.502 | 23,11 |
| RIBEIRAO PRETO | 6.841 | 2,57 |
| CAMPINAS | 6.840 | 2,57 |
| GUARULHOS | 6.691 | 2,51 |
| SAO JOSE DO RIO PRETO | 5.332 | 2,00 |
| SOROCABA | 5.056 | 1,90 |
| SAO BERNARDO DO CAMPO | 4.688 | 1,76 |
| JUNDIAI | 3.902 | 1,47 |
| SANTO ANDRE | 3.768 | 1,42 |
| SAO JOSE DOS CAMPOS | 3.678 | 1,38 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 101.150 | 38,01 |
| CAMPINAS | 41.806 | 15,71 |
| SOROCABA | 17.992 | 6,76 |
| SÃO JOSÉ DO RIO PRETO | 14.872 | 5,59 |
| SÃO JOSÉ DOS CAMPOS | 14.293 | 5,37 |
| BAIXADA SANTISTA | 12.755 | 4,79 |
| RIBEIRÃO PRETO | 10.630 | 3,99 |
| MARÍLIA | 9.180 | 3,45 |
| CENTRAL | 7.797 | 2,93 |
| PRESIDENTE PRUDENTE | 7.748 | 2,91 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 220.715 | 82,94 |
| ESTRADAS E RODOVIAS | 45.063 | 16,93 |
| NAO DISPONIVEL | 350 | 0,13 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 105.909 | 39,80 |
| MOTOCICLETA | 91.058 | 34,22 |
| (nulo) | 53.266 | 20,02 |
| CAMINHAO | 7.251 | 2,72 |
| ONIBUS | 5.703 | 2,14 |
| OUTROS | 2.387 | 0,90 |
| BICICLETA | 388 | 0,15 |
| NAO DISPONIVEL | 166 | 0,06 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 125.971 | 47,33 |
| PASSAGEIRO | 90.562 | 34,03 |
| NAO DISPONIVEL | 33.414 | 12,56 |
| PEDESTRE | 16.181 | 6,08 |

### modo_transporte_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 105.909 | 39,80 |
| MOTOCICLETA | 91.058 | 34,22 |
| (nulo) | 52.009 | 19,54 |
| CAMINHAO | 7.251 | 2,72 |
| ONIBUS | 5.703 | 2,14 |
| OUTROS | 2.387 | 0,90 |
| PEDESTRE | 1.283 | 0,48 |
| BICICLETA | 362 | 0,14 |
| NAO DISPONIVEL | 166 | 0,06 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 191.396 | 71,92 |
| FEMININO | 74.443 | 27,97 |
| NAO DISPONIVEL | 289 | 0,11 |

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 119.917 | 45,06 |
| ILESO | 108.016 | 40,59 |
| NAO DISPONIVEL | 19.027 | 7,15 |
| GRAVE | 13.723 | 5,16 |
| FATAL | 5.445 | 2,05 |

### faixa_etaria_demografica

| valor | n | % |
| --- | --- | --- |
| 20 a 24 | 40.696 | 15,29 |
| 25 a 29 | 35.596 | 13,38 |
| 30 a 34 | 31.323 | 11,77 |
| 35 a 39 | 30.377 | 11,41 |
| 40 a 44 | 28.294 | 10,63 |
| 45 a 49 | 21.706 | 8,16 |
| 50 a 54 | 16.961 | 6,37 |
| 15 a 19 | 13.901 | 5,22 |
| 55 a 59 | 13.439 | 5,05 |
| 60 a 64 | 9.727 | 3,66 |

### faixa_etaria_legal

| valor | n | % |
| --- | --- | --- |
| 18-24 | 50.433 | 18,95 |
| 25-29 | 35.596 | 13,38 |
| 30-34 | 31.323 | 11,77 |
| 35-39 | 30.377 | 11,41 |
| 40-44 | 28.294 | 10,63 |
| 45-49 | 21.706 | 8,16 |
| 50-54 | 16.961 | 6,37 |
| 55-59 | 13.439 | 5,05 |
| 60-64 | 9.727 | 3,66 |
| 0-17 | 9.321 | 3,50 |

### profissao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 24.816 | 9,32 |
| MOTORISTA | 23.390 | 8,79 |
| AUTONOMO(A) | 15.450 | 5,81 |
| MOTO-BOY | 13.988 | 5,26 |
| APOSENTADO(A) | 12.613 | 4,74 |
| ESTUDANTE | 10.346 | 3,89 |
| AJUDANTE | 8.064 | 3,03 |
| OUTRA | 7.275 | 2,73 |
| VENDEDOR(A) | 5.781 | 2,17 |
| DO LAR | 5.755 | 2,16 |

### grau_de_instrucao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 207.112 | 77,82 |
| SUPERIOR | 36.180 | 13,59 |
| MÉDIO | 15.124 | 5,68 |
| BÁSICO | 7.712 | 2,90 |

### nacionalidade

| valor | n | % |
| --- | --- | --- |
| BRASILEIRA           | 236.860 | 89,00 |
| (nulo) | 27.775 | 10,44 |
| BOLIVIANA            | 276 | 0,10 |
| COLOMBIANA           | 205 | 0,08 |
| PORTUGUÊS            | 151 | 0,06 |
| CHINÊS               | 85 | 0,03 |
| HAITIANA             | 69 | 0,03 |
| JAPONÊS              | 64 | 0,02 |
| VENEZUELANO          | 62 | 0,02 |
| ARGENTINA            | 54 | 0,02 |

### ano_mes_sinistro

| valor | n | % |
| --- | --- | --- |
| 2022/05 | 24.391 | 9,17 |
| 2022/07 | 23.739 | 8,92 |
| 2022/08 | 23.696 | 8,90 |
| 2022/10 | 23.644 | 8,88 |
| 2022/06 | 23.503 | 8,83 |
| 2022/03 | 22.799 | 8,57 |
| 2022/04 | 22.761 | 8,55 |
| 2022/09 | 22.377 | 8,41 |
| 2022/11 | 21.840 | 8,21 |
| 2022/02 | 20.164 | 7,58 |

### ano_mes_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 260.683 | 97,95 |
| 2022/07 | 543 | 0,20 |
| 2022/10 | 526 | 0,20 |
| 2022/08 | 489 | 0,18 |
| 2022/09 | 486 | 0,18 |
| 2022/06 | 482 | 0,18 |
| 2022/05 | 472 | 0,18 |
| 2022/04 | 445 | 0,17 |
| 2022/03 | 438 | 0,16 |
| 2022/11 | 427 | 0,16 |

### local_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 260.683 | 97,95 |
| ESTABELECIMENTO DE SAUDE | 2.774 | 1,04 |
| VIA | 2.420 | 0,91 |
| OUTROS | 197 | 0,07 |
| NAO DISPONIVEL | 54 | 0,02 |

### local_via

| valor | n | % |
| --- | --- | --- |
| PUBLICO | 239.837 | 90,12 |
| NAO DISPONIVEL | 21.389 | 8,04 |
| (nulo) | 3.381 | 1,27 |
| PRIVADO | 1.521 | 0,57 |
