## Perfil dos dados de 2022 (ETL-08)

**O que foi feito:** perfil dos dados de 2022 (12 arquivos mensais `pessoas_*-2022.csv`), usando a função `perfil()` (ETL-06). Nenhum dado foi alterado; só foram feitos diagnósticos.

**Por quê:** as informações do perfil alimentam as etapas de limpeza e de tratamento de nulos e categorias (ETL-12 e ETL-16).

**Resultados:**
- 266.128 linhas × 31 colunas (mais `arquivo_origem`), com `id_pessoa` único e 132.358 sinistros, todos de 2022.
- 642 municípios e 642 códigos IBGE.
- Nulos: `grau_de_instrucao` 77,82%; `id_veiculo` 20,09%; `tipo_veiculo_vitima` 20,02%; `modo_transporte_vitima` 19,54%; `nacionalidade` 10,44%; `profissao` 9,32%; `idade` 1,43%; `local_via` 1,27%.
- As 7 colunas de óbito têm 97,95% de nulos, sempre juntas.
- Óbitos: 5.445 (2,05% do total).
- Veículo nulo × tipo de vítima: 53.266 linhas (20,02%). Delas, 53,79% são "NAO DISPONIVEL", 30,38% pedestres, 13,34% passageiros e 2,49% condutores. Passageiros e condutores sem veículo (8.432 linhas) são registros incompletos.
- Nulos disfarçados: "NAO DISPONIVEL" e "NÃO INFORMADO" aparecem como texto, não como nulo.
- Texto: os acentos estão corretos. 8 municípios que tinham apóstrofo ficaram com espaço (ex.: "SANTA BARBARA D OESTE"). `municipio` vem sem acento e `regiao_administrativa` com acento. Todos os 68 valores distintos de `nacionalidade` têm espaços sobrando no fim (238.353 linhas).

**Respostas às 10 perguntas padrão:** em `docs/perfil/perfil_2022.md`. Lista de valores suspeitos: `docs/perfil/corrompidos_2022.csv`.