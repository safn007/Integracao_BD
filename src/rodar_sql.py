"""Executa scripts da ELT no PostgreSQL com a conexão do projeto."""

import argparse
from pathlib import Path
from pprint import pprint
from typing import Any

from sqlalchemy import Engine

from .conexao import obter_engine


def rodar_sql(
    caminho: str | Path, engine: Engine | None = None
) -> list[dict[str, Any]]:
    """Executa um arquivo UTF-8 e devolve somente as linhas do último comando.

    O script deve conter SQL transacional do PostgreSQL, sem BEGIN, COMMIT
    ou comandos do psql. Sem consulta final, devolve uma lista vazia.
    Uma engine passada pelo chamador deve usar PostgreSQL com psycopg2
    e não deve estar configurada com AUTOCOMMIT.
    """
    sql = Path(caminho).read_text(encoding="utf-8-sig")
    criada_aqui = engine is None
    if engine is None:
        engine = obter_engine()

    try:
        with engine.begin() as conexao:
            # Envia o arquivo inteiro ao driver, preservando blocos SQL
            # e sinais de porcentagem usados, por exemplo, em LIKE.
            resultado = conexao.exec_driver_sql(
                sql, execution_options={"no_parameters": True}
            )
            if resultado.returns_rows:
                return [dict(linha) for linha in resultado.mappings()]
            return []
    finally:
        if criada_aqui:
            engine.dispose()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("arquivo", type=Path, help="Caminho do arquivo .sql")
    args = parser.parse_args()
    linhas = rodar_sql(args.arquivo)
    print(f"Executado: {args.arquivo}")
    if linhas:
        pprint(linhas, sort_dicts=False)


if __name__ == "__main__":
    main()
