## Texto e encoding (ETL-14)

**O que foi feito:** Limpeza de espaços excedentes, auditoria de *encoding*/acentuação e padronização ortográfica de municípios nas 15 colunas textuais da base unificada (`806.977` linhas × `33` colunas), no notebook `notebooks/etl/03_texto_encoding.ipynb`, gerando `data/intermediarios/03_texto.parquet`.

1. **Remoção de espaços sobrando (`normalizar_espacos`):** aplicação de `strip()` e colapso de múltiplos espaços internos (`\s+` → `' '`) em todas as colunas de texto.
2. **Mapa explícito de correção (`corrigir_encoding` / `MAPA_TEXTO`):** uso de dicionário `{valor_errado: valor_certo}` por coluna para restaurar o apóstrofo perdido nos 8 municípios paulistas identificados nos perfis (`D OESTE` → `D'OESTE` e `D ALHO` → `D'ALHO`, mantendo sem acento como os demais 637 municípios) e incluir regras preventivas para acentos que apareceram corrompidos em amostras antigas (`METROPOLITANA DE S O PAULO`, `M DIO`, etc.).

**Por quê:** Espaços à direita em campos de largura fixa, espaços duplos internos e grafias divergentes de municípios comprometem agrupamentos, filtros e a integridade das dimensões `dim_localidade` (`ETL-21`) e `dim_profissao` (`ETL-17` e `ETL-22`).

**Decisão de escopo sobre `profissao`:** Foram identificados 266 valores distintos de `profissao` em caixa mista ou minúscula (ex.: `'Motorista'`, `'Estudante'`, `'Tecnico em raio x'`) coexistindo com formas em maiúsculas (`'MOTORISTA'`, `'ESTUDANTE'`). Optou-se por **não converter a caixa de `profissao` na ETL-14**, deixando essa padronização para a **ETL-17 (Padronização de profissão)**, para manter a separação de responsabilidades: a ETL-14 garante apenas a integridade física do texto (*encoding*, acentos, apóstrofos e espaços), preservando as grafias originais para a normalização léxica e o agrupamento em `grupo_profissao` realizados na ETL-17.

**Resultados (antes × depois):**
- **Linhas:** `806.977` → `806.977` (`0` linhas removidas; `0` alterações na contagem de nulos).
- **Células alteradas:** **715.957** no total, distribuídas em 3 colunas:
  - `nacionalidade`: **711.291** células corrigidas (todos os 90 valores distintos preenchidos tinham preenchimento com espaços à direita, ex.: `'BRASILEIRA          '`); `n_distintos` mantido em `90`.
  - `municipio`: **4.665** células corrigidas nos 8 municípios padronizados com apóstrofo (`SANTA BARBARA D'OESTE`: 4.111; `PALMEIRA D'OESTE`: 231; `ESTRELA D'OESTE`: 161; `APARECIDA D'OESTE`: 83; `SANTA RITA D'OESTE`: 36; `SAO JOAO DO PAU D'ALHO`: 18; `SANTA CLARA D'OESTE`: 15; `GUARANI D'OESTE`: 10); relação 1:1 preservada entre os `645` códigos IBGE (`cod_ibge`) e os `645` municípios.
  - `profissao`: **1** célula corrigida por espaço duplo interno (`'TECNICO EM  MECANICA PRODUCAO'` → `'TECNICO EM MECANICA PRODUCAO'`); `n_distintos` mantido em `814`.
- **Acentuação e encoding:** `0` caracteres inválidos (`U+FFFD`), de controle ou *mojibake* na leitura em `latin-1`; as entradas preventivas de acentuação do `MAPA_TEXTO` tiveram `0` ocorrências nos 36 CSVs.
- **Verificação final (`src/perfil.py` / `_p4_texto`):** `0` espaços nas pontas, `0` espaços duplos e `0` caracteres inválidos após as transformações; resta apenas 1 falso positivo conhecido (`profissao = 'Tecnico em raio x'`, 1 linha, sinalizado pelo detector por conter a letra `'x'`).
