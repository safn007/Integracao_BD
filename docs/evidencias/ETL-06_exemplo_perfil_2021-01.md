# Perfil da base: pessoas_01-2021

> Gerado por `src/perfil.py` (ETL-06). As seções 1 a 10 respondem as 10 perguntas padrão e aparecem sempre na mesma ordem, em todos os anos. Escreva as respostas depois de gerar e não gere de novo por cima do arquivo editado.

## 1. Quantas linhas e quantos sinistros distintos há? Qual a média de pessoas por sinistro?

| métrica | valor |
| --- | --- |
| Linhas | 19.534 |
| Colunas | 32 |
| Sinistros distintos (id_sinistro) | 9.714 |
| Pessoas por sinistro: média | 2,01 |
| Pessoas por sinistro: mediana | 2,00 |
| Pessoas por sinistro: máximo | 16 |

**Resposta:** _escreva aqui o que os números mostram._

## 2. Qual o % de nulos de cada coluna?

| coluna | nulos | % nulos |
| --- | --- | --- |
| id_sinistro | 0 | 0,00 |
| id_pessoa | 0 | 0,00 |
| id_veiculo | 3.817 | 19,54 |
| cod_ibge | 0 | 0,00 |
| municipio | 0 | 0,00 |
| regiao_administrativa | 0 | 0,00 |
| tipo_via | 0 | 0,00 |
| tipo_veiculo_vitima | 3.807 | 19,49 |
| tipo_de_vitima | 0 | 0,00 |
| modo_transporte_vitima | 3.739 | 19,14 |
| sexo | 0 | 0,00 |
| idade | 303 | 1,55 |
| gravidade_lesao | 0 | 0,00 |
| faixa_etaria_demografica | 0 | 0,00 |
| faixa_etaria_legal | 0 | 0,00 |
| profissao | 1.857 | 9,51 |
| grau_de_instrucao | 15.116 | 77,38 |
| nacionalidade | 2.193 | 11,23 |
| data_sinistro | 0 | 0,00 |
| ano_sinistro | 0 | 0,00 |
| mes_sinistro | 0 | 0,00 |
| dia_sinistro | 0 | 0,00 |
| ano_mes_sinistro | 0 | 0,00 |
| data_obito | 19.172 | 98,15 |
| ano_obito | 19.172 | 98,15 |
| mes_obito | 19.172 | 98,15 |
| dia_obito | 19.172 | 98,15 |
| ano_mes_obito | 19.172 | 98,15 |
| local_obito | 19.172 | 98,15 |
| local_via | 276 | 1,41 |
| tempo_sinistro_obito | 19.172 | 98,15 |
| arquivo_origem | 0 | 0,00 |

**Resposta:** _escreva aqui o que os números mostram._

## 3. Quais os domínios (valores e contagens) de gravidade_lesao, tipo_de_vitima, sexo, tipo_via, tipo_veiculo_vitima e regiao_administrativa?

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 8.779 | 44,94 |
| ILESO | 7.742 | 39,63 |
| NAO DISPONIVEL | 1.547 | 7,92 |
| GRAVE | 1.104 | 5,65 |
| FATAL | 362 | 1,85 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 9.236 | 47,28 |
| PASSAGEIRO | 6.715 | 34,38 |
| NAO DISPONIVEL | 2.579 | 13,20 |
| PEDESTRE | 1.004 | 5,14 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 14.191 | 72,65 |
| FEMININO | 5.087 | 26,04 |
| NAO DISPONIVEL | 256 | 1,31 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 16.054 | 82,18 |
| ESTRADAS E RODOVIAS | 3.455 | 17,69 |
| NAO DISPONIVEL | 25 | 0,13 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 8.078 | 41,35 |
| MOTOCICLETA | 6.555 | 33,56 |
| (nulo) | 3.807 | 19,49 |
| CAMINHAO | 535 | 2,74 |
| ONIBUS | 385 | 1,97 |
| OUTROS | 135 | 0,69 |
| BICICLETA | 28 | 0,14 |
| NAO DISPONIVEL | 11 | 0,06 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 7.284 | 37,29 |
| CAMPINAS | 2.797 | 14,32 |
| SOROCABA | 1.258 | 6,44 |
| BAIXADA SANTISTA | 1.210 | 6,19 |
| SÃO JOSÉ DO RIO PRETO | 1.191 | 6,10 |
| SÃO JOSÉ DOS CAMPOS | 1.189 | 6,09 |
| RIBEIRÃO PRETO | 831 | 4,25 |
| MARÍLIA | 640 | 3,28 |
| BAURU | 566 | 2,90 |
| CENTRAL | 565 | 2,89 |
| PRESIDENTE PRUDENTE | 560 | 2,87 |
| ARAÇATUBA | 488 | 2,50 |
| FRANCA | 390 | 2,00 |
| ITAPEVA | 201 | 1,03 |
| BARRETOS | 195 | 1,00 |
| REGISTRO | 169 | 0,87 |

**Resposta:** _escreva aqui o que os números mostram._

## 4. Há valores com caractere inválido/acento corrompido ou com espaço sobrando?

Nomes de coluna com espaço: nenhuma.

27 valores distintos suspeitos. Motivos: `espaco_nas_pontas`, `espaco_duplo`, `caractere_invalido` (U+FFFD, controle, UTF-8 lido como latin-1) e `letra_isolada` (ex.: `S O PAULO`; pode ter falso positivo).

| coluna | motivo | valores distintos | linhas |
| --- | --- | --- | --- |
| nacionalidade | espaco_nas_pontas | 27 | 17.341 |

Detalhe:

| coluna | valor | n | motivo |
| --- | --- | --- | --- |
| nacionalidade | `'BRASILEIRA          '` | 17.247 | espaco_nas_pontas |
| nacionalidade | `'BOLIVIANA           '` | 27 | espaco_nas_pontas |
| nacionalidade | `'COLOMBIANA          '` | 14 | espaco_nas_pontas |
| nacionalidade | `'PORTUGUÊS           '` | 8 | espaco_nas_pontas |
| nacionalidade | `'BRITANICO           '` | 4 | espaco_nas_pontas |
| nacionalidade | `'CHINÊS              '` | 4 | espaco_nas_pontas |
| nacionalidade | `'JAPONÊS             '` | 4 | espaco_nas_pontas |
| nacionalidade | `'ARGENTINA           '` | 3 | espaco_nas_pontas |
| nacionalidade | `'LIBANÊS             '` | 3 | espaco_nas_pontas |
| nacionalidade | `'PERUANO             '` | 3 | espaco_nas_pontas |
| nacionalidade | `'VENEZUELANO         '` | 3 | espaco_nas_pontas |
| nacionalidade | `'BURUNDIENÊS         '` | 2 | espaco_nas_pontas |
| nacionalidade | `'CHILENA             '` | 2 | espaco_nas_pontas |
| nacionalidade | `'ESPANHOL            '` | 2 | espaco_nas_pontas |
| nacionalidade | `'NIGERIANO           '` | 2 | espaco_nas_pontas |
| nacionalidade | `'URUGUAIO            '` | 2 | espaco_nas_pontas |
| nacionalidade | `'AFEGANE             '` | 1 | espaco_nas_pontas |
| nacionalidade | `'ALBANÊS             '` | 1 | espaco_nas_pontas |
| nacionalidade | `'BELGA               '` | 1 | espaco_nas_pontas |
| nacionalidade | `'DOMINIQUÊS          '` | 1 | espaco_nas_pontas |
| nacionalidade | `'HAITIANA            '` | 1 | espaco_nas_pontas |
| nacionalidade | `'INDIANA             '` | 1 | espaco_nas_pontas |
| nacionalidade | `'ITALIANA            '` | 1 | espaco_nas_pontas |
| nacionalidade | `'MOÇAMBICANO         '` | 1 | espaco_nas_pontas |
| nacionalidade | `'POLONÊS             '` | 1 | espaco_nas_pontas |
| nacionalidade | `'SENEGALÊS           '` | 1 | espaco_nas_pontas |
| nacionalidade | `'TAILANDÊS           '` | 1 | espaco_nas_pontas |

**Resposta:** _escreva aqui o que os números mostram._

## 5. Qual o % de grau_de_instrucao preenchido em cada mês?

| mês | linhas | preenchidos | % preenchido |
| --- | --- | --- | --- |
| 2021-01 | 19.534 | 4.418 | 22,62 |

**Resposta:** _escreva aqui o que os números mostram._

## 6. Quantos óbitos há e qual o % do total? As colunas de óbito são nulas nas mesmas linhas?

| métrica | valor |
| --- | --- |
| Óbitos (data_obito preenchida) | 362 |
| % do total de linhas | 1,85 |
| Linhas com gravidade_lesao = FATAL | 362 |
| Colunas de óbito encontradas | 7 |
| Nulas nas mesmas linhas? | sim |
| Linhas com óbito parcial (inconsistentes) | 0 |

**Resposta:** _escreva aqui o que os números mostram._

## 7. Há id_pessoa repetido? E linhas 100% idênticas?

| métrica | valor |
| --- | --- |
| id_pessoa nulo | 0 |
| id_pessoa que aparece mais de uma vez | 0 |
| Linhas com id_pessoa repetido | 0 |
| Linhas excedentes por id_pessoa | 0 |
| Linhas 100% idênticas (excedentes, sem as colunas de rastreio) | 0 |

**Resposta:** _escreva aqui o que os números mostram._

## 8. Há linhas cujo mês de data_sinistro difere do mês do arquivo de origem?

| métrica | valor |
| --- | --- |
| Linhas comparáveis (mês do arquivo e da data conhecidos) | 19.534 |
| Linhas com mês divergente | 0 |
| % divergente | 0,00 |
| data_sinistro nula | 0 |
| data_sinistro preenchida mas inválida | 0 |
| arquivo_origem fora do padrão pessoas_MM-AAAA | 0 |

**Resposta:** _escreva aqui o que os números mostram._

## 9. Quais o mínimo, o máximo e os valores impossíveis de idade?

| métrica | valor |
| --- | --- |
| Mínimo observado | 0,00 |
| Máximo observado | 97,00 |
| Fora de 0 a 110 | 0 |
| Exemplos fora do intervalo | — |
| Nulas | 303 |
| Preenchidas mas não numéricas | 0 |

**Resposta:** _escreva aqui o que os números mostram._

## 10. Há algo novo ou estranho (colunas novas ou ausentes, colunas constantes ou 100% nulas)?

- Colunas esperadas que faltam: nenhuma
- Colunas novas (fora das 31 da fonte e do rastreio): nenhuma
- Ordem das colunas diferente da fonte: não
- Colunas com um único valor: `ano_sinistro`, `mes_sinistro`, `ano_mes_sinistro`, `ano_obito` (em um perfil de um ano ou de um mês, as colunas de ano e de mês são constantes: é esperado)
- Colunas 100% nulas: nenhuma

**Resposta:** _escreva aqui o que os números mostram._

## Anexo A. Linhas por mês de data_sinistro

| mês | linhas | % |
| --- | --- | --- |
| 2021-01 | 19.534 | 100,00 |

## Anexo B. Valores distintos por coluna

| coluna | valores distintos |
| --- | --- |
| id_sinistro | 9.714 |
| id_pessoa | 19.534 |
| id_veiculo | 13.399 |
| cod_ibge | 495 |
| municipio | 495 |
| regiao_administrativa | 16 |
| tipo_via | 3 |
| tipo_veiculo_vitima | 7 |
| tipo_de_vitima | 4 |
| modo_transporte_vitima | 8 |
| sexo | 3 |
| idade | 95 |
| gravidade_lesao | 5 |
| faixa_etaria_demografica | 20 |
| faixa_etaria_legal | 15 |
| profissao | 344 |
| grau_de_instrucao | 3 |
| nacionalidade | 27 |
| data_sinistro | 31 |
| ano_sinistro | 1 |
| mes_sinistro | 1 |
| dia_sinistro | 31 |
| ano_mes_sinistro | 1 |
| data_obito | 40 |
| ano_obito | 1 |
| mes_obito | 2 |
| dia_obito | 31 |
| ano_mes_obito | 2 |
| local_obito | 3 |
| local_via | 3 |
| tempo_sinistro_obito | 19 |
| arquivo_origem | 1 |

## Anexo C. Os 10 valores mais frequentes de cada coluna categórica

### municipio

| valor | n | % |
| --- | --- | --- |
| SAO PAULO | 4.336 | 22,20 |
| RIBEIRAO PRETO | 552 | 2,83 |
| CAMPINAS | 525 | 2,69 |
| GUARULHOS | 483 | 2,47 |
| SAO JOSE DO RIO PRETO | 451 | 2,31 |
| SAO BERNARDO DO CAMPO | 373 | 1,91 |
| SOROCABA | 361 | 1,85 |
| SANTOS | 286 | 1,46 |
| SANTO ANDRE | 269 | 1,38 |
| JUNDIAI | 249 | 1,27 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 7.284 | 37,29 |
| CAMPINAS | 2.797 | 14,32 |
| SOROCABA | 1.258 | 6,44 |
| BAIXADA SANTISTA | 1.210 | 6,19 |
| SÃO JOSÉ DO RIO PRETO | 1.191 | 6,10 |
| SÃO JOSÉ DOS CAMPOS | 1.189 | 6,09 |
| RIBEIRÃO PRETO | 831 | 4,25 |
| MARÍLIA | 640 | 3,28 |
| BAURU | 566 | 2,90 |
| CENTRAL | 565 | 2,89 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 16.054 | 82,18 |
| ESTRADAS E RODOVIAS | 3.455 | 17,69 |
| NAO DISPONIVEL | 25 | 0,13 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 8.078 | 41,35 |
| MOTOCICLETA | 6.555 | 33,56 |
| (nulo) | 3.807 | 19,49 |
| CAMINHAO | 535 | 2,74 |
| ONIBUS | 385 | 1,97 |
| OUTROS | 135 | 0,69 |
| BICICLETA | 28 | 0,14 |
| NAO DISPONIVEL | 11 | 0,06 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 9.236 | 47,28 |
| PASSAGEIRO | 6.715 | 34,38 |
| NAO DISPONIVEL | 2.579 | 13,20 |
| PEDESTRE | 1.004 | 5,14 |

### modo_transporte_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 8.078 | 41,35 |
| MOTOCICLETA | 6.555 | 33,56 |
| (nulo) | 3.739 | 19,14 |
| CAMINHAO | 535 | 2,74 |
| ONIBUS | 385 | 1,97 |
| OUTROS | 135 | 0,69 |
| PEDESTRE | 69 | 0,35 |
| BICICLETA | 27 | 0,14 |
| NAO DISPONIVEL | 11 | 0,06 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 14.191 | 72,65 |
| FEMININO | 5.087 | 26,04 |
| NAO DISPONIVEL | 256 | 1,31 |

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 8.779 | 44,94 |
| ILESO | 7.742 | 39,63 |
| NAO DISPONIVEL | 1.547 | 7,92 |
| GRAVE | 1.104 | 5,65 |
| FATAL | 362 | 1,85 |

### faixa_etaria_demografica

| valor | n | % |
| --- | --- | --- |
| 20 a 24 | 3.294 | 16,86 |
| 25 a 29 | 2.608 | 13,35 |
| 30 a 34 | 2.447 | 12,53 |
| 35 a 39 | 2.275 | 11,65 |
| 40 a 44 | 1.949 | 9,98 |
| 45 a 49 | 1.537 | 7,87 |
| 50 a 54 | 1.172 | 6,00 |
| 15 a 19 | 1.088 | 5,57 |
| 55 a 59 | 910 | 4,66 |
| 60 a 64 | 646 | 3,31 |

### faixa_etaria_legal

| valor | n | % |
| --- | --- | --- |
| 18-24 | 4.029 | 20,63 |
| 25-29 | 2.608 | 13,35 |
| 30-34 | 2.447 | 12,53 |
| 35-39 | 2.275 | 11,65 |
| 40-44 | 1.949 | 9,98 |
| 45-49 | 1.537 | 7,87 |
| 50-54 | 1.172 | 6,00 |
| 55-59 | 910 | 4,66 |
| 0-17 | 747 | 3,82 |
| 60-64 | 646 | 3,31 |

### profissao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 1.857 | 9,51 |
| MOTORISTA | 1.660 | 8,50 |
| AUTONOMO(A) | 1.240 | 6,35 |
| MOTO-BOY | 1.078 | 5,52 |
| APOSENTADO(A) | 822 | 4,21 |
| ESTUDANTE | 797 | 4,08 |
| AJUDANTE | 707 | 3,62 |
| OUTRA | 598 | 3,06 |
| DESEMPREGADO(A) | 438 | 2,24 |
| VENDEDOR(A) | 437 | 2,24 |

### grau_de_instrucao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 15.116 | 77,38 |
| SUPERIOR | 2.427 | 12,42 |
| MÉDIO | 1.295 | 6,63 |
| BÁSICO | 696 | 3,56 |

### nacionalidade

| valor | n | % |
| --- | --- | --- |
| BRASILEIRA           | 17.247 | 88,29 |
| (nulo) | 2.193 | 11,23 |
| BOLIVIANA            | 27 | 0,14 |
| COLOMBIANA           | 14 | 0,07 |
| PORTUGUÊS            | 8 | 0,04 |
| BRITANICO            | 4 | 0,02 |
| CHINÊS               | 4 | 0,02 |
| JAPONÊS              | 4 | 0,02 |
| ARGENTINA            | 3 | 0,02 |
| LIBANÊS              | 3 | 0,02 |

### ano_sinistro

| valor | n | % |
| --- | --- | --- |
| 2021 | 19.534 | 100,00 |

### mes_sinistro

| valor | n | % |
| --- | --- | --- |
| 01 | 19.534 | 100,00 |

### dia_sinistro

| valor | n | % |
| --- | --- | --- |
| 16 | 787 | 4,03 |
| 23 | 781 | 4,00 |
| 22 | 766 | 3,92 |
| 30 | 762 | 3,90 |
| 09 | 755 | 3,87 |
| 29 | 736 | 3,77 |
| 27 | 695 | 3,56 |
| 13 | 674 | 3,45 |
| 08 | 668 | 3,42 |
| 28 | 664 | 3,40 |

### ano_mes_sinistro

| valor | n | % |
| --- | --- | --- |
| 2021/01 | 19.534 | 100,00 |

### ano_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 19.172 | 98,15 |
| 2021 | 362 | 1,85 |

### mes_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 19.172 | 98,15 |
| 01 | 352 | 1,80 |
| 02 | 10 | 0,05 |

### dia_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 19.172 | 98,15 |
| 01 | 24 | 0,12 |
| 27 | 19 | 0,10 |
| 30 | 18 | 0,09 |
| 18 | 17 | 0,09 |
| 23 | 17 | 0,09 |
| 17 | 16 | 0,08 |
| 09 | 15 | 0,08 |
| 16 | 14 | 0,07 |
| 06 | 13 | 0,07 |

### ano_mes_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 19.172 | 98,15 |
| 2021/01 | 352 | 1,80 |
| 2021/02 | 10 | 0,05 |

### local_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 19.172 | 98,15 |
| ESTABELECIMENTO DE SAUDE | 199 | 1,02 |
| VIA | 150 | 0,77 |
| OUTROS | 13 | 0,07 |

### local_via

| valor | n | % |
| --- | --- | --- |
| PUBLICO | 17.560 | 89,89 |
| NAO DISPONIVEL | 1.597 | 8,18 |
| (nulo) | 276 | 1,41 |
| PRIVADO | 101 | 0,52 |
