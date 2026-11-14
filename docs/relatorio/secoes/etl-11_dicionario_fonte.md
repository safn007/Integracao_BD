## Dicionário de dados da fonte (ETL-11)

**O que foi feito:** levantamento e documentação completa das **31 colunas originais** presentes nos 36 arquivos CSV mensais da fonte (*Pessoas Envolvidas em Sinistros — Dados Abertos SP*, 2021 a 2023), além das **2 colunas de rastreio** adicionadas na extração (`ano_origem` e `arquivo_origem`), no arquivo `docs/dicionario/dicionario_fonte.md`.

**Por quê:** estabelecer uma referência única sobre o significado, o formato bruto, o domínio, a completude e o papel analítico de cada campo antes das transformações de limpeza e da construção do esquema estrela (alimenta a Seção 1 do relatório final e serve de base para o dicionário do Data Warehouse na ETL-18).

**Resultados:**
- **Consistência estrutural:** os 36 arquivos (`pessoas_MM-AAAA.csv`, separador `;`, encoding `latin-1`) possuem exatamente as mesmas 31 colunas na mesma ordem, somando **806.977 linhas** (2021: 260.886; 2022: 266.128; 2023: 279.963) e **402.695 sinistros distintos**, com `id_pessoa` 100% único.
- **Classificação para o DW:** das 31 colunas da fonte, **3** são identificadores/dimensões degeneradas (`id_sinistro`, `id_pessoa`, `id_veiculo`), **16** compõem as 7 dimensões descritivas, **2** são datas de evento (`data_sinistro`, `data_obito`) ligadas à `dim_tempo`, **2** são medidas numéricas (`idade`, `tempo_sinistro_obito`) e **8** são colunas temporais derivadas e redundantes (marcadas para descarte na ETL-15).
- **Mapeamento de qualidade:** documentados os nulos reais (destaque para o bloco de óbito com 98,04% de nulos sempre nas mesmas linhas, `grau_de_instrucao` com 78,35% e o bloco de veículo em ~21%), os nulos disfarçados como `"NAO DISPONIVEL"` (até 14,54% em `local_via` e 13,98% em `tipo_de_vitima`) e os problemas de texto (`nacionalidade` com espaços à direita em 711.291 linhas e 8 municípios com apóstrofo substituído por espaço), vinculando cada coluna à sua tarefa de tratamento (`ETL-13` a `ETL-23`).

**Entregável completo:** `docs/dicionario/dicionario_fonte.md`.
