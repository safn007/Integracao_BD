# ETL-06 · Conexão com o Banco de Dados PostgreSQL (Supabase)

- **Responsável:** Equipe de Integração de Dados
- **Issue:** ETL-06
- **Tecnologias:** PostgreSQL (Supabase), SQLAlchemy 2.0, Psycopg2-binary, Python-dotenv, Google Colab Secrets

---

## 1. Contexto e Motivação
Para as etapas de persistência e carga dos dados (ETL) e transformações diretamente no banco (ELT), foi configurada uma instância em nuvem do PostgreSQL hospedada na plataforma **Supabase**.

A infraestrutura precisava atender aos seguintes requisitos:
1. **Acessibilidade híbrida:** capacidade de conexão tanto a partir das máquinas locais dos integrantes quanto a partir do ambiente do **Google Colab**.
2. **Compatibilidade de rede (IPv4 / Google Colab):** o ambiente gratuito do Google Colab não oferece conectividade nativa IPv6. A conexão direta padrão do Supabase opera em IPv6, o que causaria falhas de resolução de rede (`Network is unreachable`). Por isso, foi configurado o **Session Pooler (Supavisor)** na porta `5432`, garantindo roteamento transparente via IPv4.
3. **Segurança de credenciais:** nenhuma credencial, usuário ou senha pode ser exposta no repositório Git. Foi adotada a segregação por `.env` em ambiente local e *Colab Secrets* (`google.colab.userdata`) em nuvem.

---

## 2. Arquitetura e Implementação

### 2.1 Módulo Reutilizável (`src/conexao.py`)
Foi desenvolvido o módulo `src/conexao.py` contendo:
- `obter_database_url()`: Busca a string de conexão priorizando `google.colab.userdata.get('DATABASE_URL')` se estiver no Colab, ou `os.getenv('DATABASE_URL')` via `python-dotenv` se estiver local. Também normaliza automaticamente o protocolo para `postgresql+psycopg2://`.
- `obter_engine(echo=False)`: Cria o objeto `Engine` do SQLAlchemy com o parâmetro `pool_pre_ping=True`, prevenindo desconexões ociosas típicas de instâncias gerenciadas em nuvem.
- `testar_conexao()`: Executa uma consulta de verificação de sanidade (`SELECT version(), current_database(), current_user;`) confirmando a conectividade sem expor dados sensíveis no terminal ou no relatório.

### 2.2 Gerenciamento de Dependências
O arquivo `requirements.txt` foi atualizado com as versões fixadas:
- `sqlalchemy==2.0.49`
- `psycopg2-binary==2.9.10`
- `python-dotenv==1.2.2`

### 2.3 Instruções de Configuração

#### Localmente
1. Copie o arquivo `.env.example` para `.env`:
   ```bash
   cp .env.example .env
   ```
2. Preencha o valor de `DATABASE_URL` com a senha do banco.
3. Execute o teste com:
   ```bash
   python src/conexao.py
   ```

#### No Google Colab
1. Abra o notebook no Colab.
2. Na barra lateral, acesse o ícone de chave 🔑 (**Secrets**).
3. Adicione uma chave com o nome `DATABASE_URL` e o valor da connection string completa.
4. Habilite a opção **Notebook access**.
