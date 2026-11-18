"""Monta notebooks/ELT.ipynb com as etapas da ELT na ordem, a partir de sql/elt (ELT-09)."""

import json
from pathlib import Path

RAIZ = next(p for p in [Path.cwd(), *Path.cwd().parents] if (p / ".git").exists())
SQL_ELT = RAIZ / "sql" / "elt"
SAIDA = RAIZ / "notebooks" / "ELT.ipynb"

# arquivo .sql -> título, issue, o que produz, consulta de conferência
ETAPAS = {
    "00_schemas.sql": (
        "Schemas",
        "ELT-01",
        "os schemas `raw`, `stg` e `dw_elt`",
        "SELECT nspname AS schema FROM pg_namespace\nWHERE nspname IN ('raw', 'stg', 'dw_elt')\nORDER BY nspname",
    ),
    "01_stg_tipos_texto_datas.sql": (
        "Tipos, texto e datas",
        "ELT-03",
        "a tabela `stg.pessoas_tipos_texto_datas`",
        "SELECT COUNT(*) AS linhas FROM stg.pessoas_tipos_texto_datas",
    ),
    "02_stg_nulos_profissao.sql": (
        "Nulos e profissão",
        "ELT-04",
        "a view `stg.pessoas_nulos_profissao`",
        "SELECT COUNT(*) AS linhas FROM stg.pessoas_nulos_profissao",
    ),
    "03_dims_a.sql": (
        "Dimensões A",
        "ELT-05",
        "`dim_tempo`, `dim_gravidade`, `dim_profissao` e `dim_local_obito`",
        "SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas FROM dw_elt.dim_tempo\n"
        "UNION ALL SELECT 'dim_gravidade', COUNT(*) FROM dw_elt.dim_gravidade\n"
        "UNION ALL SELECT 'dim_profissao', COUNT(*) FROM dw_elt.dim_profissao\n"
        "UNION ALL SELECT 'dim_local_obito', COUNT(*) FROM dw_elt.dim_local_obito",
    ),
    "04_dims_b.sql": (
        "Dimensões B",
        "ELT-06",
        "`dim_perfil_vitima`, `dim_transporte`, `dim_localidade` e `dim_via`",
        "SELECT 'dim_perfil_vitima' AS tabela, COUNT(*) AS linhas FROM dw_elt.dim_perfil_vitima\n"
        "UNION ALL SELECT 'dim_transporte', COUNT(*) FROM dw_elt.dim_transporte\n"
        "UNION ALL SELECT 'dim_localidade', COUNT(*) FROM dw_elt.dim_localidade\n"
        "UNION ALL SELECT 'dim_via', COUNT(*) FROM dw_elt.dim_via",
    ),
    "05_fato.sql": (
        "Tabela fato",
        "ELT-07",
        "a tabela `dw_elt.fato_pessoa_sinistro`",
        "SELECT COUNT(*) AS linhas, SUM(flag_obito) AS obitos FROM dw_elt.fato_pessoa_sinistro",
    ),
}

CARGA = "CARGA_BRUTA"  # etapa em Python, entre o 00_schemas e o 01_stg
ORDEM = ["00_schemas.sql", CARGA, "01_stg_tipos_texto_datas.sql",
         "02_stg_nulos_profissao.sql", "03_dims_a.sql", "04_dims_b.sql", "05_fato.sql"]

encontrados = sorted(p.name for p in SQL_ELT.glob("*.sql"))
faltando = [a for a in encontrados if a not in ETAPAS]
if faltando:
    raise SystemExit(f"sql/elt tem arquivo fora da lista ETAPAS: {faltando}")


def md(texto):
    return {"cell_type": "markdown", "metadata": {}, "source": texto.strip().splitlines(keepends=True)}


def code(texto):
    return {"cell_type": "code", "execution_count": None, "metadata": {},
            "outputs": [], "source": texto.strip().splitlines(keepends=True)}


# ---------------------------------------------------------------- cabeçalho

linhas_tabela = []
for i, item in enumerate(ORDEM, start=1):
    if item == CARGA:
        linhas_tabela.append(f"| {i} | Carga bruta | ELT-02 | COPY dos 36 CSVs | a tabela `raw.pessoas` |")
    else:
        titulo, issue, saida, _ = ETAPAS[item]
        linhas_tabela.append(f"| {i} | {titulo} | {issue} | `sql/elt/{item}` | {saida} |")

cells = [md(f"""
# Pipeline ELT Completo — Sinistros de Trânsito (SP, 2021–2023)

- **Tarefa:** ELT-09 · Notebook ELT completo, rodado do zero
- **Responsável:** Pedro Wellington (`@PedroWellington`) | **Revisor:** Guilherme Calistrato (`@guicalistrato`)
- **Fonte:** 36 arquivos CSV mensais em `data/pessoas_MM-AAAA.csv` (806.977 registros)
- **Destino:** esquema estrela no schema `dw_elt` do PostgreSQL (Supabase)
- **Geração automática:** este notebook foi montado pelo script `scripts/montar_notebook_elt.py` a partir dos arquivos de `sql/elt/`.

No ELT o dado vai cru para o banco e a transformação acontece toda em SQL. Aqui as etapas rodam na ordem, do zero, e cada uma tem o tempo medido.

| Ordem | Etapa | Issue | O que roda | Saída |
| --- | --- | --- | --- | --- |
{chr(10).join(linhas_tabela)}

A execução inteira leva alguns minutos, a maior parte deles na carga dos CSVs.
""")]

# ---------------------------------------------------------------- setup

cells += [md("## 1. Setup"), code('''
import os
import time
from pathlib import Path

import pandas as pd
from IPython.display import display

# Raiz do repositório: sobe de pasta em pasta até achar a pasta .git
RAIZ = next(p for p in [Path.cwd(), *Path.cwd().parents] if (p / ".git").exists())
os.chdir(RAIZ)

from src.conexao import obter_engine, testar_conexao

DADOS = RAIZ / "data"
SQL_ELT = RAIZ / "sql" / "elt"

engine = obter_engine()
TEMPOS = []   # (etapa, segundos), para o quadro do final


def rodar_sql(arquivo: str, etapa: str) -> float:
    """Executa um arquivo de sql/elt inteiro, numa transação só, e guarda o tempo."""
    sql = (SQL_ELT / arquivo).read_text(encoding="utf-8")
    engine.dispose()   # conexão nova: tabelas temporárias da etapa anterior não atrapalham
    inicio = time.perf_counter()
    conexao = engine.raw_connection()
    try:
        with conexao.cursor() as cur:
            cur.execute(sql)
        conexao.commit()
    except Exception:
        conexao.rollback()
        raise
    finally:
        conexao.close()
    segundos = time.perf_counter() - inicio
    TEMPOS.append((etapa, segundos))
    print(f"{etapa}: {segundos:.1f} s")
    return segundos


def consulta(sql: str) -> pd.DataFrame:
    return pd.read_sql(sql, engine)


_ = testar_conexao()
''')]

# ---------------------------------------------------------------- limpeza

cells += [md("""
## 2. Limpar o que existe

Rodar do zero significa reconstruir as três camadas. Cada arquivo SQL já apaga e recria as próprias
tabelas, mas a fato de uma execução anterior segura as dimensões e impede o `DROP`. Por isso os
schemas são derrubados antes de começar.

Enquanto o notebook não termina, a ELT fica fora do banco. Se parar no meio, é só rodar de novo
desde o começo.
"""), code('''
engine.dispose()
conexao = engine.raw_connection()
try:
    with conexao.cursor() as cur:
        for schema in ["dw_elt", "stg", "raw"]:
            cur.execute(f"DROP SCHEMA IF EXISTS {schema} CASCADE")
    conexao.commit()
finally:
    conexao.close()

consulta("""
SELECT nspname AS schema FROM pg_namespace
WHERE nspname IN ('raw', 'stg', 'dw_elt')
ORDER BY nspname
""")
''')]

# ---------------------------------------------------------------- etapas

for i, item in enumerate(ORDEM, start=1):
    n = i + 2   # as seções 1 e 2 são o setup e a limpeza

    if item == CARGA:
        cells += [md(f"""
## {n}. Carga bruta (ELT-02)

Os 36 CSVs entram crus em `raw.pessoas`: quem lê o arquivo é o próprio PostgreSQL, com `COPY` em
`latin-1` e separador `;`. As 31 colunas ficam como texto e cada linha ganha `ano_origem` e
`arquivo_origem`. Tudo numa transação só, então uma falha no meio não deixa carga pela metade.
"""), code('''
TABELA = "raw.pessoas"

arquivos = sorted(DADOS.glob("pessoas_*.csv"))
assert len(arquivos) == 36, f"esperava 36 arquivos, achei {len(arquivos)}"

with open(arquivos[0], encoding="latin-1") as f:
    COLUNAS = f.readline().strip().split(";")

DDL = (
    f"DROP TABLE IF EXISTS {TABELA};\\n"
    f"CREATE TABLE {TABELA} (\\n"
    + "".join(f"    {c} TEXT,\\n" for c in COLUNAS)
    + "    ano_origem SMALLINT NOT NULL,\\n"
    + "    arquivo_origem TEXT NOT NULL);"
)
COPY_CSV = "COPY carga FROM STDIN WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'LATIN1')"

engine.dispose()
inicio = time.perf_counter()
conexao = engine.raw_connection()
try:
    with conexao.cursor() as cur:
        cur.execute(DDL)
        cur.execute(f"CREATE TEMP TABLE carga ({', '.join(f'{c} TEXT' for c in COLUNAS)}) ON COMMIT DROP")
        for arquivo in arquivos:
            cur.execute("TRUNCATE carga")
            with open(arquivo, "rb") as f:
                cur.copy_expert(COPY_CSV, f)
            cur.execute(f"INSERT INTO {TABELA} SELECT carga.*, %s, %s FROM carga",
                        (int(arquivo.stem[-4:]), arquivo.name))
        cur.execute(f"ANALYZE {TABELA}")
    conexao.commit()
except Exception:
    conexao.rollback()
    raise
finally:
    conexao.close()

TEMPOS.append(("Carga bruta (ELT-02)", time.perf_counter() - inicio))
print(f"Carga bruta (ELT-02): {TEMPOS[-1][1]:.1f} s")

consulta(f"SELECT COUNT(*) AS linhas, COUNT(DISTINCT arquivo_origem) AS arquivos FROM {TABELA}")
''')]
        continue

    titulo, issue, saida, conferencia = ETAPAS[item]
    cells += [md(f"""
## {n}. {titulo} ({issue})

Roda `sql/elt/{item}`, que cria {saida}.
"""), code(f'''
rodar_sql("{item}", "{titulo} ({issue})")

consulta("""
{conferencia}
""")
''')]

# ---------------------------------------------------------------- resultado

n_final = len(ORDEM) + 3
cells += [md(f"""
## {n_final}. Resultado final

Tempo de cada etapa e as 9 tabelas do modelo estrela no schema `dw_elt`.
"""), code('''
tempos = pd.DataFrame(TEMPOS, columns=["etapa", "segundos"]).round({"segundos": 1})
display(tempos)

contagens = consulta("""
SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas FROM dw_elt.dim_tempo
UNION ALL SELECT 'dim_gravidade', COUNT(*) FROM dw_elt.dim_gravidade
UNION ALL SELECT 'dim_perfil_vitima', COUNT(*) FROM dw_elt.dim_perfil_vitima
UNION ALL SELECT 'dim_transporte', COUNT(*) FROM dw_elt.dim_transporte
UNION ALL SELECT 'dim_localidade', COUNT(*) FROM dw_elt.dim_localidade
UNION ALL SELECT 'dim_via', COUNT(*) FROM dw_elt.dim_via
UNION ALL SELECT 'dim_profissao', COUNT(*) FROM dw_elt.dim_profissao
UNION ALL SELECT 'dim_local_obito', COUNT(*) FROM dw_elt.dim_local_obito
UNION ALL SELECT 'fato_pessoa_sinistro', COUNT(*) FROM dw_elt.fato_pessoa_sinistro
""")
display(contagens)

total = float(tempos["segundos"].sum())
linhas_fato = int(contagens.loc[contagens["tabela"] == "fato_pessoa_sinistro", "linhas"].iloc[0])
print(f"ELT completa em {total / 60:.1f} min ({total:.0f} s) | fato com {linhas_fato} linhas")
''')]

# ---------------------------------------------------------------- gravar

notebook = {
    "cells": cells,
    "metadata": {
        "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
        "language_info": {"name": "python"},
    },
    "nbformat": 4,
    "nbformat_minor": 5,
}

SAIDA.write_text(json.dumps(notebook, ensure_ascii=False, indent=1), encoding="utf-8")
print(f"{len(cells)} células gravadas em {SAIDA.relative_to(RAIZ)}")