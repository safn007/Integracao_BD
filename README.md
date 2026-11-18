# Projeto de Integração de Dados: Sinistros de Trânsito (2021 a 2023)

Projeto da disciplina de Banco de Dados. O objetivo é integrar bases de dados de vítimas de sinistros de trânsito de 2021 a 2023, usando pipelines de ETL e ELT.

## Integrantes
- Davi Mello <dsm5>
- Guilherme Calistrato <gcnt>
- Pedro Wellinton <pwffl>
- Samuel de Almeida <safn>

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