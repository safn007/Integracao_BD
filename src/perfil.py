"""Perfil padronizado (data profiling) das bases de sinistros. Tarefa ETL-06.

Perfil é um raio-X dos dados: só mede e descreve, não altera nada. Todo ano
(2021, 2022, 2023) passa pela MESMA função e responde as MESMAS 10 perguntas,
na mesma ordem, para o comparativo entre anos (ETL-12) ser direto.

Como usar
---------
    from perfil import perfil, perfil_para_markdown

    p = perfil(df)                                    # df = tabela de um ano
    perfil_para_markdown(p, "docs/perfil/perfil_2021.md", titulo="2021")

No Colab (a pasta atual precisa ser a raiz do repositório):

    !git clone https://github.com/safn007/Integracao_BD.git
    %cd Integracao_BD
    import sys; sys.path.append("src")
    from perfil import perfil, perfil_para_markdown

Pela linha de comando, em um CSV mensal (teste rápido):

    python src/perfil.py data/pessoas_01-2021.csv saida.md

Regras
------
* A função nunca modifica o DataFrame recebido.
* Funciona com a tabela como sai da extração (tudo texto) e com versões
  posteriores (datas em datetime, números em Int64). Pergunta que não pode ser
  respondida (coluna ausente) vira ``None`` no dicionário e um aviso no markdown.
* Só depende de pandas e numpy (já estão no requirements.txt).
"""
from __future__ import annotations

import numbers
import re
import sys
from pathlib import Path

import numpy as np
import pandas as pd

__all__ = ["perfil", "perfil_para_markdown", "PERGUNTAS"]

# As 10 perguntas padrão. Cada perfil anual responde TODAS, por escrito, com número.
PERGUNTAS = [
    "1. Quantas linhas e quantos sinistros distintos há? Qual a média de pessoas por sinistro?",
    "2. Qual o % de nulos de cada coluna?",
    "3. Quais os domínios (valores e contagens) de gravidade_lesao, tipo_de_vitima, sexo, "
    "tipo_via, tipo_veiculo_vitima e regiao_administrativa?",
    "4. Há valores com caractere inválido/acento corrompido ou com espaço sobrando?",
    "5. Qual o % de grau_de_instrucao preenchido em cada mês?",
    "6. Quantos óbitos há e qual o % do total? As colunas de óbito são nulas nas mesmas linhas?",
    "7. Há id_pessoa repetido? E linhas 100% idênticas?",
    "8. Há linhas cujo mês de data_sinistro difere do mês do arquivo de origem?",
    "9. Quais o mínimo, o máximo e os valores impossíveis de idade?",
    "10. Há algo novo ou estranho (colunas novas ou ausentes, colunas constantes ou 100% nulas)?",
]

# As 31 colunas da fonte, na ordem em que aparecem nos CSVs de 2021 a 2023.
COLUNAS_ESPERADAS = [
    "id_sinistro", "id_pessoa", "id_veiculo", "cod_ibge", "municipio",
    "regiao_administrativa", "tipo_via", "tipo_veiculo_vitima", "tipo_de_vitima",
    "modo_transporte_vitima", "sexo", "idade", "gravidade_lesao",
    "faixa_etaria_demografica", "faixa_etaria_legal", "profissao",
    "grau_de_instrucao", "nacionalidade", "data_sinistro", "ano_sinistro",
    "mes_sinistro", "dia_sinistro", "ano_mes_sinistro", "data_obito", "ano_obito",
    "mes_obito", "dia_obito", "ano_mes_obito", "local_obito", "local_via",
    "tempo_sinistro_obito",
]
# Colunas que a nossa extração (ETL-05) acrescenta.
COLUNAS_RASTREIO = ["ano_origem", "arquivo_origem"]
# As 7 colunas de óbito: só têm valor para quem morreu.
COLUNAS_OBITO = [
    "data_obito", "ano_obito", "mes_obito", "dia_obito",
    "ano_mes_obito", "local_obito", "tempo_sinistro_obito",
]
COLUNAS_DOMINIO = [
    "gravidade_lesao", "tipo_de_vitima", "sexo", "tipo_via",
    "tipo_veiculo_vitima", "regiao_administrativa",
]
IDENTIFICADORES = {"id_sinistro", "id_pessoa", "id_veiculo"}
# Não faz sentido listar "os 10 valores mais comuns" destas colunas.
NAO_CATEGORICAS = IDENTIFICADORES | {
    "data_sinistro", "data_obito", "idade", "tempo_sinistro_obito", "cod_ibge",
    "arquivo_origem",
}
IDADE_MIN, IDADE_MAX = 0, 110

# Caractere inválido: U+FFFD, caracteres de controle ou "mojibake" (UTF-8 lido como latin-1).
_RE_INVALIDO = re.compile(
    r"[\ufffd\x00-\x08\x0b\x0c\x0e-\x1f\x7f-\x9f]|[\u00c3\u00c2][\u0080-\u00bf]"
)
# Letras soltas legítimas em português (artigos, "e", "d'Oeste"): não contam como quebra.
_LETRAS_OK = {"A", "E", "O", "D"}
_RE_ARQUIVO = r"pessoas_(\d{2})-(\d{4})"


# ---------------------------------------------------------------- utilidades
def _e_texto(s: pd.Series) -> bool:
    return (
        pd.api.types.is_string_dtype(s)
        or pd.api.types.is_object_dtype(s)
        or isinstance(s.dtype, pd.CategoricalDtype)
    )


def _como_data(s: pd.Series) -> pd.Series:
    """Converte dd/mm/aaaa para datetime; o que não converte vira NaT."""
    if pd.api.types.is_datetime64_any_dtype(s):
        return s
    return pd.to_datetime(s, format="%d/%m/%Y", errors="coerce")


def _distribuicao(s: pd.Series, topo: int | None = None) -> pd.DataFrame:
    """Valores, contagens e % de uma coluna, do mais ao menos frequente (nulo incluso)."""
    vc = s.value_counts(dropna=False)
    vc = vc[vc > 0]
    d = pd.DataFrame({
        "valor": ["(nulo)" if pd.isna(v) else str(v) for v in vc.index],
        "n": vc.to_numpy(dtype="int64"),
    })
    d["pct"] = (d["n"] / max(len(s), 1) * 100).round(2)
    d = d.sort_values(["n", "valor"], ascending=[False, True], kind="stable")
    d = d.reset_index(drop=True)
    return d.head(topo) if topo else d


def _motivos(valor: str) -> list[str]:
    """Por que um valor de texto é suspeito (lista vazia = valor ok)."""
    m = []
    if valor != valor.strip():
        m.append("espaco_nas_pontas")
    if "  " in valor.strip():
        m.append("espaco_duplo")
    if _RE_INVALIDO.search(valor):
        m.append("caractere_invalido")
    if any(len(t) == 1 and t.isalpha() and t.upper() not in _LETRAS_OK for t in valor.split()):
        m.append("letra_isolada")  # ex.: "S O PAULO" (acento perdido)
    return m


# ------------------------------------------------- uma função por pergunta
def _p1_visao_geral(df: pd.DataFrame) -> dict:
    out = {"linhas": int(len(df)), "n_colunas": int(df.shape[1]), "colunas": list(df.columns)}
    if "id_sinistro" in df.columns:
        por_sinistro = df["id_sinistro"].value_counts()
        out["sinistros_distintos"] = int(len(por_sinistro))
        out["pessoas_por_sinistro"] = (
            {
                "media": float(por_sinistro.mean()),
                "mediana": float(por_sinistro.median()),
                "max": int(por_sinistro.max()),
            }
            if len(por_sinistro)
            else None
        )
    return out


def _p2_nulos(df: pd.DataFrame) -> pd.DataFrame:
    n = df.isna().sum().to_numpy(dtype="int64")
    return pd.DataFrame({
        "coluna": list(df.columns),
        "n_nulos": n,
        "pct_nulos": (n / max(len(df), 1) * 100).round(2),
    })


def _p4_texto(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Valores de texto suspeitos + resumo por coluna e motivo."""
    achados = []
    for ordem, col in enumerate(df.columns):
        if col in IDENTIFICADORES or not _e_texto(df[col]):
            continue
        vc = df[col].dropna().astype(str).value_counts()
        for valor, n in vc.items():
            motivos = _motivos(valor)
            if motivos:
                achados.append((ordem, col, valor, int(n), "+".join(motivos)))
    det = pd.DataFrame(achados, columns=["_ordem", "coluna", "valor", "n", "motivo"])
    det = det.sort_values(["_ordem", "n", "valor"], ascending=[True, False, True], kind="stable")
    det = det.drop(columns="_ordem").reset_index(drop=True)

    resumo = {}
    for _, r in det.iterrows():
        for m in r["motivo"].split("+"):
            v, n = resumo.get((r["coluna"], m), (0, 0))
            resumo[(r["coluna"], m)] = (v + 1, n + int(r["n"]))
    res = pd.DataFrame(
        [(c, m, v, n) for (c, m), (v, n) in resumo.items()],
        columns=["coluna", "motivo", "valores_distintos", "linhas"],
    )
    return det, res


def _p5_instrucao_por_mes(df: pd.DataFrame, datas: pd.Series | None) -> pd.DataFrame | None:
    if "grau_de_instrucao" not in df.columns or datas is None:
        return None
    t = pd.DataFrame({
        "ano_mes": datas.dt.strftime("%Y-%m"),
        "ok": df["grau_de_instrucao"].notna(),
    }).dropna(subset=["ano_mes"])
    g = t.groupby("ano_mes")["ok"].agg(["size", "sum"]).reset_index()
    g.columns = ["ano_mes", "linhas", "preenchidos"]
    g["linhas"] = g["linhas"].astype("int64")
    g["preenchidos"] = g["preenchidos"].astype("int64")
    g["pct_preenchido"] = (g["preenchidos"] / g["linhas"] * 100).round(2)
    return g.sort_values("ano_mes").reset_index(drop=True)


def _p6_obitos(df: pd.DataFrame) -> dict | None:
    if "data_obito" not in df.columns:
        return None
    n = len(df)
    obitos = int(df["data_obito"].notna().sum())
    out = {
        "obitos": obitos,
        "pct_obitos": round(obitos / n * 100, 2) if n else None,
    }
    if "gravidade_lesao" in df.columns:
        fatal = df["gravidade_lesao"].dropna().astype(str).str.strip().str.upper() == "FATAL"
        out["gravidade_fatal"] = int(fatal.sum())
    presentes = [c for c in COLUNAS_OBITO if c in df.columns]
    out["colunas_obito"] = presentes
    if presentes:
        nulas_por_linha = df[presentes].isna().sum(axis=1)
        inconsistentes = ~((nulas_por_linha == 0) | (nulas_por_linha == len(presentes)))
        out["n_linhas_obito_inconsistentes"] = int(inconsistentes.sum())
        out["colunas_obito_nulas_juntas"] = bool(inconsistentes.sum() == 0)
    return out


def _p7_duplicados(df: pd.DataFrame) -> dict:
    out = {}
    if "id_pessoa" in df.columns:
        c = df["id_pessoa"].value_counts()
        rep = c[c > 1]
        out["n_id_pessoa_nulo"] = int(df["id_pessoa"].isna().sum())
        out["n_ids_repetidos"] = int(len(rep))
        out["n_linhas_com_id_repetido"] = int(rep.sum())
        out["n_linhas_excedentes_por_id"] = int((rep - 1).sum())
    sem_rastreio = df.drop(columns=[c for c in COLUNAS_RASTREIO if c in df.columns])
    out["n_linhas_identicas"] = int(sem_rastreio.duplicated().sum())
    return out


def _p8_mes_do_arquivo(df: pd.DataFrame, datas: pd.Series | None) -> dict | None:
    if "arquivo_origem" not in df.columns or datas is None:
        return None
    ext = df["arquivo_origem"].astype(str).str.extract(_RE_ARQUIVO)
    mes_arquivo = ext[1] + "-" + ext[0]  # AAAA-MM
    mes_data = datas.dt.strftime("%Y-%m")
    comparaveis = mes_arquivo.notna() & mes_data.notna()
    diverge = comparaveis & (mes_arquivo != mes_data)
    exemplos = pd.DataFrame({
        "arquivo_origem": df["arquivo_origem"][diverge],
        "data_sinistro": df["data_sinistro"][diverge],
    }).head(10)
    n_data_nula = int(df["data_sinistro"].isna().sum())
    return {
        "n_comparaveis": int(comparaveis.sum()),
        "n_divergentes": int(diverge.sum()),
        "pct_divergentes": round(diverge.sum() / max(comparaveis.sum(), 1) * 100, 2),
        "n_data_sinistro_nula": n_data_nula,
        "n_data_sinistro_invalida": int(datas.isna().sum()) - n_data_nula,
        "n_arquivo_sem_padrao": int(mes_arquivo.isna().sum()),
        "exemplos": exemplos.reset_index(drop=True),
    }


def _p9_idade(df: pd.DataFrame) -> dict | None:
    if "idade" not in df.columns:
        return None
    bruta = df["idade"]
    num = pd.to_numeric(bruta, errors="coerce")
    invalida = (num < IDADE_MIN) | (num > IDADE_MAX)
    minimo, maximo = num.min(), num.max()
    return {
        "n_nulas": int(bruta.isna().sum()),
        "n_nao_numericas": int((num.isna() & bruta.notna()).sum()),
        "minimo": None if pd.isna(minimo) else float(minimo),
        "maximo": None if pd.isna(maximo) else float(maximo),
        "intervalo_valido": [IDADE_MIN, IDADE_MAX],
        "n_invalidas": int(invalida.sum()),
        "exemplos_invalidos": sorted(float(x) for x in num[invalida].dropna().unique())[:10],
    }


def _p10_estranhezas(df: pd.DataFrame) -> dict:
    cols = list(df.columns)
    n = len(df)
    esperadas_no_df = [c for c in cols if c in COLUNAS_ESPERADAS]
    esperadas_na_ordem = [c for c in COLUNAS_ESPERADAS if c in cols]
    return {
        "colunas_faltando": [c for c in COLUNAS_ESPERADAS if c not in cols],
        "colunas_novas": [c for c in cols if c not in COLUNAS_ESPERADAS and c not in COLUNAS_RASTREIO],
        "ordem_diferente": esperadas_no_df != esperadas_na_ordem,
        "colunas_constantes": [
            c for c in cols if c not in COLUNAS_RASTREIO and df[c].nunique() == 1
        ],
        "colunas_100pct_nulas": [c for c in cols if n and df[c].isna().all()],
        "nomes_de_coluna_com_espaco": [c for c in cols if str(c) != str(c).strip()],
    }


# ------------------------------------------------------------- função pública
def perfil(df: pd.DataFrame) -> dict:
    """Raio-X de uma tabela: devolve um dicionário com as respostas das 10 perguntas.

    Chaves principais (os DataFrames têm colunas simples, prontas para ``display``):
      linhas, n_colunas, colunas, sinistros_distintos, pessoas_por_sinistro   (pergunta 1)
      nulos, distintos                       (pergunta 2 e nunique por coluna)
      dominios                               (3: dict coluna -> DataFrame valor/n/pct)
      texto_suspeito, texto_suspeito_resumo  (4)
      instrucao_por_mes                      (5)
      obitos                                 (6)
      duplicados                             (7)
      mes_do_arquivo                         (8)
      idade                                  (9)
      estranhezas                            (10)
      topo_categoricas                       (top 10 de cada coluna categórica)
      linhas_por_mes                         (linhas por mês de data_sinistro)
    """
    datas = _como_data(df["data_sinistro"]) if "data_sinistro" in df.columns else None

    p = _p1_visao_geral(df)
    p["nulos"] = _p2_nulos(df)
    p["distintos"] = pd.DataFrame({
        "coluna": list(df.columns),
        "n_distintos": [int(df[c].nunique()) for c in df.columns],
    })
    p["dominios"] = {c: _distribuicao(df[c]) for c in COLUNAS_DOMINIO if c in df.columns}
    p["dominios_ausentes"] = [c for c in COLUNAS_DOMINIO if c not in df.columns]
    p["texto_suspeito"], p["texto_suspeito_resumo"] = _p4_texto(df)
    p["instrucao_por_mes"] = _p5_instrucao_por_mes(df, datas)
    p["obitos"] = _p6_obitos(df)
    p["duplicados"] = _p7_duplicados(df)
    p["mes_do_arquivo"] = _p8_mes_do_arquivo(df, datas)
    p["idade"] = _p9_idade(df)
    p["estranhezas"] = _p10_estranhezas(df)
    p["topo_categoricas"] = {
        c: _distribuicao(df[c], topo=10)
        for c in df.columns
        if c not in NAO_CATEGORICAS and _e_texto(df[c])
    }
    if datas is not None:
        vc = datas.dt.strftime("%Y-%m").value_counts().sort_index()
        lpm = pd.DataFrame({"ano_mes": list(vc.index), "linhas": vc.to_numpy(dtype="int64")})
        lpm["pct"] = (lpm["linhas"] / max(len(df), 1) * 100).round(2)
        p["linhas_por_mes"] = lpm
    else:
        p["linhas_por_mes"] = None
    return p


# ------------------------------------------------------------------ markdown
def _fmt(v) -> str:
    if v is None:
        return "—"
    if isinstance(v, (bool, np.bool_)):
        return "sim" if v else "não"
    if isinstance(v, numbers.Integral):
        return f"{int(v):,}".replace(",", ".")
    if isinstance(v, numbers.Real):
        if v != v:  # NaN
            return "—"
        return f"{float(v):,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return str(v).replace("|", "\\|").replace("\n", " ")


def _tabela(df: pd.DataFrame, cabecalho: list[str] | None = None) -> str:
    cols = cabecalho or [str(c) for c in df.columns]
    linhas = ["| " + " | ".join(cols) + " |", "| " + " | ".join("---" for _ in cols) + " |"]
    for row in df.itertuples(index=False):
        linhas.append("| " + " | ".join(_fmt(v) for v in row) + " |")
    return "\n".join(linhas)


def _pares(pares: list[tuple[str, object]]) -> str:
    # Sem DataFrame de propósito: uma coluna mista (inteiros e decimais) viraria float
    # e "19534" sairia "19.534,00".
    linhas = ["| métrica | valor |", "| --- | --- |"]
    linhas += [f"| {_fmt(nome)} | {_fmt(valor)} |" for nome, valor in pares]
    return "\n".join(linhas)


def _lista(itens: list) -> str:
    return ", ".join(f"`{i}`" for i in itens) if itens else "nenhuma"


_RESPOSTA = "**Resposta:** _escreva aqui o que os números mostram._"
_MAX_LINHAS_TEXTO = 40


def _montar_markdown(p: dict, titulo: str) -> str:
    L: list[str] = []
    add = L.append

    def secao(i: int) -> None:
        add(f"## {PERGUNTAS[i]}")
        add("")

    def aviso(motivo: str) -> None:
        add(f"_Não calculado: {motivo}._")
        add("")

    add(f"# Perfil da base: {titulo}")
    add("")
    add(
        "> Gerado por `src/perfil.py` (ETL-06). As seções 1 a 10 respondem as 10 perguntas "
        "padrão e aparecem sempre na mesma ordem, em todos os anos. Escreva as respostas "
        "depois de gerar e não gere de novo por cima do arquivo editado."
    )
    add("")

    # 1
    secao(0)
    pps = p.get("pessoas_por_sinistro") or {}
    add(_pares([
        ("Linhas", p["linhas"]),
        ("Colunas", p["n_colunas"]),
        ("Sinistros distintos (id_sinistro)", p.get("sinistros_distintos")),
        ("Pessoas por sinistro: média", pps.get("media")),
        ("Pessoas por sinistro: mediana", pps.get("mediana")),
        ("Pessoas por sinistro: máximo", pps.get("max")),
    ]))
    add("")
    add(_RESPOSTA)
    add("")

    # 2
    secao(1)
    add(_tabela(p["nulos"], ["coluna", "nulos", "% nulos"]))
    add("")
    add(_RESPOSTA)
    add("")

    # 3
    secao(2)
    for col, d in p["dominios"].items():
        add(f"### {col}")
        add("")
        add(_tabela(d, ["valor", "n", "%"]))
        add("")
    if p["dominios_ausentes"]:
        aviso("colunas ausentes: " + _lista(p["dominios_ausentes"]))
    add(_RESPOSTA)
    add("")

    # 4
    secao(3)
    det, res = p["texto_suspeito"], p["texto_suspeito_resumo"]
    est = p["estranhezas"]
    add(f"Nomes de coluna com espaço: {_lista(est['nomes_de_coluna_com_espaco'])}.")
    add("")
    if det.empty:
        add("Nenhum valor de texto suspeito.")
    else:
        add(
            f"{_fmt(len(det))} valores distintos suspeitos. Motivos: `espaco_nas_pontas`, "
            "`espaco_duplo`, `caractere_invalido` (U+FFFD, controle, UTF-8 lido como latin-1) "
            "e `letra_isolada` (ex.: `S O PAULO`; pode ter falso positivo)."
        )
        add("")
        add(_tabela(res, ["coluna", "motivo", "valores distintos", "linhas"]))
        add("")
        mostra = det.head(_MAX_LINHAS_TEXTO).copy()
        mostra["valor"] = [f"`{v!r}`" for v in mostra["valor"]]
        if len(det) > _MAX_LINHAS_TEXTO:
            add(f"Detalhe (as {_MAX_LINHAS_TEXTO} primeiras de {_fmt(len(det))}):")
        else:
            add("Detalhe:")
        add("")
        add(_tabela(mostra, ["coluna", "valor", "n", "motivo"]))
    add("")
    add(_RESPOSTA)
    add("")

    # 5
    secao(4)
    if p["instrucao_por_mes"] is None:
        aviso("`grau_de_instrucao` ou `data_sinistro` ausente")
    else:
        add(_tabela(p["instrucao_por_mes"], ["mês", "linhas", "preenchidos", "% preenchido"]))
        add("")
    add(_RESPOSTA)
    add("")

    # 6
    secao(5)
    ob = p["obitos"]
    if ob is None:
        aviso("`data_obito` ausente")
    else:
        add(_pares([
            ("Óbitos (data_obito preenchida)", ob["obitos"]),
            ("% do total de linhas", ob["pct_obitos"]),
            ("Linhas com gravidade_lesao = FATAL", ob.get("gravidade_fatal")),
            ("Colunas de óbito encontradas", len(ob["colunas_obito"])),
            ("Nulas nas mesmas linhas?", ob.get("colunas_obito_nulas_juntas")),
            ("Linhas com óbito parcial (inconsistentes)", ob.get("n_linhas_obito_inconsistentes")),
        ]))
        add("")
    add(_RESPOSTA)
    add("")

    # 7
    secao(6)
    d7 = p["duplicados"]
    add(_pares([
        ("id_pessoa nulo", d7.get("n_id_pessoa_nulo")),
        ("id_pessoa que aparece mais de uma vez", d7.get("n_ids_repetidos")),
        ("Linhas com id_pessoa repetido", d7.get("n_linhas_com_id_repetido")),
        ("Linhas excedentes por id_pessoa", d7.get("n_linhas_excedentes_por_id")),
        ("Linhas 100% idênticas (excedentes, sem as colunas de rastreio)", d7["n_linhas_identicas"]),
    ]))
    add("")
    add(_RESPOSTA)
    add("")

    # 8
    secao(7)
    m8 = p["mes_do_arquivo"]
    if m8 is None:
        aviso("`arquivo_origem` ou `data_sinistro` ausente")
    else:
        add(_pares([
            ("Linhas comparáveis (mês do arquivo e da data conhecidos)", m8["n_comparaveis"]),
            ("Linhas com mês divergente", m8["n_divergentes"]),
            ("% divergente", m8["pct_divergentes"]),
            ("data_sinistro nula", m8["n_data_sinistro_nula"]),
            ("data_sinistro preenchida mas inválida", m8["n_data_sinistro_invalida"]),
            ("arquivo_origem fora do padrão pessoas_MM-AAAA", m8["n_arquivo_sem_padrao"]),
        ]))
        add("")
        if len(m8["exemplos"]):
            add("Exemplos de divergência:")
            add("")
            add(_tabela(m8["exemplos"]))
            add("")
    add(_RESPOSTA)
    add("")

    # 9
    secao(8)
    i9 = p["idade"]
    if i9 is None:
        aviso("`idade` ausente")
    else:
        add(_pares([
            ("Mínimo observado", i9["minimo"]),
            ("Máximo observado", i9["maximo"]),
            (f"Fora de {i9['intervalo_valido'][0]} a {i9['intervalo_valido'][1]}", i9["n_invalidas"]),
            ("Exemplos fora do intervalo", ", ".join(_fmt(x) for x in i9["exemplos_invalidos"]) or None),
            ("Nulas", i9["n_nulas"]),
            ("Preenchidas mas não numéricas", i9["n_nao_numericas"]),
        ]))
        add("")
    add(_RESPOSTA)
    add("")

    # 10
    secao(9)
    add(f"- Colunas esperadas que faltam: {_lista(est['colunas_faltando'])}")
    add(f"- Colunas novas (fora das 31 da fonte e do rastreio): {_lista(est['colunas_novas'])}")
    add(f"- Ordem das colunas diferente da fonte: {_fmt(est['ordem_diferente'])}")
    add(
        f"- Colunas com um único valor: {_lista(est['colunas_constantes'])} "
        "(em um perfil de um ano ou de um mês, as colunas de ano e de mês são constantes: é esperado)"
    )
    add(f"- Colunas 100% nulas: {_lista(est['colunas_100pct_nulas'])}")
    add("")
    add(_RESPOSTA)
    add("")

    # Anexos (mesma ordem sempre)
    add("## Anexo A. Linhas por mês de data_sinistro")
    add("")
    if p["linhas_por_mes"] is None:
        aviso("`data_sinistro` ausente")
    else:
        add(_tabela(p["linhas_por_mes"], ["mês", "linhas", "%"]))
        add("")
    add("## Anexo B. Valores distintos por coluna")
    add("")
    add(_tabela(p["distintos"], ["coluna", "valores distintos"]))
    add("")
    add("## Anexo C. Os 10 valores mais frequentes de cada coluna categórica")
    add("")
    for col, d in p["topo_categoricas"].items():
        add(f"### {col}")
        add("")
        add(_tabela(d, ["valor", "n", "%"]))
        add("")
    return "\n".join(L).rstrip() + "\n"


def perfil_para_markdown(p: dict, caminho: str | Path, titulo: str = "base") -> str:
    """Grava o perfil em markdown (sempre as mesmas seções, na mesma ordem).

    Cria as pastas que faltarem e devolve o texto gravado.
    """
    texto = _montar_markdown(p, titulo)
    caminho = Path(caminho)
    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_text(texto, encoding="utf-8", newline="\n")
    return texto


# ------------------------------------------------------------ linha de comando
def _main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("uso: python src/perfil.py <arquivo.csv> [saida.md]")
        return 1
    csv = Path(argv[1])
    # Leitura de teste: separador ';', latin-1, tudo como texto (igual à extração).
    df = pd.read_csv(csv, sep=";", encoding="latin-1", dtype=str,
                     keep_default_na=False, na_values=[""])
    df["arquivo_origem"] = csv.name
    p = perfil(df)
    if len(argv) > 2:
        perfil_para_markdown(p, argv[2], titulo=csv.stem)
        print(f"{csv.name}: {p['linhas']} linhas x {p['n_colunas']} colunas -> {argv[2]}")
    else:
        sys.stdout.write(_montar_markdown(p, csv.stem))
    return 0


if __name__ == "__main__":
    raise SystemExit(_main(sys.argv))
