# Convenções do time

## Fluxo de trabalho
1. Cada tarefa `ETL-XX` é uma **issue** com um dono.
2. Crie uma branch a partir da `main`: `etl-XX-descricao-curta` (ex.: `etl-15-datas`).
3. Trabalhe só no **seu** notebook/arquivo. Ninguém edita o notebook de outro.
4. Abra um **PR** para a `main` usando o template. O revisor é o definido no plano.
5. **Ninguém aprova o próprio PR.** Prazo de revisão: 24 h.
6. Merge só com o PR aprovado.

## Commits
Formato: `tipo(ETL-XX): resumo no imperativo`

Tipos: `feat` (algo novo), `fix` (correção), `docs` (documentação), `data` (diagnóstico/saída de dados), `chore` (organização).

Exemplos:
- `feat(ETL-15): converte colunas de data para datetime`
- `docs(ETL-04): adiciona ata do kickoff`

## Definition of Done
Uma tarefa só vai para **Concluído** quando:
- [ ] o PR foi aprovado por outro membro;
- [ ] o notebook está com as **saídas salvas**;
- [ ] a subseção do relatório foi escrita em `docs/relatorio/secoes/`.

## Notebooks
- Parta de `notebooks/_template_etapa.ipynb` (cabeçalho, setup, diagnóstico antes/depois, salvar, resumo).
- Instale as dependências com `pip install -r requirements.txt`.
- Cada etapa lê o `.parquet` da etapa anterior e grava o seu em `data/intermediarios/`. A pasta é criada automaticamente na primeira execução, e os `.parquet` dentro dela não vão para o Git.
- Durante o sprint 2 todos leem `01_bruto.parquet`. Na execução final, troque só a variável `ENTRADA`.

## Notebook final ETL
- A entrega é **um único notebook: `notebooks/ETL.ipynb`**.
- Os notebooks por etapa (`notebooks/etl/` e `notebooks/exploracao/`) são arquivos de trabalho. Na ETL-26 o script `scripts/montar_notebook_etl.py` os junta e **sobrescreve** o `notebooks/ETL.ipynb`.
- Antes da entrega, um PR de limpeza remove todos os outros `.ipynb`, incluindo o `_template_etapa.ipynb`. Antes dele, crie a tag `etl-notebooks-por-etapa`.
- Até a ETL-26, **ninguém edita o `notebooks/ETL.ipynb` atual** (o código de leitura dele serve de base para a ETL-05).

## ELT — fluxo e documentação reduzida

- Cada tarefa `ELT-XX` tem uma issue, um responsável e o revisor do plano.
- Crie a branch a partir da `main` com o padrão `elt-XX-descricao-curta`. Use commits no formato `tipo(ELT-XX): resumo`, por exemplo `feat(ELT-01): prepara schemas e executor SQL`.
- Abra o PR para a `main` com `Closes #<número da issue>`. Revisão em até 24 h, sem aprovação do próprio autor. Merge só depois da aprovação.
- Nas etapas feitas em SQL, use um arquivo comentado por tarefa em `sql/elt/`, com uma consulta de conferência no fim. Não edite o arquivo de outra tarefa sem combinar com seu responsável. Use nomes qualificados, como `raw.pessoas`, e deixe a transação a cargo de `rodar_sql()`.
- No PostgreSQL, `raw` guarda os dados brutos, `stg` contém a limpeza e `dw_elt` recebe o modelo estrela. O resultado da ETL fica em `public`.
- No PR da ELT, substitua o checklist geral do template por **Rodei do zero** e **A conferência bateu**. Não inclua credenciais nem arquivos de dados gerados.
- Prints só na carga bruta (ELT-02) e no resultado final (ELT-09). O notebook final é `notebooks/ELT.ipynb` e roda as etapas em ordem.
- Só ELT-10, FIN-01 e FIN-02 escrevem seções do relatório nesta fase. O dicionário existente é reaproveitado, pois o modelo é o mesmo.
