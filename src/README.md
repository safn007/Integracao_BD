# `src/perfil.py`: perfil padronizado das bases (ETL-06)

Perfil (*data profiling*) é um raio-X dos dados: só mede e descreve, não altera nada.
Cada ano (2021, 2022, 2023) passa pela **mesma função** e responde as **mesmas 10 perguntas**,
na mesma ordem, para o comparativo entre anos (ETL-12) ser direto.

## Como usar

```python
from perfil import perfil, perfil_para_markdown

p = perfil(df)                                            # df = tabela de um ano
perfil_para_markdown(p, "docs/perfil/perfil_2021.md", titulo="2021")
```

### No Colab

O repositório precisa estar clonado e a pasta atual precisa ser a raiz dele:

```python
!git clone https://github.com/safn007/Integracao_BD.git
%cd Integracao_BD
import sys; sys.path.append("src")
from perfil import perfil, perfil_para_markdown
```

### Pela linha de comando (teste rápido em um CSV mensal)

```bash
python src/perfil.py data/pessoas_01-2021.csv saida.md
```

## As 10 perguntas (a mesma lista está em `PERGUNTAS`)

| # | Pergunta | Chave do dicionário devolvido |
| --- | --- | --- |
| 1 | Quantas linhas e sinistros distintos? Média de pessoas por sinistro? | `linhas`, `sinistros_distintos`, `pessoas_por_sinistro` |
| 2 | % de nulos de cada coluna? | `nulos` (e `distintos` para os valores distintos) |
| 3 | Domínios de `gravidade_lesao`, `tipo_de_vitima`, `sexo`, `tipo_via`, `tipo_veiculo_vitima`, `regiao_administrativa`? | `dominios` |
| 4 | Valores com caractere inválido ou espaço sobrando? | `texto_suspeito`, `texto_suspeito_resumo` |
| 5 | % de `grau_de_instrucao` preenchido por mês? | `instrucao_por_mes` |
| 6 | Quantos óbitos? As colunas de óbito são nulas nas mesmas linhas? | `obitos` |
| 7 | `id_pessoa` repetido? Linhas 100% idênticas? | `duplicados` |
| 8 | Linhas com mês de `data_sinistro` diferente do mês do arquivo? | `mes_do_arquivo` |
| 9 | Mínimo, máximo e valores impossíveis de `idade`? | `idade` |
| 10 | Algo novo ou estranho (colunas novas/ausentes, constantes, 100% nulas)? | `estranhezas` |

Além disso: `topo_categoricas` (10 valores mais frequentes de cada coluna categórica) e
`linhas_por_mes` (linhas por mês de `data_sinistro`).

O markdown gerado tem as seções 1 a 10 (uma por pergunta, com uma linha **Resposta:** para
vocês escreverem o que os números mostram) e os anexos A (linhas por mês), B (valores
distintos) e C (top 10 por coluna).

## Detalhes que ajudam a interpretar

- **Texto suspeito (pergunta 4):** `espaco_nas_pontas`, `espaco_duplo`, `caractere_invalido`
  (U+FFFD, caractere de controle ou UTF-8 lido como latin-1) e `letra_isolada` (ex.: `S O PAULO`,
  que pode dar falso positivo; as letras `A`, `E`, `O` e `D` são ignoradas). O valor aparece entre
  aspas para os espaços ficarem visíveis.
- **Óbito (pergunta 6):** conta `data_obito` preenchida e confere se as 7 colunas de óbito são nulas
  nas mesmas linhas.
- **Mês do arquivo (pergunta 8):** precisa da coluna `arquivo_origem` com o padrão
  `pessoas_MM-AAAA` (a extração, ETL-05, já cria essa coluna). Sem ela, a pergunta aparece como
  "Não calculado".
- **Idade (pergunta 9):** considera impossível o que está fora de 0 a 110.
- A função **não modifica** o DataFrame recebido e funciona com pandas 2 e com o 3.1.1 do
  `requirements.txt`.
