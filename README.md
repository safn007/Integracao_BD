# Projeto de Integração de Dados: Sinistros de Trânsito (2021 a 2023)

Projeto da disciplina de Banco de Dados. O objetivo é integrar bases de dados de vítimas de sinistros de trânsito de 2021 a 2023, usando pipelines de ETL e ELT.

## Integrantes
- Davi Mello <dsm5> · `@davi01mello`
- Guilherme Calistrato <gcnt> · `@guicalistrato`
- Pedro Wellington <pwffl> · `@PedroWellington`
- Samuel de Almeida <safn> · `@safn007`

## Entregáveis

| Entregável | Onde está |
| --- | --- |
| Relatório (7 seções do template) | [`docs/relatorio/relatorio.md`](docs/relatorio/relatorio.md) |
| Notebook ETL, com o resultado no banco | [`notebooks/ETL.ipynb`](notebooks/ETL.ipynb) |
| Notebook ELT, com o resultado no banco | [`notebooks/ELT.ipynb`](notebooks/ELT.ipynb) e os scripts em [`sql/elt/`](sql/elt/) |
| Modelo estrela e dicionários | [`docs/modelagem/modelo_estrela.md`](docs/modelagem/modelo_estrela.md), [`docs/dicionario/`](docs/dicionario/) e o DDL em [`sql/ddl/`](sql/ddl/) |
| Diagramas dos fluxos (draw.io) | [`docs/diagramas/`](docs/diagramas/) |
| Validações | [`sql/validacao/`](sql/validacao/) e [`notebooks/elt/08_validacao.ipynb`](notebooks/elt/08_validacao.ipynb) |
| Três análises (consultas SQL e gráficos) | [`notebooks/analises.ipynb`](notebooks/analises.ipynb), [`sql/analises/analises.sql`](sql/analises/analises.sql) e a seção 6 do relatório |

## Dados
- Tema: Pessoas Envolvidas em Sinistros em São Paulo
- Período: 2021 a 2023, com 1 arquivo CSV por mês (36 arquivos)
- Local no repositório: `data/`
- Formato: CSV separado por `;`, encoding `latin-1`

## Fluxo da ETL

A transformação acontece no Python, antes da carga. O notebook [ETL.ipynb](notebooks/ETL.ipynb) consolida os CSVs, limpa e padroniza os dados, monta a fato e as oito dimensões em Parquet e só então carrega e valida o modelo estrela no PostgreSQL (Supabase).

![Fluxo da ETL: dos 36 CSVs à extração e limpeza, à montagem da fato e das dimensões, à carga e à validação no PostgreSQL.](docs/diagramas/fluxo_etl.png)

[Diagrama editável no draw.io](docs/diagramas/fluxo_etl.drawio) · [Modelo estrela](docs/modelagem/modelo_estrela.md) · [Detalhes da execução da ETL-26](docs/relatorio/secoes/etl-26_notebook_completo.md)

## Como rodar a ETL

### 1. Abra um clone do repositório e prepare os dados

Clone o repositório com Git, caso ainda não tenha um clone, e abra a pasta `Integracao_BD` no VS Code. O notebook usa a pasta `.git` para localizar a raiz, então baixar apenas o ZIP do código não substitui o clone.

Confirme que os 36 arquivos originais estão diretamente em `data/`, no padrão `pessoas_MM-AAAA.csv`, de `pessoas_01-2021.csv` a `pessoas_12-2023.csv`. Se não vierem no clone, obtenha a coleção original com a equipe. Não é preciso baixar nem copiar os arquivos Parquet: o próprio notebook gera os intermediários em `data/intermediarios/`.

### 2. Prepare o ambiente Python

Use **Python 3.13**, a série registrada no notebook final. No VS Code, tenha as extensões **Python** e **Jupyter** instaladas. Rode os comandos na raiz do clone.

**Windows (PowerShell)**

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt ipykernel
```

**Linux ou WSL (Bash)**

```bash
python3.13 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt ipykernel
```

### 3. Configure e teste a conexão

Na raiz do clone, crie um arquivo `.env` com a variável `DATABASE_URL` e a URI PostgreSQL fornecida pela equipe. O exemplo abaixo é fictício e deve ser substituído por completo.

```dotenv
DATABASE_URL=postgresql://USUARIO:SENHA@HOST:5432/BANCO
```

O usuário do banco deve ter permissão para criar e recriar as tabelas da ETL no ambiente de destino. Não coloque a URI real no README, no notebook ou no Git. Se estiver no Windows, teste com `.\.venv\Scripts\python.exe src/conexao.py`. No Bash com a `.venv` ativa, use `python src/conexao.py`.

> **Atenção à etapa 09.** O DDL apaga e recria as nove tabelas da ETL em `public` antes da carga. O `DROP TABLE ... CASCADE` pode remover objetos que dependem delas. Para reproduzir o pipeline completo, use um banco de testes ou combine a recarga no banco compartilhado com a equipe. Para apenas consultar a execução já feita, abra as saídas salvas no notebook sem rodá-lo.

### 4. Execute o notebook final

Abra [`notebooks/ETL.ipynb`](notebooks/ETL.ipynb), selecione a `.venv` em **Select Kernel** e clique em **Run All**. Não execute os notebooks por etapa separadamente nem rode o script de montagem para uma execução normal. O notebook final já contém o fluxo inteiro.

Na conclusão, compare as saídas com as da execução registrada na ETL-26.

| Conferência | Resultado esperado |
| --- | ---: |
| Arquivos mensais lidos | 36 |
| Dimensões no banco | 8 |
| Linhas em `fato_pessoa_sinistro` | 806.977 |
| Óbitos na fato | 15.793 |
| Chaves estrangeiras sem correspondência | 0 nas 9 verificações |

As consultas usadas na última etapa ficam em [`sql/validacao/etl_checks.sql`](sql/validacao/etl_checks.sql).

## Quem fez o quê na ETL

A tabela resume as contribuições que aparecem nos notebooks e na documentação. A distribuição inicial e o fluxo de revisão estão em [`docs/equipe.md`](docs/equipe.md).

| Integrante | Principais contribuições |
| --- | --- |
| Davi Mello (`@davi01mello`) | Função de diagnóstico da base (ETL-06), modelo estrela (ETL-10), conferência de chaves e duplicatas (ETL-13), dimensões de tempo e gravidade assumidas do Samuel (ETL-19), dimensões de profissão e local de óbito (ETL-22) e montagem da tabela fato (ETL-23). |
| Guilherme Calistrato (`@guicalistrato`) | Conexão ao PostgreSQL (ETL-02), perfil de 2022 (ETL-08), dicionário da fonte (ETL-11), texto e encoding (ETL-14), DDL e dicionário do DW (ETL-18), dimensões de localidade e via (ETL-21) e integração do notebook final (ETL-26). |
| Pedro (`@PedroWellington`) | Fonte e extração (ETL-03 e ETL-05), perfil de 2023 (ETL-09), nulos e categorias (ETL-16), padronização de profissões (ETL-17), dimensões de perfil e transporte (ETL-20), carga no PostgreSQL (ETL-24) e validação pós-carga (ETL-25). |
| Samuel de Almeida (`@safn007`) | Organização do repositório e do quadro (ETL-01 e ETL-04), perfil de 2021 (ETL-07), comparativo entre anos (ETL-12), tratamento de datas (ETL-15), diagrama do fluxo e guia de execução (ETL-27). |

## Fluxo da ELT

A ELT usa os mesmos 36 CSVs da ETL. O notebook [`notebooks/ELT.ipynb`](notebooks/ELT.ipynb) envia os arquivos brutos com `COPY` para `raw.pessoas`. A limpeza de tipos, textos, datas, nulos e profissões roda em SQL no schema `stg`. O PostgreSQL monta as oito dimensões e a tabela fato em `dw_elt`.

![Fluxo da ELT: carga em raw, transformação em stg, modelo estrela em dw_elt e comparação com a ETL.](docs/diagramas/fluxo_elt.png)

[Diagrama editável](docs/diagramas/fluxo_elt.drawio) · [Comparativo ETL × ELT (seção 5 do relatório)](docs/relatorio/relatorio.md#5-comparativo-etl--elt)

### Como rodar a ELT

1. Use o mesmo clone, ambiente Python, arquivos em `data/` e configuração de `DATABASE_URL` da seção **Como rodar a ETL** deste README. Na raiz do projeto, `python src/conexao.py` testa a conexão sem recarregar o banco.
2. Para executar do zero, abra [`notebooks/ELT.ipynb`](notebooks/ELT.ipynb), escolha o kernel do ambiente virtual e use **Run All** em **um banco de teste**. A etapa inicial do notebook executa `DROP SCHEMA ... CASCADE` em `raw`, `stg` e `dw_elt` e recria essas camadas. No banco compartilhado, só faça a recarga se estiver combinada com a equipe.
3. Ao terminar, confira as oito dimensões, as **806.977 linhas na fato** e os **15.793 óbitos**. Para apenas consultar o resultado já carregado, use `SELECT` com o schema explícito e não execute o notebook inteiro.

### Comparar a ELT com a ETL

A validação cruzada fica em [`notebooks/elt/08_validacao.ipynb`](notebooks/elt/08_validacao.ipynb), depois de as estrelas dos dois fluxos estarem no mesmo banco. Ela lê `public` (ETL) e `dw_elt` (ELT) e gera [`sql/validacao/elt_checks.sql`](sql/validacao/elt_checks.sql). As saídas salvas registram contagens iguais nas nove tabelas e nenhum registro divergente nas colunas projetadas pelo `EXCEPT` por tabela.

## Análises

O notebook [`notebooks/analises.ipynb`](notebooks/analises.ipynb) roda as consultas de [`sql/analises/analises.sql`](sql/analises/analises.sql) no Data Warehouse e gera os três gráficos em `docs/relatorio/img/`. Ele só faz `SELECT` e pode ser executado no banco compartilhado. A variável `ESQUEMA` escolhe a estrela da ETL (`public`) ou da ELT (`dw_elt`); o resultado é o mesmo. O texto das análises está na [seção 6 do relatório](docs/relatorio/relatorio.md#6-três-análises-e-insights).

## Quem fez o quê na ELT e no fechamento

| Integrante | Principais contribuições |
| --- | --- |
| Davi Mello (`@davi01mello`) | Carga bruta (ELT-02), nulos, categorias e profissão em SQL (ELT-04), dimensões A (ELT-05), três análises (FIN-01), relatório final e repositório (FIN-02 e FIN-04). |
| Guilherme Calistrato (`@guicalistrato`) | Tipos, texto e datas em SQL (ELT-03) e tabela fato (ELT-07). |
| Pedro Wellington (`@PedroWellington`) | Validação ELT × ETL (ELT-08) e notebook ELT completo (ELT-09). |
| Samuel de Almeida (`@safn007`) | Preparação da fase ELT (ELT-01), dimensões B (ELT-06), comparativo ETL × ELT e diagrama da ELT (ELT-10) e slides (FIN-03). |

## Estrutura do repositório

| Pasta | Conteúdo |
| --- | --- |
| `data/` | Os 36 CSVs originais. `data/intermediarios/` (Parquets da ETL) é gerada pelo notebook e fica fora do Git. |
| `notebooks/` | Os notebooks finais: `ETL.ipynb`, `ELT.ipynb` e `analises.ipynb`. |
| `notebooks/etl/`, `notebooks/elt/` e `notebooks/exploracao/` | Os notebooks por etapa, com as saídas de cada tarefa. São o registro do trabalho individual e a fonte que `scripts/montar_notebook_*.py` usa para montar os notebooks finais. |
| `sql/` | DDL da estrela (`ddl/`), scripts da ELT (`elt/`), validações (`validacao/`) e análises (`analises/`). |
| `src/` | Conexão com o banco (`conexao.py`), execução de arquivos SQL (`rodar_sql.py`) e função de perfil (`perfil.py`). |
| `docs/` | Relatório, modelagem, dicionários, diagramas, perfis dos anos, atas e evidências. |
| `scripts/` | Montagem dos notebooks finais a partir dos notebooks por etapa. |
