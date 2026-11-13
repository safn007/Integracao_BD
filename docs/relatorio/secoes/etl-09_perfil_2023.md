## Perfil dos dados de 2023 (ETL-09)

**O que foi feito:** perfil dos dados de 2023 (12 arquivos mensais `pessoas_*-2023.csv`), usando a função `perfil()` (ETL-06). Nenhum dado foi alterado; só foram feitos diagnósticos.

**Por quê:** as informações do perfil alimentam as etapas de limpeza e de tratamento de nulos e categorias (ETL-12 e ETL-16).

**Resultados:**
- 279.963 linhas × 31 colunas, com `id_pessoa` único e 142.130 sinistros, todos de 2023.
- 645 municípios e 645 códigos IBGE.
- Nulos: `grau_de_instrucao` 78,91%; `id_veiculo` 21,77%; `tipo_veiculo_vitima` 21,73%; `modo_transporte_vitima` 21,29%; `nacionalidade` 13,13%; `profissao` 12,20%; `local_via` 1,38%; `idade` 0,40%.
- As 7 colunas de óbito têm 98,04% de nulos, sempre juntas.
- Óbitos: 5.490 (1,96% do total).
- Veículo nulo × tipo de vítima: 60.843 linhas (21,73%). Delas, 60,93% são "NAO DISPONIVEL", 25,51% pedestres, 11,64% passageiros e 1,91% condutores. Passageiros e condutores sem veículo (8.247 linhas) são registros incompletos.
- Nulos disfarçados: "NAO DISPONIVEL" e "NÃO INFORMADO" aparecem como texto, não como nulo.
- Texto: os acentos estão corretos. 8 municípios que tinham apóstrofo ficaram com espaço (ex.: "SANTA BARBARA D OESTE"). `municipio` vem sem acento e `regiao_administrativa` com acento.

**Respostas às 10 perguntas padrão:** em `docs/perfil/perfil_2023.md`. Lista de valores suspeitos: `docs/perfil/corrompidos_2023.csv`.