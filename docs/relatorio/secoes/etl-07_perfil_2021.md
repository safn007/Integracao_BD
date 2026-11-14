## Perfil dos dados de 2022 (ETL-08)

**O que foi feito:** perfil dos dados de 2021 (12 arquivos mensais `pessoas_*-2021.csv`), usando a função `perfil()`. Nenhum dado foi alterado; só foram feitos diagnósticos.

**Por quê:** as informações do perfil alimentam a comparação entre anos (ETL-12) e as etapas de limpeza e de tratamento de nulos e categorias (ETL-14 e ETL-16).

**Resultados:**
- 260.886 linhas × 31 colunas (mais `arquivo_origem`), com `id_pessoa` único e 128.207 sinistros (média de 2,03 pessoas por sinistro), todos de 2021.
- 644 municípios e 644 códigos IBGE.
- Nulos: `grau_de_instrucao` 78,29%; `id_veiculo` 21,21%; `tipo_veiculo_vitima` 21,16%; `modo_transporte_vitima` 20,77%; `nacionalidade` 11,94%; `profissao` 10,32%; `idade` 1,33%; `local_via` 1,17%.
- As 7 colunas de óbito têm 98,14% de nulos, sempre juntas.
- Óbitos: 4.858 (1,86% do total). As datas de óbito cobrem mais de um ano (`ano_obito` tem 2 valores distintos).
- Veículo nulo × tipo de vítima: 55.192 linhas (21,16%). Delas, 59,39% são "NAO DISPONIVEL", 26,21% pedestres, 12,34% passageiros e 2,05% condutores. No sentido inverso, 100% dos 14.468 pedestres estão sem veículo: a hipótese vale de pedestre para "sem veículo", mas não o contrário. Passageiros e condutores sem veículo (7.945 linhas) são registros incompletos. As três colunas do bloco de veículo têm % de nulos diferentes, então não ficam nulas exatamente nas mesmas linhas.
- `grau_de_instrucao` por mês: preenchido em cerca de 22% das linhas em todos os meses de 2021 (de 20,90% em junho a 22,62% em janeiro), sem diferença relevante entre eles. O campo é cerca de 78% nulo o ano inteiro, e não só fora de janeiro.
- Nulos disfarçados: "NAO DISPONIVEL" e "NAO INFORMADO" aparecem como texto, não como nulo, em `tipo_de_vitima` (37.232 linhas, 14,27%), `gravidade_lesao` (23.548, 9,03%) e `local_via` (20.842, 7,99%). Em menor escala aparecem em `sexo` (1,34%), nas duas faixas etárias (1,33%) e em `tipo_via` (0,12%).
- Texto: os 12 arquivos não são UTF-8 e foram lidos como `latin-1`; os acentos estão corretos. Os mesmos 8 municípios de 2022 ficaram com espaço no lugar do apóstrofo (ex.: "SANTA BARBARA D OESTE"). `municipio` vem sem acento e `regiao_administrativa` com acento. Todos os 65 valores distintos de `nacionalidade` têm espaços sobrando no fim (229.731 linhas) e `profissao` tem 1 valor com espaço duplo (1 linha). Nenhum valor com caractere inválido.

**Respostas às 10 perguntas padrão:** em `docs/perfil/perfil_2021.md`. Lista de valores suspeitos: `docs/perfil/corrompidos_2021.csv`.