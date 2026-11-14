# Perfil da base: 2021

> Gerado por `src/perfil.py` (ETL-06). As seções 1 a 10 respondem as 10 perguntas padrão e aparecem sempre na mesma ordem, em todos os anos. Escreva as respostas depois de gerar e não gere de novo por cima do arquivo editado.

## 1. Quantas linhas e quantos sinistros distintos há? Qual a média de pessoas por sinistro?

| métrica | valor |
| --- | --- |
| Linhas | 260.886 |
| Colunas | 32 |
| Sinistros distintos (id_sinistro) | 128.207 |
| Pessoas por sinistro: média | 2,03 |
| Pessoas por sinistro: mediana | 2,00 |
| Pessoas por sinistro: máximo | 37 |

**Resposta:** 260.886 linhas × 31 colunas (mais `arquivo_origem`), com `id_pessoa` único e 128.207 sinistros (média de 2,03 pessoas por sinistro), todos de 2021.

## 2. Qual o % de nulos de cada coluna?

| coluna | nulos | % nulos |
| --- | --- | --- |
| id_sinistro | 0 | 0,00 |
| id_pessoa | 0 | 0,00 |
| id_veiculo | 55.338 | 21,21 |
| cod_ibge | 0 | 0,00 |
| municipio | 0 | 0,00 |
| regiao_administrativa | 0 | 0,00 |
| tipo_via | 0 | 0,00 |
| tipo_veiculo_vitima | 55.192 | 21,16 |
| tipo_de_vitima | 0 | 0,00 |
| modo_transporte_vitima | 54.174 | 20,77 |
| sexo | 0 | 0,00 |
| idade | 3.475 | 1,33 |
| gravidade_lesao | 0 | 0,00 |
| faixa_etaria_demografica | 0 | 0,00 |
| faixa_etaria_legal | 0 | 0,00 |
| profissao | 26.926 | 10,32 |
| grau_de_instrucao | 204.256 | 78,29 |
| nacionalidade | 31.155 | 11,94 |
| data_sinistro | 0 | 0,00 |
| ano_sinistro | 0 | 0,00 |
| mes_sinistro | 0 | 0,00 |
| dia_sinistro | 0 | 0,00 |
| ano_mes_sinistro | 0 | 0,00 |
| data_obito | 256.028 | 98,14 |
| ano_obito | 256.028 | 98,14 |
| mes_obito | 256.028 | 98,14 |
| dia_obito | 256.028 | 98,14 |
| ano_mes_obito | 256.028 | 98,14 |
| local_obito | 256.028 | 98,14 |
| local_via | 3.041 | 1,17 |
| tempo_sinistro_obito | 256.028 | 98,14 |
| arquivo_origem | 0 | 0,00 |

**Resposta:** `grau_de_instrucao` é a coluna mais vazia fora do bloco de óbito: 204.256 nulos (78,29%). As 7 colunas de óbito têm 256.028 nulos cada (98,14%), sempre nas mesmas linhas. O bloco de veículo tem 21,21% (`id_veiculo`, 55.338), 21,16% (`tipo_veiculo_vitima`, 55.192) e 20,77% (`modo_transporte_vitima`, 54.174); como os três números diferem, o nulo não cai exatamente nas mesmas linhas. Os demais são `nacionalidade` 11,94%, `profissao` 10,32%, `idade` 1,33% e `local_via` 1,17%. As outras 17 colunas não têm nenhum nulo, mas isso não quer dizer que estejam completas: `tipo_de_vitima`, `gravidade_lesao`, `sexo` e `tipo_via` trazem "NAO DISPONIVEL" como texto (nulo disfarçado, ver pergunta 3).

## 3. Quais os domínios (valores e contagens) de gravidade_lesao, tipo_de_vitima, sexo, tipo_via, tipo_veiculo_vitima e regiao_administrativa?

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 114.859 | 44,03 |
| ILESO | 103.761 | 39,77 |
| NAO DISPONIVEL | 23.548 | 9,03 |
| GRAVE | 13.860 | 5,31 |
| FATAL | 4.858 | 1,86 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 121.713 | 46,65 |
| PASSAGEIRO | 87.473 | 33,53 |
| NAO DISPONIVEL | 37.232 | 14,27 |
| PEDESTRE | 14.468 | 5,55 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 188.832 | 72,38 |
| FEMININO | 68.567 | 26,28 |
| NAO DISPONIVEL | 3.487 | 1,34 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 218.935 | 83,92 |
| ESTRADAS E RODOVIAS | 41.625 | 15,96 |
| NAO DISPONIVEL | 326 | 0,12 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 102.227 | 39,18 |
| MOTOCICLETA | 88.516 | 33,93 |
| (nulo) | 55.192 | 21,16 |
| CAMINHAO | 7.527 | 2,89 |
| ONIBUS | 4.673 | 1,79 |
| OUTROS | 2.242 | 0,86 |
| BICICLETA | 345 | 0,13 |
| NAO DISPONIVEL | 164 | 0,06 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 100.311 | 38,45 |
| CAMPINAS | 39.733 | 15,23 |
| SOROCABA | 17.082 | 6,55 |
| SÃO JOSÉ DO RIO PRETO | 15.003 | 5,75 |
| SÃO JOSÉ DOS CAMPOS | 13.554 | 5,20 |
| BAIXADA SANTISTA | 12.796 | 4,90 |
| RIBEIRÃO PRETO | 10.501 | 4,03 |
| MARÍLIA | 9.063 | 3,47 |
| BAURU | 8.058 | 3,09 |
| PRESIDENTE PRUDENTE | 7.645 | 2,93 |
| ARAÇATUBA | 7.052 | 2,70 |
| CENTRAL | 6.933 | 2,66 |
| FRANCA | 5.594 | 2,14 |
| BARRETOS | 3.290 | 1,26 |
| ITAPEVA | 2.592 | 0,99 |
| REGISTRO | 1.679 | 0,64 |

**Resposta:** As seis colunas têm poucos valores e nenhuma variação de grafia. `gravidade_lesao` tem 5 valores (LEVE 44,03%, ILESO 39,77%, GRAVE 5,31%, FATAL 1,86%); `tipo_de_vitima` tem 4 (CONDUTOR 46,65%, PASSAGEIRO 33,53%, PEDESTRE 5,55%); `sexo` tem 3 (MASCULINO 72,38%, FEMININO 26,28%); `tipo_via` tem 3 (VIAS URBANAS 83,92%, ESTRADAS E RODOVIAS 15,96%); `tipo_veiculo_vitima` tem 7 valores mais o nulo (AUTOMOVEL 39,18%, MOTOCICLETA 33,93%); `regiao_administrativa` tem 16 regiões (METROPOLITANA DE SÃO PAULO 38,45%, CAMPINAS 15,23%). Cinco das seis têm "NAO DISPONIVEL" como categoria: `tipo_de_vitima` 37.232 linhas (14,27%), `gravidade_lesao` 23.548 (9,03%), `sexo` 3.487 (1,34%), `tipo_via` 326 (0,12%) e `tipo_veiculo_vitima` 164 (0,06%, além dos 55.192 nulos). São nulos disfarçados, relevantes para o tratamento da ETL-16.

## 4. Há valores com caractere inválido/acento corrompido ou com espaço sobrando?

Nomes de coluna com espaço: nenhuma.

66 valores distintos suspeitos. Motivos: `espaco_nas_pontas`, `espaco_duplo`, `caractere_invalido` (U+FFFD, controle, UTF-8 lido como latin-1) e `letra_isolada` (ex.: `S O PAULO`; pode ter falso positivo).

| coluna | motivo | valores distintos | linhas |
| --- | --- | --- | --- |
| profissao | espaco_duplo | 1 | 1 |
| nacionalidade | espaco_nas_pontas | 65 | 229.731 |

Detalhe (as 40 primeiras de 66):

| coluna | valor | n | motivo |
| --- | --- | --- | --- |
| profissao | `'TECNICO EM  MECANICA PRODUCAO'` | 1 | espaco_duplo |
| nacionalidade | `'BRASILEIRA          '` | 228.387 | espaco_nas_pontas |
| nacionalidade | `'BOLIVIANA           '` | 231 | espaco_nas_pontas |
| nacionalidade | `'COLOMBIANA          '` | 201 | espaco_nas_pontas |
| nacionalidade | `'PORTUGUÊS           '` | 112 | espaco_nas_pontas |
| nacionalidade | `'JAPONÊS             '` | 82 | espaco_nas_pontas |
| nacionalidade | `'CHINÊS              '` | 75 | espaco_nas_pontas |
| nacionalidade | `'BRITANICO           '` | 58 | espaco_nas_pontas |
| nacionalidade | `'HAITIANA            '` | 55 | espaco_nas_pontas |
| nacionalidade | `'ARGENTINA           '` | 48 | espaco_nas_pontas |
| nacionalidade | `'VENEZUELANO         '` | 45 | espaco_nas_pontas |
| nacionalidade | `'PERUANO             '` | 40 | espaco_nas_pontas |
| nacionalidade | `'BENGALI             '` | 37 | espaco_nas_pontas |
| nacionalidade | `'CHILENA             '` | 37 | espaco_nas_pontas |
| nacionalidade | `'ITALIANA            '` | 32 | espaco_nas_pontas |
| nacionalidade | `'PARAGUAIO           '` | 29 | espaco_nas_pontas |
| nacionalidade | `'ESPANHOL            '` | 25 | espaco_nas_pontas |
| nacionalidade | `'ANGOLANA            '` | 23 | espaco_nas_pontas |
| nacionalidade | `'LIBANÊS             '` | 20 | espaco_nas_pontas |
| nacionalidade | `'AFEGANE             '` | 14 | espaco_nas_pontas |
| nacionalidade | `'ESTADUNIDENSE       '` | 14 | espaco_nas_pontas |
| nacionalidade | `'CUBANA              '` | 12 | espaco_nas_pontas |
| nacionalidade | `'URUGUAIO            '` | 11 | espaco_nas_pontas |
| nacionalidade | `'ALBANÊS             '` | 10 | espaco_nas_pontas |
| nacionalidade | `'NIGERIANO           '` | 9 | espaco_nas_pontas |
| nacionalidade | `'ALEMÃ               '` | 8 | espaco_nas_pontas |
| nacionalidade | `'SÍRIO               '` | 8 | espaco_nas_pontas |
| nacionalidade | `'AUSTRÍACA           '` | 7 | espaco_nas_pontas |
| nacionalidade | `'ARGELINA            '` | 6 | espaco_nas_pontas |
| nacionalidade | `'INDIANA             '` | 6 | espaco_nas_pontas |
| nacionalidade | `'SENEGALÊS           '` | 6 | espaco_nas_pontas |
| nacionalidade | `'AUSTRALIANA         '` | 5 | espaco_nas_pontas |
| nacionalidade | `'BARBADIANA          '` | 5 | espaco_nas_pontas |
| nacionalidade | `'FRANCÊS             '` | 5 | espaco_nas_pontas |
| nacionalidade | `'BELGA               '` | 4 | espaco_nas_pontas |
| nacionalidade | `'BURUNDIENÊS         '` | 4 | espaco_nas_pontas |
| nacionalidade | `'GUINEENSE           '` | 4 | espaco_nas_pontas |
| nacionalidade | `'SUL-AFRICANO        '` | 4 | espaco_nas_pontas |
| nacionalidade | `'ARUBIANO            '` | 3 | espaco_nas_pontas |
| nacionalidade | `'EGÍPCIO             '` | 3 | espaco_nas_pontas |

**Resposta:** Há espaços sobrando e apóstrofos perdidos, mas nenhum texto corrompido pela leitura. A função achou 66 valores distintos suspeitos: todos os 65 valores de `nacionalidade` têm espaços no fim (229.731 linhas; o texto vem preenchido com espaços até 20 caracteres, ex.: `'BRASILEIRA          '`) e 1 valor de `profissao` tem espaço duplo (`TECNICO EM  MECANICA PRODUCAO`, 1 linha). Não há caractere inválido nem UTF-8 lido como latin-1: os 12 arquivos não são UTF-8, foram lidos como `latin-1` e os acentos saem corretos (`SÃO PAULO`, `RIBEIRÃO PRETO`). A busca por letra isolada, feita no notebook, achou 8 municípios que perderam o apóstrofo (7 com "D OESTE", como `SANTA BARBARA D OESTE`, e `SAO JOAO DO PAU D ALHO`), os mesmos 8 de 2022, listados em `corrompidos_2021.csv`. Também há inconsistência de acento entre colunas: `municipio` vem sem acento (`SAO PAULO`) e `regiao_administrativa` com acento (`SÃO PAULO`).

## 5. Qual o % de grau_de_instrucao preenchido em cada mês?

| mês | linhas | preenchidos | % preenchido |
| --- | --- | --- | --- |
| 2021-01 | 19.534 | 4.418 | 22,62 |
| 2021-02 | 19.684 | 4.248 | 21,58 |
| 2021-03 | 18.198 | 3.819 | 20,99 |
| 2021-04 | 19.586 | 4.175 | 21,32 |
| 2021-05 | 23.067 | 4.986 | 21,62 |
| 2021-06 | 22.192 | 4.638 | 20,90 |
| 2021-07 | 24.209 | 5.064 | 20,92 |
| 2021-08 | 23.852 | 5.155 | 21,61 |
| 2021-09 | 21.579 | 4.762 | 22,07 |
| 2021-10 | 22.772 | 5.053 | 22,19 |
| 2021-11 | 23.156 | 5.117 | 22,10 |
| 2021-12 | 23.057 | 5.195 | 22,53 |

**Resposta:** O preenchimento fica em cerca de 22% em todos os meses, de 20,90% (junho) a 22,62% (janeiro), sem diferença relevante entre eles. No ano, 56.630 das 260.886 linhas têm o campo preenchido (21,71%). Janeiro é o maior, mas por pouco: não existe um mês em que `grau_de_instrucao` esteja bem preenchido, o campo é cerca de 78% nulo o ano inteiro.

## 6. Quantos óbitos há e qual o % do total? As colunas de óbito são nulas nas mesmas linhas?

| métrica | valor |
| --- | --- |
| Óbitos (data_obito preenchida) | 4.858 |
| % do total de linhas | 1,86 |
| Linhas com gravidade_lesao = FATAL | 4.858 |
| Colunas de óbito encontradas | 7 |
| Nulas nas mesmas linhas? | sim |
| Linhas com óbito parcial (inconsistentes) | 0 |

**Resposta:** Há 4.858 óbitos, 1,86% das linhas, o mesmo número de linhas com `gravidade_lesao` = FATAL. As 7 colunas de óbito são nulas nas mesmas linhas (256.028 nulos em cada uma) e nenhuma linha tem óbito preenchido pela metade (0 inconsistentes). Portanto, nessas colunas o nulo significa "não morreu".

## 7. Há id_pessoa repetido? E linhas 100% idênticas?

| métrica | valor |
| --- | --- |
| id_pessoa nulo | 0 |
| id_pessoa que aparece mais de uma vez | 0 |
| Linhas com id_pessoa repetido | 0 |
| Linhas excedentes por id_pessoa | 0 |
| Linhas 100% idênticas (excedentes, sem as colunas de rastreio) | 0 |

**Resposta:** Não. Nenhum `id_pessoa` é nulo ou repetido (260.886 valores distintos em 260.886 linhas, 0 excedentes) e não há linhas 100% idênticas (0). A checagem vale só dentro de 2021; repetições entre anos ficam para as etapas de chaves e duplicatas (ETL-13) e para o comparativo (ETL-12).

## 8. Há linhas cujo mês de data_sinistro difere do mês do arquivo de origem?

| métrica | valor |
| --- | --- |
| Linhas comparáveis (mês do arquivo e da data conhecidos) | 260.886 |
| Linhas com mês divergente | 0 |
| % divergente | 0,00 |
| data_sinistro nula | 0 |
| data_sinistro preenchida mas inválida | 0 |
| arquivo_origem fora do padrão pessoas_MM-AAAA | 0 |

**Resposta:** Não. Das 260.886 linhas comparáveis, nenhuma tem o mês de `data_sinistro` diferente do mês do arquivo de origem (0 divergentes, 0,00%). Também não há `data_sinistro` nula ou inválida, nem `arquivo_origem` fora do padrão `pessoas_MM-AAAA`.

## 9. Quais o mínimo, o máximo e os valores impossíveis de idade?

| métrica | valor |
| --- | --- |
| Mínimo observado | 0,00 |
| Máximo observado | 102,00 |
| Fora de 0 a 110 | 0 |
| Exemplos fora do intervalo | — |
| Nulas | 3.475 |
| Preenchidas mas não numéricas | 0 |

**Resposta:** A idade vai de 0 a 102 anos, nenhum valor fica fora do intervalo de 0 a 110 (0 impossíveis) e não há valores não numéricos. Há 3.475 idades nulas (1,33%), o mesmo total de "NAO DISPONIVEL" nas duas colunas de faixa etária.

## 10. Há algo novo ou estranho (colunas novas ou ausentes, colunas constantes ou 100% nulas)?

- Colunas esperadas que faltam: nenhuma
- Colunas novas (fora das 31 da fonte e do rastreio): nenhuma
- Ordem das colunas diferente da fonte: não
- Colunas com um único valor: `ano_sinistro` (em um perfil de um ano ou de um mês, as colunas de ano e de mês são constantes: é esperado)
- Colunas 100% nulas: nenhuma

**Resposta:** Nada novo: as 31 colunas esperadas estão presentes, na ordem da fonte, sem colunas novas nem 100% nulas. A única constante é `ano_sinistro`, o que é esperado em um perfil de um ano. Pontos a notar: `ano_obito` tem 2 valores e `ano_mes_obito` tem 13, então há óbitos em mais de um ano (relevante para `dim_tempo`); por causa dos nulos, `id_veiculo`, `idade` e `ano_obito` são lidos como decimal (float64) e as datas como texto, o que as etapas ETL-13 e ETL-15 convertem; e `ano_mes_sinistro` usa barra (`2021/01`).

## Anexo A. Linhas por mês de data_sinistro

| mês | linhas | % |
| --- | --- | --- |
| 2021-01 | 19.534 | 7,49 |
| 2021-02 | 19.684 | 7,55 |
| 2021-03 | 18.198 | 6,98 |
| 2021-04 | 19.586 | 7,51 |
| 2021-05 | 23.067 | 8,84 |
| 2021-06 | 22.192 | 8,51 |
| 2021-07 | 24.209 | 9,28 |
| 2021-08 | 23.852 | 9,14 |
| 2021-09 | 21.579 | 8,27 |
| 2021-10 | 22.772 | 8,73 |
| 2021-11 | 23.156 | 8,88 |
| 2021-12 | 23.057 | 8,84 |

## Anexo B. Valores distintos por coluna

| coluna | valores distintos |
| --- | --- |
| id_sinistro | 128.207 |
| id_pessoa | 260.886 |
| id_veiculo | 178.437 |
| cod_ibge | 644 |
| municipio | 644 |
| regiao_administrativa | 16 |
| tipo_via | 3 |
| tipo_veiculo_vitima | 7 |
| tipo_de_vitima | 4 |
| modo_transporte_vitima | 8 |
| sexo | 3 |
| idade | 102 |
| gravidade_lesao | 5 |
| faixa_etaria_demografica | 20 |
| faixa_etaria_legal | 15 |
| profissao | 515 |
| grau_de_instrucao | 3 |
| nacionalidade | 65 |
| data_sinistro | 365 |
| ano_sinistro | 1 |
| mes_sinistro | 12 |
| dia_sinistro | 31 |
| ano_mes_sinistro | 12 |
| data_obito | 373 |
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
| SAO PAULO | 61.529 | 23,58 |
| RIBEIRAO PRETO | 7.042 | 2,70 |
| CAMPINAS | 6.478 | 2,48 |
| GUARULHOS | 6.073 | 2,33 |
| SAO JOSE DO RIO PRETO | 5.496 | 2,11 |
| SOROCABA | 4.991 | 1,91 |
| SAO BERNARDO DO CAMPO | 4.710 | 1,81 |
| SANTO ANDRE | 3.923 | 1,50 |
| JUNDIAI | 3.511 | 1,35 |
| FRANCA | 3.349 | 1,28 |

### regiao_administrativa

| valor | n | % |
| --- | --- | --- |
| METROPOLITANA DE SÃO PAULO | 100.311 | 38,45 |
| CAMPINAS | 39.733 | 15,23 |
| SOROCABA | 17.082 | 6,55 |
| SÃO JOSÉ DO RIO PRETO | 15.003 | 5,75 |
| SÃO JOSÉ DOS CAMPOS | 13.554 | 5,20 |
| BAIXADA SANTISTA | 12.796 | 4,90 |
| RIBEIRÃO PRETO | 10.501 | 4,03 |
| MARÍLIA | 9.063 | 3,47 |
| BAURU | 8.058 | 3,09 |
| PRESIDENTE PRUDENTE | 7.645 | 2,93 |

### tipo_via

| valor | n | % |
| --- | --- | --- |
| VIAS URBANAS | 218.935 | 83,92 |
| ESTRADAS E RODOVIAS | 41.625 | 15,96 |
| NAO DISPONIVEL | 326 | 0,12 |

### tipo_veiculo_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 102.227 | 39,18 |
| MOTOCICLETA | 88.516 | 33,93 |
| (nulo) | 55.192 | 21,16 |
| CAMINHAO | 7.527 | 2,89 |
| ONIBUS | 4.673 | 1,79 |
| OUTROS | 2.242 | 0,86 |
| BICICLETA | 345 | 0,13 |
| NAO DISPONIVEL | 164 | 0,06 |

### tipo_de_vitima

| valor | n | % |
| --- | --- | --- |
| CONDUTOR | 121.713 | 46,65 |
| PASSAGEIRO | 87.473 | 33,53 |
| NAO DISPONIVEL | 37.232 | 14,27 |
| PEDESTRE | 14.468 | 5,55 |

### modo_transporte_vitima

| valor | n | % |
| --- | --- | --- |
| AUTOMOVEL | 102.227 | 39,18 |
| MOTOCICLETA | 88.516 | 33,93 |
| (nulo) | 54.174 | 20,77 |
| CAMINHAO | 7.527 | 2,89 |
| ONIBUS | 4.673 | 1,79 |
| OUTROS | 2.242 | 0,86 |
| PEDESTRE | 1.043 | 0,40 |
| BICICLETA | 320 | 0,12 |
| NAO DISPONIVEL | 164 | 0,06 |

### sexo

| valor | n | % |
| --- | --- | --- |
| MASCULINO | 188.832 | 72,38 |
| FEMININO | 68.567 | 26,28 |
| NAO DISPONIVEL | 3.487 | 1,34 |

### gravidade_lesao

| valor | n | % |
| --- | --- | --- |
| LEVE | 114.859 | 44,03 |
| ILESO | 103.761 | 39,77 |
| NAO DISPONIVEL | 23.548 | 9,03 |
| GRAVE | 13.860 | 5,31 |
| FATAL | 4.858 | 1,86 |

### faixa_etaria_demografica

| valor | n | % |
| --- | --- | --- |
| 20 a 24 | 42.715 | 16,37 |
| 25 a 29 | 35.766 | 13,71 |
| 30 a 34 | 32.538 | 12,47 |
| 35 a 39 | 30.944 | 11,86 |
| 40 a 44 | 26.392 | 10,12 |
| 45 a 49 | 20.637 | 7,91 |
| 50 a 54 | 16.278 | 6,24 |
| 15 a 19 | 12.784 | 4,90 |
| 55 a 59 | 12.479 | 4,78 |
| 60 a 64 | 8.867 | 3,40 |

### faixa_etaria_legal

| valor | n | % |
| --- | --- | --- |
| 18-24 | 51.359 | 19,69 |
| 25-29 | 35.766 | 13,71 |
| 30-34 | 32.538 | 12,47 |
| 35-39 | 30.944 | 11,86 |
| 40-44 | 26.392 | 10,12 |
| 45-49 | 20.637 | 7,91 |
| 50-54 | 16.278 | 6,24 |
| 55-59 | 12.479 | 4,78 |
| 0-17 | 9.370 | 3,59 |
| 60-64 | 8.867 | 3,40 |

### profissao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 26.926 | 10,32 |
| MOTORISTA | 22.133 | 8,48 |
| MOTO-BOY | 15.384 | 5,90 |
| AUTONOMO(A) | 15.285 | 5,86 |
| APOSENTADO(A) | 11.052 | 4,24 |
| ESTUDANTE | 9.876 | 3,79 |
| AJUDANTE | 8.875 | 3,40 |
| OUTRA | 7.241 | 2,78 |
| DO LAR | 5.664 | 2,17 |
| VENDEDOR(A) | 5.659 | 2,17 |

### grau_de_instrucao

| valor | n | % |
| --- | --- | --- |
| (nulo) | 204.256 | 78,29 |
| SUPERIOR | 33.805 | 12,96 |
| MÉDIO | 14.932 | 5,72 |
| BÁSICO | 7.893 | 3,03 |

### nacionalidade

| valor | n | % |
| --- | --- | --- |
| BRASILEIRA           | 228.387 | 87,54 |
| (nulo) | 31.155 | 11,94 |
| BOLIVIANA            | 231 | 0,09 |
| COLOMBIANA           | 201 | 0,08 |
| PORTUGUÊS            | 112 | 0,04 |
| JAPONÊS              | 82 | 0,03 |
| CHINÊS               | 75 | 0,03 |
| BRITANICO            | 58 | 0,02 |
| HAITIANA             | 55 | 0,02 |
| ARGENTINA            | 48 | 0,02 |

### ano_mes_sinistro

| valor | n | % |
| --- | --- | --- |
| 2021/07 | 24.209 | 9,28 |
| 2021/08 | 23.852 | 9,14 |
| 2021/11 | 23.156 | 8,88 |
| 2021/05 | 23.067 | 8,84 |
| 2021/12 | 23.057 | 8,84 |
| 2021/10 | 22.772 | 8,73 |
| 2021/06 | 22.192 | 8,51 |
| 2021/09 | 21.579 | 8,27 |
| 2021/02 | 19.684 | 7,55 |
| 2021/04 | 19.586 | 7,51 |

### ano_mes_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 256.028 | 98,14 |
| 2021/05 | 478 | 0,18 |
| 2021/07 | 443 | 0,17 |
| 2021/12 | 438 | 0,17 |
| 2021/10 | 425 | 0,16 |
| 2021/08 | 423 | 0,16 |
| 2021/06 | 401 | 0,15 |
| 2021/09 | 399 | 0,15 |
| 2021/11 | 394 | 0,15 |
| 2021/03 | 376 | 0,14 |

### local_obito

| valor | n | % |
| --- | --- | --- |
| (nulo) | 256.028 | 98,14 |
| ESTABELECIMENTO DE SAUDE | 2.365 | 0,91 |
| VIA | 2.305 | 0,88 |
| OUTROS | 162 | 0,06 |
| NAO DISPONIVEL | 26 | 0,01 |

### local_via

| valor | n | % |
| --- | --- | --- |
| PUBLICO | 235.586 | 90,30 |
| NAO DISPONIVEL | 20.842 | 7,99 |
| (nulo) | 3.041 | 1,17 |
| PRIVADO | 1.417 | 0,54 |