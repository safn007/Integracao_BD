"""Monta o notebook unificado ``notebooks/ETL.ipynb`` a partir dos notebooks por etapa.

Uso:
    python scripts/montar_notebook_etl.py
"""

from __future__ import annotations

import re
import warnings
from pathlib import Path
from typing import Callable

import nbformat
from nbformat.v4 import new_code_cell, new_markdown_cell, new_notebook
from nbformat.validator import MissingIDFieldWarning

RAIZ = Path(__file__).resolve().parent.parent
DIR_ETAPAS = RAIZ / "notebooks" / "etl"
SAIDA_NOTEBOOK = RAIZ / "notebooks" / "ETL.ipynb"

ETAPAS: list[tuple[str, str]] = [
    ("01_extracao.ipynb", "Etapa 01 · Extração dos 36 CSVs (ETL-05)"),
    ("02_chaves_duplicatas.ipynb", "Etapa 02 · Chaves e duplicatas (ETL-13)"),
    ("03_texto_encoding.ipynb", "Etapa 03 · Texto e encoding (ETL-14)"),
    ("04_datas.ipynb", "Etapa 04 · Datas de sinistro e óbito (ETL-15)"),
    ("05_nulos_categorias.ipynb", "Etapa 05 · Nulos e categorias (ETL-16)"),
    ("06_profissao.ipynb", "Etapa 06 · Padronização de profissão (ETL-17)"),
    ("07a_dim_tempo_gravidade.ipynb", "Etapa 07a · dim_tempo e dim_gravidade (ETL-19)"),
    ("07b_dim_perfil_transporte.ipynb", "Etapa 07b · dim_perfil_vitima e dim_transporte (ETL-20)"),
    ("07c_dim_localidade_via.ipynb", "Etapa 07c · dim_localidade e dim_via (ETL-21)"),
    ("07d_dim_profissao_local_obito.ipynb", "Etapa 07d · dim_profissao e dim_local_obito (ETL-22)"),
    ("08_fato.ipynb", "Etapa 08 · Tabela fato (ETL-23)"),
    ("09_carga.ipynb", "Etapa 09 · Carga no PostgreSQL (ETL-24)"),
    ("10_validacao.ipynb", "Etapa 10 · Validação pós-carga (ETL-25)"),
]

CABECALHO_MD = """\
# Pipeline ETL Completo — Sinistros de Trânsito (SP, 2021–2023)

- **Tarefa:** ETL-26 · Notebook ETL completo, rodado do zero
- **Responsável:** Guilherme Calistrato (`@guicalistrato`) | **Revisor:** Davi Mello (`@davi01mello`)
- **Fonte:** 36 arquivos CSV mensais em `data/pessoas_MM-AAAA.csv` (806.977 registros)
- **Destino:** Esquema estrela (`fato_pessoa_sinistro` + 8 dimensões) no PostgreSQL (Supabase)
- **Geração automática:** este notebook foi montado a partir das etapas em `notebooks/etl/` pelo script `scripts/montar_notebook_etl.py`, com as entradas encadeadas ponta a ponta.

## Visão geral do encadeamento

| Ordem | Etapa | Entrada | Saída |
| --- | --- | --- | --- |
| 01 | Extração (`ETL-05`) | `data/pessoas_*.csv` | `01_bruto.parquet` |
| 02 | Chaves e duplicatas (`ETL-13`) | `01_bruto.parquet` | `02_chaves_duplicatas.parquet` |
| 03 | Texto e encoding (`ETL-14`) | `02_chaves_duplicatas.parquet` | `03_texto.parquet` |
| 04 | Datas (`ETL-15`) | `03_texto.parquet` | `04_datas.parquet` |
| 05 | Nulos e categorias (`ETL-16`) | `04_datas.parquet` | `05_nulos_categorias.parquet` |
| 06 | Profissão (`ETL-17`) | `05_nulos_categorias.parquet` | `06_limpo.parquet` |
| 07a | `dim_tempo` e `dim_gravidade` (`ETL-19`) | `06_limpo.parquet` | `dims/dim_tempo.parquet`, `dims/dim_gravidade.parquet` |
| 07b | `dim_perfil_vitima` e `dim_transporte` (`ETL-20`) | `06_limpo.parquet` | `dims/dim_perfil_vitima.parquet`, `dims/dim_transporte.parquet` |
| 07c | `dim_localidade` e `dim_via` (`ETL-21`) | `06_limpo.parquet` | `dims/dim_localidade.parquet`, `dims/dim_via.parquet` |
| 07d | `dim_profissao` e `dim_local_obito` (`ETL-22`) | `06_limpo.parquet` | `dims/dim_profissao.parquet`, `dims/dim_local_obito.parquet` |
| 08 | Tabela fato (`ETL-23`) | `06_limpo.parquet` + `dims/*.parquet` | `fato.parquet` |
| 09 | Carga no PostgreSQL (`ETL-24`) | `sql/ddl/etl_star_schema.sql` + parquets | 9 tabelas no schema `public` |
| 10 | Validação pós-carga (`ETL-25`) | Banco PostgreSQL | `sql/validacao/etl_checks.sql` |
"""

SETUP_GLOBAL_CODE = """\
import io
import os
import sys
from datetime import timedelta
from pathlib import Path

import pandas as pd
from IPython.display import display

# Raiz do repositório: sobe de pasta em pasta até achar a pasta .git
RAIZ = next(p for p in [Path.cwd(), *Path.cwd().parents] if (p / ".git").exists())
os.chdir(RAIZ)

if str(RAIZ / "src") not in sys.path:
    sys.path.append(str(RAIZ / "src"))

from conexao import obter_engine, testar_conexao
from perfil import _p4_texto

DADOS  = RAIZ / "data"
INTERM = DADOS / "intermediarios"
DIMS   = INTERM / "dims"
INTERM.mkdir(parents=True, exist_ok=True)
DIMS.mkdir(parents=True, exist_ok=True)


def diagnostico(df: pd.DataFrame) -> pd.DataFrame:
    \"\"\"Tabela-resumo usada antes e depois: tipo, % de nulos e nº de valores distintos por coluna.\"\"\"
    return pd.DataFrame({
        "dtype": df.dtypes.astype(str),
        "pct_nulo": (df.isna().mean() * 100).round(2),
        "n_distintos": df.nunique(),
    })


print("RAIZ:", RAIZ)
"""

# Linhas de boilerplate repetidas no Setup de cada etapa e que passam a viver no Setup Global
PADROES_REMOVER_LINHA = [
    re.compile(r"^from pathlib import Path\s*$"),
    re.compile(r"^import (?:os|io|sys|pandas as pd)\s*$"),
    re.compile(r"^from IPython\.display import display\s*$"),
    re.compile(r"^from datetime import timedelta\s*$"),
    re.compile(r"^#\s*Raiz do repositório.*$"),
    re.compile(r"^RAIZ\s*=\s*next\(p for p in.*$"),
    re.compile(r"^os\.chdir\(RAIZ\).*$"),
    re.compile(r"^if str\(RAIZ / [\"']src[\"']\) not in sys\.path:\s*$"),
    re.compile(r"^\s*sys\.path\.append\(str\(RAIZ / [\"']src[\"']\)\)\s*$"),
    re.compile(r"^from (?:src\.)?conexao import .*$"),
    re.compile(r"^from perfil import _p4_texto.*$"),
    re.compile(r"^DADOS\s*=\s*RAIZ / [\"']data[\"'].*$"),
    re.compile(r"^INTERM\s*=\s*(?:RAIZ / [\"']data[\"']|DADOS) / [\"']intermediarios[\"'].*$"),
    re.compile(r"^DIMS\s*=\s*INTERM / [\"']dims[\"'].*$"),
    re.compile(r"^(?:INTERM|DIMS)\.mkdir\(parents=True, exist_ok=True\)\s*$"),
]

# Bloco idêntico de definição de `diagnostico` presente na maioria das etapas
PADRAO_DEF_DIAGNOSTICO = re.compile(
    r"def diagnostico\(df: pd\.DataFrame\) -> pd\.DataFrame:\n"
    r"\s+\"\"\"[^\"]+\"\"\"\n"
    r"\s+return pd\.DataFrame\(\{\n"
    r"(?:\s+[\"'][^\"']+[\"']:.*\n)+"
    r"\s+\}\)\n*"
)


def substituir_exato(texto: str, antigo: str, novo: str, contexto: str) -> str:
    """Substitui ``antigo`` por ``novo`` exatamente uma vez, falhando se não encontrar."""
    ocorrencias = texto.count(antigo)
    if ocorrencias != 1:
        raise ValueError(
            f"[{contexto}] Esperada 1 ocorrência para substituição, encontradas {ocorrencias}:\n{antigo}"
        )
    return texto.replace(antigo, novo, 1)


def _patch_03(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entrada:** `data/intermediarios/01_bruto.parquet` *(na execução final, usar a saída da etapa `02_chaves_duplicatas`)*",
        "- **Entrada:** `data/intermediarios/02_chaves_duplicatas.parquet`",
        "03_texto_encoding/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA = INTERM / "01_bruto.parquet"       # na execução final, trocar para 02_chaves.parquet',
        'ENTRADA = INTERM / "02_chaves_duplicatas.parquet"',
        "03_texto_encoding/setup",
    )
    celulas[11] = substituir_exato(
        celulas[11],
        'comparacao = antes.join(depois, lsuffix="_antes", rsuffix="_depois")',
        'comparacao = antes.join(depois, suffixes=("_antes", "_depois"))',
        "03_texto_encoding/diagnostico_depois",
    )
    return celulas


def _patch_04(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entrada:** `intermediarios/01_bruto.parquet`",
        "- **Entrada:** `data/intermediarios/03_texto.parquet`",
        "04_datas/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA = INTERM / "01_bruto.parquet"',
        'ENTRADA = INTERM / "03_texto.parquet"',
        "04_datas/setup",
    )
    return celulas


def _patch_05(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entrada:** `data/pessoas_*.csv`\n- **Saída:** `intermediarios/<arquivo>.parquet`",
        "- **Entrada:** `data/intermediarios/04_datas.parquet`\n- **Saída:** `data/intermediarios/05_nulos_categorias.parquet`",
        "05_nulos_categorias/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'SAIDA = INTERM / "05_nulos_categorias.parquet"  # resultado desta etapa',
        'ENTRADA = INTERM / "04_datas.parquet"             # saída da etapa anterior (ETL-15)\n'
        'SAIDA   = INTERM / "05_nulos_categorias.parquet"  # resultado desta etapa',
        "05_nulos_categorias/setup",
    )
    celulas[4] = (
        "df = pd.read_parquet(ENTRADA)\n"
        "print('entrada:', ENTRADA.name, '| shape:', df.shape)\n"
        "df.head()"
    )
    celulas[18] = substituir_exato(
        celulas[18],
        "    for col in ['idade', 'id_veiculo', 'ano_obito', 'mes_obito', 'dia_obito']:\n"
        "        df[col] = df[col].astype('Int64')\n"
        "    return df\n"
        "\n"
        "df = converter_inteiros(df)\n"
        "print(df[['idade', 'id_veiculo', 'ano_obito', 'mes_obito', 'dia_obito']].dtypes)",
        "    colunas_alvo = [c for c in ['idade', 'id_veiculo', 'ano_obito', 'mes_obito', 'dia_obito'] if c in df.columns]\n"
        "    for col in colunas_alvo:\n"
        "        df[col] = df[col].astype('Int64')\n"
        "    return df\n"
        "\n"
        "df = converter_inteiros(df)\n"
        "colunas_int = [c for c in ['idade', 'id_veiculo', 'ano_obito', 'mes_obito', 'dia_obito'] if c in df.columns]\n"
        "print(df[colunas_int].dtypes)",
        "05_nulos_categorias/converter_inteiros",
    )
    celulas[20] = substituir_exato(
        celulas[20],
        "tabela = df.groupby('ano_mes_sinistro')['grau_de_instrucao'].apply(lambda s: round(s.notna().mean() * 100, 2))",
        "competencia = df['ano_mes_sinistro'] if 'ano_mes_sinistro' in df.columns else df['data_sinistro'].dt.strftime('%Y-%m')\n"
        "tabela = df.groupby(competencia)['grau_de_instrucao'].apply(lambda s: round(s.notna().mean() * 100, 2))",
        "05_nulos_categorias/grau_de_instrucao",
    )
    return celulas


def _patch_06(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entrada:** `data/intermediarios/03_texto.parquet`",
        "- **Entrada:** `data/intermediarios/05_nulos_categorias.parquet`",
        "06_profissao/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA = INTERM / "03_texto.parquet"          # saída da ETL-14',
        'ENTRADA = INTERM / "05_nulos_categorias.parquet"  # saída da ETL-16',
        "06_profissao/setup",
    )
    celulas[15] = substituir_exato(
        celulas[15],
        "df.loc[df['profissao'].isna(), 'grupo_profissao'] = 'NÃO INFORMADO'",
        "sem_prof = df['profissao'].isna() | df['profissao'].isin(['NAO INFORMADO', 'NÃO INFORMADO'])\n"
        "df.loc[sem_prof, 'grupo_profissao'] = 'NÃO INFORMADO'",
        "06_profissao/grupo_profissao",
    )
    return celulas


def _patch_07a(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entradas:** `data/intermediarios/04_datas.parquet` (datas convertidas, ETL-15) e `data/intermediarios/05_nulos_categorias.parquet` (`gravidade_lesao`, ETL-16)",
        "- **Entrada:** `data/intermediarios/06_limpo.parquet`",
        "07a_dim_tempo_gravidade/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA_DATAS     = INTERM / "04_datas.parquet"             # saída da ETL-15: datas já convertidas\n'
        'ENTRADA_GRAVIDADE = INTERM / "05_nulos_categorias.parquet"  # saída da ETL-16: gravidade_lesao ainda com NAO DISPONIVEL',
        'ENTRADA_DATAS     = INTERM / "06_limpo.parquet"\n'
        'ENTRADA_GRAVIDADE = INTERM / "06_limpo.parquet"',
        "07a_dim_tempo_gravidade/setup",
    )
    return celulas


def _patch_07b(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entrada:** `data/intermediarios/05_nulos_categorias.parquet`",
        "- **Entrada:** `data/intermediarios/06_limpo.parquet`",
        "07b_dim_perfil_transporte/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA = INTERM / "05_nulos_categorias.parquet"   # saída da ETL-16',
        'ENTRADA = INTERM / "06_limpo.parquet"              # base limpa unificada',
        "07b_dim_perfil_transporte/setup",
    )
    return celulas


def _patch_07c(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entradas:** `data/intermediarios/03_texto.parquet` (`dim_localidade`, saída da ETL-14) e `data/intermediarios/05_nulos_categorias.parquet` (`dim_via`, saída da ETL-16) *(na execução encadeada final, ambas apontam para `06_limpo.parquet`)*",
        "- **Entrada:** `data/intermediarios/06_limpo.parquet`",
        "07c_dim_localidade_via/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA_LOCALIDADE = INTERM / "03_texto.parquet"             # saída da ETL-14: municípios e regiões limpos\n'
        'ENTRADA_VIA        = INTERM / "05_nulos_categorias.parquet"  # saída da ETL-16: tipo_via e local_via tratados',
        'ENTRADA_LOCALIDADE = INTERM / "06_limpo.parquet"\n'
        'ENTRADA_VIA        = INTERM / "06_limpo.parquet"',
        "07c_dim_localidade_via/setup",
    )
    return celulas


def _patch_07d(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entradas:** `data/intermediarios/06_limpo.parquet` (profissão, ETL-17) e `data/intermediarios/05_nulos_categorias.parquet` (local do óbito, ETL-16)",
        "- **Entrada:** `data/intermediarios/06_limpo.parquet`",
        "07d_dim_profissao_local_obito/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        'ENTRADA_PROFISSAO = INTERM / "06_limpo.parquet"           # saída da ETL-17: profissao e grupo_profissao\n'
        'ENTRADA_LOCAL     = INTERM / "05_nulos_categorias.parquet"  # saída da ETL-16: local_obito e flag_obito',
        'ENTRADA_PROFISSAO = INTERM / "06_limpo.parquet"\n'
        'ENTRADA_LOCAL     = INTERM / "06_limpo.parquet"',
        "07d_dim_profissao_local_obito/setup",
    )
    return celulas


def _patch_08(celulas: list[str]) -> list[str]:
    celulas[0] = substituir_exato(
        celulas[0],
        "- **Entradas:** a base limpa (saídas das ETL-13 a ETL-17 em `data/intermediarios/`) e as 8 dimensões em `data/intermediarios/dims/` (ETL-19 a ETL-22)",
        "- **Entradas:** `data/intermediarios/06_limpo.parquet` e as 8 dimensões em `data/intermediarios/dims/` (ETL-19 a ETL-22)",
        "08_fato/header",
    )
    celulas[2] = substituir_exato(
        celulas[2],
        "FONTES = {\n"
        "    'ids (ETL-13)':        (INTERM / '02_chaves_duplicatas.parquet', ['id_sinistro', 'id_veiculo']),\n"
        "    'datas (ETL-15)':      (INTERM / '04_datas.parquet', ['data_sinistro', 'data_obito', 'dias_ate_obito']),\n"
        "    'localidade (ETL-14)': (INTERM / '03_texto.parquet', ['cod_ibge']),\n"
        "    'categorias (ETL-16)': (INTERM / '05_nulos_categorias.parquet',\n"
        "                            ['gravidade_lesao', 'local_obito', 'idade', 'flag_obito',\n"
        "                             *COLUNAS_TRANSPORTE, *COLUNAS_PERFIL, *COLUNAS_VIA]),\n"
        "    'profissão (ETL-17)':  (INTERM / '06_limpo.parquet', ['profissao']),\n"
        "}",
        "FONTES = {\n"
        "    'ids (ETL-13)':        (INTERM / '06_limpo.parquet', ['id_sinistro', 'id_veiculo']),\n"
        "    'datas (ETL-15)':      (INTERM / '06_limpo.parquet', ['data_sinistro', 'data_obito', 'dias_ate_obito']),\n"
        "    'localidade (ETL-14)': (INTERM / '06_limpo.parquet', ['cod_ibge']),\n"
        "    'categorias (ETL-16)': (INTERM / '06_limpo.parquet',\n"
        "                            ['gravidade_lesao', 'local_obito', 'idade', 'flag_obito',\n"
        "                             *COLUNAS_TRANSPORTE, *COLUNAS_PERFIL, *COLUNAS_VIA]),\n"
        "    'profissão (ETL-17)':  (INTERM / '06_limpo.parquet', ['profissao']),\n"
        "}",
        "08_fato/setup",
    )
    return celulas


PATCHES_POR_ETAPA: dict[str, Callable[[list[str]], list[str]]] = {
    "03_texto_encoding.ipynb": _patch_03,
    "04_datas.ipynb": _patch_04,
    "05_nulos_categorias.ipynb": _patch_05,
    "06_profissao.ipynb": _patch_06,
    "07a_dim_tempo_gravidade.ipynb": _patch_07a,
    "07b_dim_perfil_transporte.ipynb": _patch_07b,
    "07c_dim_localidade_via.ipynb": _patch_07c,
    "07d_dim_profissao_local_obito.ipynb": _patch_07d,
    "08_fato.ipynb": _patch_08,
}


def limpar_boilerplate_codigo(codigo: str) -> str:
    """Remove imports e definições globais já centralizados no Setup Global."""
    linhas_filtradas = [
        linha
        for linha in codigo.splitlines()
        if not any(padrao.match(linha) for padrao in PADROES_REMOVER_LINHA)
    ]
    texto = "\n".join(linhas_filtradas)
    texto = PADRAO_DEF_DIAGNOSTICO.sub("", texto)
    texto = re.sub(r"\n{3,}", "\n\n", texto)
    return texto.strip()


def rebaixar_titulos_markdown(md: str) -> str:
    """Rebaixa títulos Markdown da etapa em um nível (``##`` -> ``###``) fora de blocos de código."""
    linhas = []
    em_bloco_codigo = False
    for linha in md.splitlines():
        if linha.strip().startswith("```"):
            em_bloco_codigo = not em_bloco_codigo
        if not em_bloco_codigo and linha.startswith("#"):
            linha = "#" + linha
        linhas.append(linha)
    return "\n".join(linhas)


def montar_notebook() -> nbformat.NotebookNode:
    """Lê os notebooks de etapa, aplica o encadeamento e gera o notebook unificado."""
    celulas_finais = [
        new_markdown_cell(CABECALHO_MD.strip()),
        new_markdown_cell("## Setup Global"),
        new_code_cell(SETUP_GLOBAL_CODE.strip()),
    ]

    for arquivo, titulo_etapa in ETAPAS:
        caminho = DIR_ETAPAS / arquivo
        if not caminho.is_file():
            raise FileNotFoundError(f"Notebook de etapa não encontrado: {caminho}")

        with warnings.catch_warnings():
            warnings.simplefilter("ignore", MissingIDFieldWarning)
            nb_etapa = nbformat.read(caminho, as_version=4)
        fontes = [c.source for c in nb_etapa.cells]
        if arquivo in PATCHES_POR_ETAPA:
            fontes = PATCHES_POR_ETAPA[arquivo](fontes)

        for idx, (celula, fonte) in enumerate(zip(nb_etapa.cells, fontes)):
            if idx == 0 and celula.cell_type == "markdown":
                # Substitui o título de topo da etapa pelo título padronizado em nível H2
                linhas_cabecalho = fonte.splitlines()
                corpo_cabecalho = "\n".join(linhas_cabecalho[1:]).strip()
                md_etapa = f"---\n\n## {titulo_etapa}"
                if corpo_cabecalho:
                    md_etapa = f"{md_etapa}\n\n{corpo_cabecalho}"
                celulas_finais.append(new_markdown_cell(md_etapa))
                continue

            if celula.cell_type == "markdown":
                celulas_finais.append(new_markdown_cell(rebaixar_titulos_markdown(fonte)))
            elif celula.cell_type == "code":
                codigo_limpo = limpar_boilerplate_codigo(fonte)
                if codigo_limpo:
                    celulas_finais.append(new_code_cell(codigo_limpo))

    for seq, celula in enumerate(celulas_finais):
        celula["id"] = f"etl-{seq:03d}"

    notebook = new_notebook(cells=celulas_finais)
    notebook.metadata["kernelspec"] = {
        "display_name": "Python 3",
        "language": "python",
        "name": "python3",
    }
    notebook.metadata["language_info"] = {
        "name": "python",
    }
    return notebook


def main() -> None:
    notebook = montar_notebook()
    SAIDA_NOTEBOOK.parent.mkdir(parents=True, exist_ok=True)
    nbformat.write(notebook, SAIDA_NOTEBOOK)
    n_code = sum(1 for c in notebook.cells if c.cell_type == "code")
    n_md = sum(1 for c in notebook.cells if c.cell_type == "markdown")
    print(f"Gerado: {SAIDA_NOTEBOOK.relative_to(RAIZ)} | {len(notebook.cells)} células ({n_md} markdown, {n_code} código)")


if __name__ == "__main__":
    main()
