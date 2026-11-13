## Modelo estrela do Data Warehouse (ETL-10)

**O que foi feito:** a modelagem dimensional do DW, com 1 tabela fato e 8 dimensões. O diagrama está em `docs/modelagem/modelo_estrela.png` (fonte editável em `.drawio`) e a especificação completa, coluna por coluna, em `docs/modelagem/modelo_estrela.md`.

**Grão:** uma linha da fato `fato_pessoa_sinistro` é uma pessoa envolvida em um sinistro. A fonte já vem nesse grão: `id_pessoa` é único nas 806.977 linhas, e esse é o número de linhas que a fato deve ter depois da carga.

**Tabelas:**
- **Fato:** `fato_pessoa_sinistro`, com 9 chaves estrangeiras, 3 dimensões degeneradas (`id_pessoa`, `id_sinistro`, `id_veiculo`) e as medidas `qtd_pessoas`, `flag_obito`, `idade` e `dias_ate_obito`.
- **Dimensões:**
  - `dim_tempo`, usada duas vezes: data do sinistro e data do óbito, de 01/01/2021 a 24/01/2024;
  - `dim_gravidade`;
  - `dim_perfil_vitima`;
  - `dim_transporte`;
  - `dim_localidade`, com 645 municípios e 16 regiões;
  - `dim_via`;
  - `dim_profissao`;
  - `dim_local_obito`.

**Destino das 31 colunas da fonte:** 23 são aproveitadas e 8 são descartadas. As descartadas são ano, mês, dia e ano_mes do sinistro e do óbito, porque derivam das datas e já estão na `dim_tempo`. Nos dados brutos, conferimos que elas batem 100% com as datas, e também que `tempo_sinistro_obito` é exatamente a diferença em dias entre óbito e sinistro (15.793 óbitos).

**Decisões principais:**
1. **Grão por pessoa:** as perguntas do projeto são sobre quem se envolve e quem morre.
2. **Dimensões de combinações** (perfil, transporte, via): reduzem a fato de 16 para 9 chaves estrangeiras, com cerca de 1.500, 27 e 11 linhas.
3. **`idade` na fato e não na dimensão:** colocar idade na dimensão faria as combinações explodirem.
4. **Membros especiais:** `-1` (NÃO INFORMADO) e `-2` (NÃO SE APLICA), para a fato nunca ter chave estrangeira nula.
