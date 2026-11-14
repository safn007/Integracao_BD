## Chaves e duplicatas (ETL-13, etapa 02)

**O que foi feito:** o notebook `notebooks/etl/02_chaves_duplicatas.ipynb` prepara as chaves que o modelo estrela usa. Ele lê a base bruta e grava `data/intermediarios/02_chaves_duplicatas.parquet`.

**Transformações:**
1. **IDs para inteiro.** `id_sinistro`, `id_pessoa` e `cod_ibge` viraram `int64`. `id_veiculo` virou `Int64`, o inteiro que aceita nulo, porque é nulo em 21,04% das linhas (169.754: pedestres e registros sem veículo). A conversão interrompe o notebook se algum valor não for número. Nenhum valor se perdeu, e os nulos ficaram exatamente iguais aos de antes.
2. **Linhas 100% duplicadas.** A comparação usa as 31 colunas da fonte, sem as colunas de rastreio, para pegar também uma linha repetida em dois arquivos mensais. Foram encontradas **0**, então nenhuma linha foi removida e a base continua com **806.977 linhas**.
3. **`id_pessoa` único.** São 806.977 valores distintos em 806.977 linhas, então ele pode ser a chave primária da tabela fato.
4. **`cod_ibge` → município.** São 645 códigos para 645 municípios (relação 1:1), cada um em uma única das 16 regiões administrativas. O `cod_ibge` é uma chave natural segura para a `dim_localidade`.

**Conferências de integridade:**
- Nenhum veículo aparece em mais de um sinistro.
- Cada sinistro tem uma única data e um único município.

**Achado:** 1.211 linhas (571 grupos) são idênticas em tudo, exceto no `id_pessoa`. **Não foram removidas**, porque são pessoas diferentes registradas no mesmo sinistro com os mesmos atributos. A maioria tem tipo de vítima "NAO DISPONIVEL" (643) ou é passageiro (470). O caso fica registrado para quem for interpretar contagens por perfil.

| Indicador | Antes | Depois |
| --- | --- | --- |
| Linhas | 806.977 | 806.977 |
| Linhas 100% duplicadas | 0 | 0 |
| `id_pessoa` repetidos | 0 | 0 |
| `id_veiculo` nulos | 169.754 | 169.754 |
| Sinistros distintos | 402.695 | 402.695 |
| `cod_ibge` com mais de um município | 0 | 0 |
