# Dicionário de Dados da Fonte — Pessoas Envolvidas em Sinistros (2021–2023)

> **Tarefa:** ETL-11 · **Responsável:** Guilherme · **Revisor:** Davi
> Documento de referência da base bruta antes das transformações do pipeline ETL (alimenta a Seção 1 do relatório final e serve de base para o dicionário do Data Warehouse na ETL-18).

## 1. Visão Geral da Fonte

| Característica | Valor observado nos 36 CSVs |
|---|---|
| **Base / Origem** | Pessoas Envolvidas em Sinistros — Dados Abertos SP (`dadosabertos.sp.gov.br` / Infosiga-SP) |
| **Abrangência** | Estado de São Paulo inteiro (645 municípios, 16 regiões administrativas) |
| **Período** | Janeiro/2021 a Dezembro/2023 (`01/01/2021` a `31/12/2023` em `data_sinistro`; óbitos até `24/01/2024`) |
| **Arquivos** | 36 CSVs mensais (`data/pessoas_MM-AAAA.csv`) |
| **Formato e encoding** | Separador `;`, codificação `latin-1`, datas `dd/mm/aaaa`, nulos como campo vazio (`""`) |
| **Volume total** | **806.977 linhas** (2021: `260.886`; 2022: `266.128`; 2023: `279.963`) |
| **Sinistros distintos** | **402.695** (`id_sinistro` distintos; `id_pessoa` único em 100% das 806.977 linhas) |
| **Colunas** | **31 colunas originais** (mesmo nome e ordem nos 36 arquivos) + **2 colunas de rastreio** da extração (`ETL-05`) |

---

## 2. Dicionário das Colunas (31 originais + 2 de rastreio)

**Legenda de Classificação:**
- **Identificador / Degenerada:** chave de negócio ou identificador mantido na tabela fato (`fato_vitima_sinistro`).
- **Chave Natural (Dimensão):** identificador natural que define a granularidade de uma dimensão.
- **Atributo (Dimensão):** atributo categórico/descritivo que compõe uma dimensão do esquema estrela.
- **Temporal:** data de evento usada como chave estrangeira para `dim_tempo`.
- **Medida:** valor numérico quantitativo armazenado na tabela fato.
- **Derivada (Descartada):** coluna redundante pré-calculada na fonte (ano/mês/dia/ano_mes) removida na limpeza de datas (`ETL-15`).
- **Rastreio (Extração):** metadado gerado na leitura dos CSVs (`ETL-05`), usado apenas para auditoria durante o pipeline.

> **Nota sobre "nulo disfarçado":** Além de campos vazios (`null`), a fonte registra valores ausentes como texto literal `"NAO DISPONIVEL"`. A coluna *% de Nulo* informa primeiro o nulo real (campo vazio) sobre as `806.977` linhas e, entre parênteses, a ocorrência de `"NAO DISPONIVEL"` quando existente.

| # | Coluna | Descrição | Tipo (fonte → lógico) | Exemplo / Domínio | % de Nulo (base 2021–2023) | Classificação | Tarefa(s) que trata(m) |
|---|---|---|---|---|---|---|---|
| 1 | `id_sinistro` | Identificador único do sinistro de trânsito (pode aparecer em mais de uma linha quando há múltiplas vítimas/envolvidos). | Texto → Inteiro (`BIGINT`) | `2240338`, `1839244` (`402.695` distintos) | `0,00%` (`0`) | Identificador / Dimensão Degenerada (`fato_vitima_sinistro`) | `ETL-13` (tipagem/chaves), `ETL-23` (fato) |
| 2 | `id_pessoa` | Identificador único da pessoa envolvida no sinistro (define o grão da base e da tabela fato). | Texto → Inteiro (`BIGINT`) | `1979797`, `1284984` (`806.977` distintos; único) | `0,00%` (`0`) | Identificador / Dimensão Degenerada (`fato_vitima_sinistro`) | `ETL-13` (unicidade/duplicatas), `ETL-23` (fato) |
| 3 | `id_veiculo` | Identificador do veículo associado à pessoa no sinistro (nulo principalmente para pedestres e registros incompletos). | Texto → Inteiro (`BIGINT`) | `2874666`, `2648403` (`554.294` distintos) | `21,04%` (`169.754`) | Identificador / Dimensão Degenerada (`fato_vitima_sinistro`) | `ETL-13` (tipagem), `ETL-16` (cruzamento pedestres/nulos), `ETL-23` (fato) |
| 4 | `cod_ibge` | Código IBGE de 7 dígitos do município onde ocorreu o sinistro (relação 1:1 com `municipio`). | Texto → Inteiro (`INT`) | `3550308` (São Paulo), `3552502` (Suzano) (`645` distintos) | `0,00%` (`0`) | Chave Natural (`dim_localidade`) | `ETL-13` (consistência 1:1 IBGE×município), `ETL-21` (`dim_localidade`) |
| 5 | `municipio` | Nome do município paulista da ocorrência (em maiúsculas, sem acentos; 8 municípios têm apóstrofo trocado por espaço, ex.: `SANTA BARBARA D OESTE`). | Texto (`VARCHAR`) | `SAO PAULO`, `RIBEIRAO PRETO`, `CAMPINAS` (`645` distintos) | `0,00%` (`0`) | Atributo (`dim_localidade`) | `ETL-13` (consistência IBGE), `ETL-14` (texto/apóstrofos), `ETL-21` (`dim_localidade`) |
| 6 | `regiao_administrativa` | Região Administrativa do Estado de São Paulo à qual o município pertence (em maiúsculas, com acentos). | Texto (`VARCHAR`) | `METROPOLITANA DE SÃO PAULO`, `CAMPINAS`, `SOROCABA` (`16` valores) | `0,00%` (`0`) | Atributo (`dim_localidade`) | `ETL-14` (validação de encoding/texto), `ETL-21` (`dim_localidade`) |
| 7 | `tipo_via` | Classificação macro da via onde ocorreu o sinistro. | Texto (`VARCHAR`) | `VIAS URBANAS`, `ESTRADAS E RODOVIAS`, `NAO DISPONIVEL` (`3` valores) | `0,00%` (`0`; `0,12%` `NAO DISPONIVEL` — `973`) | Atributo (`dim_via`) | `ETL-14` (texto), `ETL-16` (padronização `NAO DISPONIVEL`), `ETL-21` (`dim_via`) |
| 8 | `tipo_veiculo_vitima` | Categoria do veículo em que a vítima estava no momento do sinistro (nulo quando não há veículo associado). | Texto (`VARCHAR`) | `AUTOMOVEL`, `MOTOCICLETA`, `CAMINHAO`, `ONIBUS`, `BICICLETA`, `OUTROS`, `NAO DISPONIVEL` (`7` valores) | `20,98%` (`169.301`; `0,06%` `NAO DISPONIVEL` — `480`) | Atributo (`dim_transporte`) | `ETL-14` (texto), `ETL-16` (nulos → `NÃO SE APLICA` / `NÃO INFORMADO`), `ETL-20` (`dim_transporte`) |
| 9 | `tipo_de_vitima` | Papel da pessoa envolvida no sinistro. | Texto (`VARCHAR`) | `CONDUTOR`, `PASSAGEIRO`, `PEDESTRE`, `NAO DISPONIVEL` (`4` valores) | `0,00%` (`0`; `13,98%` `NAO DISPONIVEL` — `112.828`) | Atributo (`dim_transporte`) | `ETL-14` (texto), `ETL-16` (cruzamento pedestres + `NAO DISPONIVEL`), `ETL-20` (`dim_transporte`) |
| 10 | `modo_transporte_vitima` | Modo de transporte da vítima (combina veículos e a categoria `PEDESTRE`; nulo em parte dos casos sem veículo). | Texto (`VARCHAR`) | `AUTOMOVEL`, `MOTOCICLETA`, `CAMINHAO`, `ONIBUS`, `OUTROS`, `PEDESTRE`, `BICICLETA`, `NAO DISPONIVEL` (`8` valores) | `20,54%` (`165.789`; `0,06%` `NAO DISPONIVEL` — `480`) | Atributo (`dim_transporte`) | `ETL-14` (texto), `ETL-16` (nulos/categorias), `ETL-20` (`dim_transporte`) |
| 11 | `sexo` | Sexo biológico/registrado da pessoa envolvida. | Texto (`VARCHAR`) | `MASCULINO`, `FEMININO`, `NAO DISPONIVEL` (`3` valores) | `0,00%` (`0`; `0,54%` `NAO DISPONIVEL` — `4.366`) | Atributo (`dim_perfil_vitima`) | `ETL-14` (texto), `ETL-16` (padronização `NAO DISPONIVEL`), `ETL-20` (`dim_perfil_vitima`) |
| 12 | `idade` | Idade da pessoa envolvida na data do sinistro, em anos completos. | Texto → Inteiro (`SMALLINT`) | `22`, `34`, `65` (intervalo observado: `0` a `102`) | `1,04%` (`8.389`) | Medida (`fato_vitima_sinistro`) | `ETL-16` (validação de intervalo e nulos), `ETL-23` (fato) |
| 13 | `gravidade_lesao` | Classificação clínica/policial da gravidade das lesões sofridas pela pessoa. | Texto (`VARCHAR`) | `LEVE`, `ILESO`, `GRAVE`, `FATAL`, `NAO DISPONIVEL` (`5` valores) | `0,00%` (`0`; `8,71%` `NAO DISPONIVEL` — `70.314`) | Atributo (`dim_gravidade`) | `ETL-14` (texto), `ETL-16` (coerência com óbito + `NAO DISPONIVEL`), `ETL-19` (`dim_gravidade`) |
| 14 | `faixa_etaria_demografica` | Faixa etária quinquenal padronizada (grupos de 5 anos); marca `NAO DISPONIVEL` sempre que `idade` é nula. | Texto (`VARCHAR`) | `20 a 24`, `00 a 04`, `90 e +`, `NAO DISPONIVEL` (`20` valores) | `0,00%` (`0`; `1,04%` `NAO DISPONIVEL` — `8.389`) | Atributo (`dim_perfil_vitima`) | `ETL-14` (texto), `ETL-16` (padronização), `ETL-20` (`dim_perfil_vitima`) |
| 15 | `faixa_etaria_legal` | Faixa etária com recorte legal (menor de idade `0-17`, maioridade `18-24`, etc.); `NAO DISPONIVEL` quando `idade` é nula. | Texto (`VARCHAR`) | `18-24`, `0-17`, `80 ou mais`, `NAO DISPONIVEL` (`15` valores) | `0,00%` (`0`; `1,04%` `NAO DISPONIVEL` — `8.389`) | Atributo (`dim_perfil_vitima`) | `ETL-14` (texto), `ETL-16` (padronização), `ETL-20` (`dim_perfil_vitima`) |
| 16 | `profissao` | Ocupação/profissão declarada pela pessoa (contém grafias variantes, ex.: `MOTO-BOY`, `MOTOBOY`, `Tecnico em raio x`). | Texto (`VARCHAR`) | `MOTORISTA`, `AUTONOMO(A)`, `MOTO-BOY`, `ESTUDANTE` (`814` valores) | `10,64%` (`85.900`; `0,04%` `NAO DISPONIVEL` — `298`) | Atributo (`dim_profissao`) | `ETL-14` (texto/encoding), `ETL-16` (nulos), `ETL-17` (unificação e `grupo_profissao`), `ETL-22` (`dim_profissao`) |
| 17 | `grau_de_instrucao` | Nível de escolaridade da pessoa (alto índice de preenchimento ausente ao longo dos 36 meses). | Texto (`VARCHAR`) | `SUPERIOR`, `MÉDIO`, `BÁSICO` (`3` valores) | `78,35%` (`632.289`) | Atributo (`dim_perfil_vitima`) | `ETL-12` (análise mensal), `ETL-14` (texto), `ETL-16` (tratamento de nulos), `ETL-20` (`dim_perfil_vitima`) |
| 18 | `nacionalidade` | Nacionalidade da pessoa; 100% dos valores preenchidos (`711.291` linhas) vêm com espaços sobrando à direita (tamanho fixo 20). | Texto (`VARCHAR`) | `'BRASILEIRA          '`, `'BOLIVIANA           '` (`90` valores) | `11,86%` (`95.686`) | Atributo (`dim_perfil_vitima`) | `ETL-14` (`strip` de espaços/acentos), `ETL-16` (nulos), `ETL-20` (`dim_perfil_vitima`) |
| 19 | `data_sinistro` | Data em que ocorreu o sinistro de trânsito (formato `dd/mm/aaaa`). | Texto → Data (`DATE`) | `01/01/2021`, `31/12/2023` (`1.095` datas distintas) | `0,00%` (`0`) | Temporal (FK `sk_data_sinistro` → `dim_tempo`) | `ETL-15` (conversão `DATE` e validação), `ETL-19` (`dim_tempo`), `ETL-23` (fato) |
| 20 | `ano_sinistro` | Ano extraído de `data_sinistro`. | Texto → Inteiro | `2021`, `2022`, `2023` (`3` valores) | `0,00%` (`0`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_sinistro` e remoção) |
| 21 | `mes_sinistro` | Mês (zero-padded) extraído de `data_sinistro`. | Texto → Inteiro | `01`, `07`, `12` (`12` valores) | `0,00%` (`0`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_sinistro` e remoção) |
| 22 | `dia_sinistro` | Dia do mês (zero-padded) extraído de `data_sinistro`. | Texto → Inteiro | `01`, `15`, `31` (`31` valores) | `0,00%` (`0`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_sinistro` e remoção) |
| 23 | `ano_mes_sinistro` | Ano e mês de `data_sinistro` no formato `AAAA/MM`. | Texto (`CHAR(7)`) | `2021/01`, `2023/06` (`36` valores) | `0,00%` (`0`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_sinistro` e remoção) |
| 24 | `data_obito` | Data do óbito da vítima, preenchida apenas nos `15.793` casos fatais (`dd/mm/aaaa`). Pode avançar até janeiro do ano seguinte (`24/01/2024`). | Texto → Data (`DATE`) | `01/01/2021`, `25/06/2022` (`1.109` datas distintas) | `98,04%` (`791.184`) | Temporal (FK `sk_data_obito` → `dim_tempo`) | `ETL-15` (conversão `DATE` e regras), `ETL-16` (`flag_obito`), `ETL-19` (`dim_tempo`), `ETL-23` (fato) |
| 25 | `ano_obito` | Ano extraído de `data_obito` (nulo quando não houve óbito). | Texto → Inteiro | `2021`, `2022`, `2023`, `2024` (`4` valores) | `98,04%` (`791.184`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_obito` e remoção) |
| 26 | `mes_obito` | Mês (zero-padded) extraído de `data_obito`. | Texto → Inteiro | `01`, `10`, `12` (`12` valores) | `98,04%` (`791.184`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_obito` e remoção) |
| 27 | `dia_obito` | Dia do mês (zero-padded) extraído de `data_obito`. | Texto → Inteiro | `01`, `09`, `25` (`31` valores) | `98,04%` (`791.184`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_obito` e remoção) |
| 28 | `ano_mes_obito` | Ano e mês de `data_obito` no formato `AAAA/MM`. | Texto (`CHAR(7)`) | `2023/12`, `2022/07` (`37` valores, inclui `2024/01`) | `98,04%` (`791.184`) | Derivada / Redundante (Descartada) | `ETL-15` (validação contra `data_obito` e remoção) |
| 29 | `local_obito` | Tipo de estabelecimento ou local onde ocorreu o óbito (nulo quando não houve óbito). | Texto (`VARCHAR`) | `ESTABELECIMENTO DE SAUDE`, `VIA`, `OUTROS`, `NAO DISPONIVEL` (`4` valores) | `98,04%` (`791.184`; `0,01%` `NAO DISPONIVEL` — `105`) | Atributo (`dim_local_obito`) | `ETL-14` (texto), `ETL-16` (nulo → `NÃO SE APLICA`), `ETL-22` (`dim_local_obito`) |
| 30 | `local_via` | Natureza jurídica/acesso da via do sinistro. | Texto (`VARCHAR`) | `PUBLICO`, `NAO DISPONIVEL`, `PRIVADO` (`3` valores) | `1,27%` (`10.278`; `14,54%` `NAO DISPONIVEL` — `117.298`) | Atributo (`dim_via`) | `ETL-14` (texto), `ETL-16` (nulos/`NAO DISPONIVEL`), `ETL-21` (`dim_via`) |
| 31 | `tempo_sinistro_obito` | Quantidade de dias decorridos entre a data do sinistro e a data do óbito (critério Infosiga até 30 dias). | Texto → Inteiro (`SMALLINT`) | `0`, `1`, `2` (intervalo observado: `0` a `30`) | `98,04%` (`791.184`) | Medida (`fato_vitima_sinistro`, recalculada como `dias_ate_obito`) | `ETL-15` (validação contra `data_obito - data_sinistro` e cálculo de `dias_ate_obito`), `ETL-23` (fato) |
| 32 | `ano_origem` | *(Rastreio — ETL-05)* Ano de referência do arquivo CSV de origem. | Inteiro (`INT`) | `2021`, `2022`, `2023` (`3` valores) | `0,00%` (`0`) | Rastreio (Extração / Auditoria) | `ETL-05` (criação), não vai para o DW |
| 33 | `arquivo_origem` | *(Rastreio — ETL-05)* Caminho/nome do CSV mensal de origem da linha. | Texto (`VARCHAR`) | `data/pessoas_01-2021.csv` (`36` valores) | `0,00%` (`0`) | Rastreio (Extração / Auditoria) | `ETL-05` (criação), `ETL-07/08/09` (validação mês), não vai para o DW |

---

## 3. Resumo por Classificação e Destino no Pipeline

| Classificação | Qtd. Colunas | Colunas da fonte | Destino / Ação no Pipeline |
|---|---|---|---|
| **Identificadores / Dimensões Degeneradas** | 3 | `id_sinistro`, `id_pessoa`, `id_veiculo` | Mantidos na `fato_vitima_sinistro` (`ETL-13`, `ETL-23`) |
| **Chave Natural + Atributos de Dimensão** | 16 | `cod_ibge`, `municipio`, `regiao_administrativa`, `tipo_via`, `local_via`, `tipo_veiculo_vitima`, `tipo_de_vitima`, `modo_transporte_vitima`, `sexo`, `faixa_etaria_demografica`, `faixa_etaria_legal`, `grau_de_instrucao`, `nacionalidade`, `gravidade_lesao`, `profissao`, `local_obito` | Distribuídos nas dimensões `dim_localidade`, `dim_via`, `dim_transporte`, `dim_perfil_vitima`, `dim_gravidade`, `dim_profissao` e `dim_local_obito` (`ETL-19` a `ETL-22`) |
| **Temporais** | 2 | `data_sinistro`, `data_obito` | Convertidas para `DATE` (`ETL-15`) e mapeadas às FKs `sk_data_sinistro` e `sk_data_obito` em `dim_tempo` (`ETL-19`, `ETL-23`) |
| **Medidas** | 2 | `idade`, `tempo_sinistro_obito` | Validadas (`ETL-15`, `ETL-16`) e armazenadas em `fato_vitima_sinistro` (`ETL-23`), junto às medidas derivadas `flag_obito` e `qtd_vitima` |
| **Derivadas / Redundantes** | 8 | `ano_sinistro`, `mes_sinistro`, `dia_sinistro`, `ano_mes_sinistro`, `ano_obito`, `mes_obito`, `dia_obito`, `ano_mes_obito` | Conferidas contra as datas-base e removidas na `ETL-15` (a granularidade temporal passa a residir em `dim_tempo`) |
| **Rastreio (adicionadas na extração)** | 2 | `ano_origem`, `arquivo_origem` | Criadas na `ETL-05` para rastreabilidade e validação mensal; descartadas antes da carga no DW |

---

## 4. Principais Achados de Qualidade na Fonte (para as próximas etapas)

1. **Unicidade e chave primária natural:** `id_pessoa` não possui nulos nem repetições em nenhuma das `806.977` linhas de 2021–2023. Cada `id_sinistro` agrega em média `2,00` pessoas (`402.695` sinistros).
2. **Bloco de óbito consistente:** As 7 colunas ligadas ao óbito (`data_obito`, `ano_obito`, `mes_obito`, `dia_obito`, `ano_mes_obito`, `local_obito`, `tempo_sinistro_obito`) são nulas exatamente nas mesmas `791.184` linhas (`98,04%`), com `0` linhas parcialmente preenchidas. Os `15.793` registros preenchidos (`1,96%`) correspondem aos óbitos ocorridos em até 30 dias (`tempo_sinistro_obito` entre `0` e `30`).
3. **Nulos disfarçados como texto (`"NAO DISPONIVEL"`):** Ocorrem em `local_via` (`14,54%`), `tipo_de_vitima` (`13,98%`), `gravidade_lesao` (`8,71%`), `faixa_etaria_demografica` e `faixa_etaria_legal` (`1,04%` — exatamente nas mesmas `8.389` linhas onde `idade` é nula), `sexo` (`0,54%`), `tipo_via` (`0,12%`), `tipo_veiculo_vitima` (`0,06%`), `modo_transporte_vitima` (`0,06%`), `profissao` (`0,04%`) e `local_obito` (`0,01%`). Serão unificados na `ETL-16` como `NÃO INFORMADO` (ou `NÃO SE APLICA` quando aplicável, como em `local_obito` sem óbito e veículo de pedestre).
4. **Bloco de veículo nulo (~21%):** `id_veiculo` (`21,04%`), `tipo_veiculo_vitima` (`20,98%`) e `modo_transporte_vitima` (`20,54%`) têm forte concentração de nulos — parte legítima (pedestres) e parte por registro incompleto, a ser tratada na `ETL-16`.
5. **Problemas de texto e formatação (`ETL-14` e `ETL-17`):**
   - `nacionalidade` tem espaços sobrando à direita em `100%` dos registros preenchidos (`711.291` linhas).
   - `municipio` não possui acentos e apresenta `8` municípios com o apóstrofo substituído por espaço (ex.: `SANTA BARBARA D OESTE`), mas mantém relação 1:1 com os `645` valores de `cod_ibge`.
   - `profissao` possui `814` valores distintos com variações de grafia (ex.: `MOTO-BOY`), tratados na `ETL-17`.
6. **Baixo preenchimento de `grau_de_instrucao`:** `78,35%` de nulos no consolidado dos 3 anos (2021: `78,29%`; 2022: `77,82%`; 2023: `78,91%`), mantido como atributo em `dim_perfil_vitima` com tratamento explícito de nulos na `ETL-16`.
