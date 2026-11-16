## Padronização de profissão (ETL-17)

**O que foi feito:** padronização da escrita das profissões e criação da coluna `grupo_profissao`. O resultado foi salvo em `data/intermediarios/06_limpo.parquet`.

**Padronização:** maiúsculas, sem acento, sem "(A)" e sem hífen (MOTO-BOY virou MOTO BOY). Duas grafias foram unificadas à mão (MOTOBOY e MOTOFRETISTA). As grafias distintas caíram de 814 para 561.

**Grupos:** a profissão recebe um de 11 grupos por palavras-chave, como TRANSPORTE E ENTREGA, INDUSTRIA E CONSTRUCAO e SAUDE E EDUCACAO. Profissões sem palavra-chave ficam em OUTROS (62.275 linhas, 7,7%), a maior parte da própria categoria OUTRA da fonte (21.544). Quem não tem profissão informada fica em NÃO INFORMADO (85.900 linhas).

**O que não mudou:** nenhuma linha foi removida (806.977). A coluna `profissao` continua com 10,64% de nulos, que a `dim_profissao` trata com o membro -1. A tabela final tem 34 colunas.

**Observação:** os grupos usam palavras-chave e podem ser refinados. Os grupos finais seguem a ordem das regras, e o primeiro que combina vale.