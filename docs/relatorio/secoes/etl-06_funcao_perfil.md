## Função padrão de perfil (ETL-06)

**O que foi feito:** a função `perfil(df)`, em `src/perfil.py`, gera o raio-X de uma base sem alterar nenhum dado. Ela responde sempre às mesmas 10 perguntas, na mesma ordem:

1. Linhas e sinistros
2. Nulos
3. Domínios das colunas categóricas
4. Texto suspeito
5. Escolaridade por mês
6. Óbitos
7. Duplicatas
8. Mês do arquivo × data
9. Idade
10. Estranhezas

A função `perfil_para_markdown()` grava o resultado em `.md`, com um espaço de **Resposta** por pergunta.

**Por quê:** cada integrante faz o perfil de um ano (ETL-07, ETL-08 e ETL-09). Com a mesma função e as mesmas perguntas, os três perfis saem comparáveis, e o comparativo entre anos (ETL-12) fica direto.

**Como foi validado:**
- Os números de jan/2021 (19.534 linhas, 9.714 sinistros, 362 óbitos) foram conferidos com uma contagem independente.
- A função foi testada com pandas 3.1.1 e 2.3.3, com saída idêntica, e em casos de borda (idades inválidas, IDs repetidos, base vazia, colunas ausentes).
- A ETL-09 usou a função sem ajustes em 279.963 linhas.

**Achado que a função revelou:** lendo os arquivos em `latin-1`, os acentos estão corretos. O problema real de texto é `nacionalidade` com espaços no fim, tratado na ETL-14.

**Limitação conhecida:** a pergunta 4 ignora letras isoladas `A`, `E`, `O` e `D`, para evitar falsos positivos. Por isso não marca municípios como `SANTA BARBARA D OESTE`, cujo apóstrofo virou espaço. Esses 8 municípios foram encontrados com uma conferência à parte na ETL-09.
