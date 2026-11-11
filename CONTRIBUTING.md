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
- Cada etapa lê o `.parquet` da etapa anterior e grava o seu em `data/intermediarios/` (ignorado pelo Git).
- Durante o sprint 2 todos leem `01_bruto.parquet`. Na execução final, troque só a variável `ENTRADA`.
