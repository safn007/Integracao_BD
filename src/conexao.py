"""Módulo de conexão com o banco de dados PostgreSQL (Supabase).

Compatível tanto com execução local (via arquivo .env) quanto com o Google Colab
(via Secrets do Colab: google.colab.userdata).
"""

import os
from pathlib import Path
from typing import Optional
from sqlalchemy import create_engine, Engine, text
from dotenv import load_dotenv


def _carregar_variaveis_ambiente() -> None:
    """Procura e carrega o arquivo .env tanto na raiz do repositório quanto em src/."""
    # 1. Tenta carregar a partir da pasta atual e seus diretórios pais
    caminho_atual = Path(__file__).resolve().parent
    possiveis_env = [
        caminho_atual / ".env",          # src/.env
        caminho_atual.parent / ".env",   # raiz/.env
        Path.cwd() / ".env",             # diretório de trabalho atual
    ]
    for env_path in possiveis_env:
        if env_path.is_file():
            load_dotenv(dotenv_path=env_path, override=False)


def obter_database_url() -> str:
    """Obtém a URL de conexão do PostgreSQL.

    Ordem de busca:
    1. Secrets do Google Colab (google.colab.userdata.get('DATABASE_URL'))
    2. Variáveis de ambiente / arquivo .env local (os.getenv('DATABASE_URL'))

    Retorna:
        str: URL de conexão formatada com o driver postgresql+psycopg2://.

    Lança:
        ValueError: Se a variável DATABASE_URL não for encontrada.
    """
    database_url: Optional[str] = None

    # 1. Tenta obter dos Secrets do Google Colab
    try:
        from google.colab import userdata  # type: ignore
        database_url = userdata.get("DATABASE_URL")
    except (ImportError, ModuleNotFoundError):
        pass
    except Exception:
        # Usuário pode estar no Colab mas ainda não criou a chave nos Secrets
        pass

    # 2. Se não estiver no Colab ou não encontrou no Colab, busca localmente
    if not database_url:
        _carregar_variaveis_ambiente()
        database_url = os.getenv("DATABASE_URL")

    if not database_url:
        raise ValueError(
            "DATABASE_URL não foi encontrada!\n"
            "- Se estiver rodando localmente: verifique se o arquivo .env existe e contém DATABASE_URL=...\n"
            "- Se estiver no Google Colab: adicione 'DATABASE_URL' no ícone de chave 🔑 (Secrets) e marque 'Notebook access'."
        )

    # 3. Normaliza o prefixo para usar o driver psycopg2 com SQLAlchemy
    if database_url.startswith("postgres://"):
        database_url = database_url.replace("postgres://", "postgresql+psycopg2://", 1)
    elif database_url.startswith("postgresql://") and not database_url.startswith("postgresql+"):
        database_url = database_url.replace("postgresql://", "postgresql+psycopg2://", 1)

    return database_url


def obter_engine(echo: bool = False) -> Engine:
    """Cria e retorna uma Engine do SQLAlchemy configurada para o PostgreSQL/Supabase.

    Args:
        echo (bool): Se True, o SQLAlchemy loga todas as queries SQL executadas.

    Retorna:
        Engine: Objeto de engine pronto para uso com pandas ou SQLAlchemy.
    """
    url = obter_database_url()
    # pool_pre_ping=True verifica se a conexão ainda está viva antes de usá-la,
    # prevenindo erros de timeout comuns em conexões com cloud/pooler.
    return create_engine(url, pool_pre_ping=True, echo=echo)


def testar_conexao() -> bool:
    """Testa a conexão executando uma consulta simples no PostgreSQL.

    Retorna:
        bool: True se a conexão foi bem-sucedida.
    """
    try:
        engine = obter_engine()
        with engine.connect() as conn:
            query = text("SELECT version(), current_database(), current_user;")
            resultado = conn.execute(query).fetchone()
            if resultado:
                versao, banco, usuario = resultado
                print(" Conexão estabelecida com sucesso!")
                print(f" Banco de Dados : {banco}")
                print(f" Usuário         : {usuario}")
                print(f" Versão SGDB     : {versao[:45]}...")
                return True
        return False
    except Exception as e:
        print(" Falha ao conectar ao banco de dados:")
        print(e)
        return False


if __name__ == "__main__":
    testar_conexao()
