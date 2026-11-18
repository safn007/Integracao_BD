-- FIN-01 · Três análises e insights
-- Consultas no Data Warehouse (fato_pessoa_sinistro + 8 dimensões).
-- Rodam iguais nos schemas public (ETL) e dw_elt (ELT): as duas estrelas são idênticas.
-- Letalidade = óbitos / pessoas envolvidas = SUM(flag_obito) / SUM(qtd_pessoas).
-- Cada bloco começa com "-- [nome]"; o notebook notebooks/analises.ipynb lê os blocos por nome.

-- [panorama_ano]
-- Sinistros, pessoas, óbitos e letalidade por ano do sinistro (com total).
SELECT t.ano,
       COUNT(DISTINCT f.id_sinistro)                               AS sinistros,
       SUM(f.qtd_pessoas)                                          AS pessoas,
       SUM(f.flag_obito)                                           AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)    AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
GROUP BY ROLLUP (t.ano)
ORDER BY t.ano NULLS LAST;

-- [a1_grupo]
-- Análise 1: quem morre. Pedestre vem de tipo_de_vitima; os demais, do veículo da vítima.
WITH base AS (
    SELECT CASE WHEN tr.tipo_de_vitima = 'PEDESTRE' THEN 'PEDESTRE' ELSE tr.tipo_veiculo_vitima END AS grupo,
           f.qtd_pessoas, f.flag_obito
    FROM fato_pessoa_sinistro f
    JOIN dim_transporte tr USING (sk_transporte)
)
SELECT grupo,
       SUM(qtd_pessoas)                                                      AS pessoas,
       SUM(flag_obito)                                                       AS obitos,
       ROUND(100.0 * SUM(flag_obito) / SUM(qtd_pessoas), 2)                  AS letalidade,
       ROUND(100.0 * SUM(qtd_pessoas) / SUM(SUM(qtd_pessoas)) OVER (), 1)    AS pct_pessoas,
       ROUND(100.0 * SUM(flag_obito) / SUM(SUM(flag_obito)) OVER (), 1)      AS pct_obitos
FROM base
GROUP BY grupo
ORDER BY obitos DESC;

-- [a1_moto_ano]
-- Óbitos de motociclistas (condutor ou passageiro) por ano.
SELECT t.ano, SUM(f.qtd_pessoas) AS pessoas, SUM(f.flag_obito) AS obitos
FROM fato_pessoa_sinistro f
JOIN dim_transporte tr USING (sk_transporte)
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
WHERE tr.tipo_veiculo_vitima = 'MOTOCICLETA' AND tr.tipo_de_vitima <> 'PEDESTRE'
GROUP BY t.ano
ORDER BY t.ano;

-- [a1_moto_perfil]
-- Perfil dos motociclistas mortos: sexo, idade e papel (condutor).
SELECT COUNT(*)                                                                         AS mortos,
       ROUND(100.0 * COUNT(*) FILTER (WHERE p.sexo = 'MASCULINO') / COUNT(*), 1)         AS pct_homens,
       ROUND(100.0 * COUNT(*) FILTER (WHERE tr.tipo_de_vitima = 'CONDUTOR') / COUNT(*), 1) AS pct_condutores,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f.idade)                             AS idade_mediana,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.idade BETWEEN 18 AND 24) / COUNT(f.idade), 1) AS pct_18_24,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.idade BETWEEN 18 AND 34) / COUNT(f.idade), 1) AS pct_18_34
FROM fato_pessoa_sinistro f
JOIN dim_transporte tr USING (sk_transporte)
JOIN dim_perfil_vitima p USING (sk_perfil_vitima)
WHERE tr.tipo_veiculo_vitima = 'MOTOCICLETA' AND tr.tipo_de_vitima <> 'PEDESTRE' AND f.flag_obito = 1;

-- [a1_sexo]
-- Pessoas, óbitos e letalidade por sexo.
SELECT p.sexo,
       SUM(f.qtd_pessoas)                                                AS pessoas,
       SUM(f.flag_obito)                                                 AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)          AS letalidade,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(SUM(f.flag_obito)) OVER (), 1) AS pct_obitos
FROM fato_pessoa_sinistro f
JOIN dim_perfil_vitima p USING (sk_perfil_vitima)
GROUP BY p.sexo
ORDER BY pessoas DESC;

-- [a1_pedestre_idade]
-- Letalidade do pedestre por faixa de idade (idade da fato).
SELECT CASE WHEN f.idade IS NULL THEN 'não informada'
            WHEN f.idade < 18 THEN '0-17'
            WHEN f.idade < 30 THEN '18-29'
            WHEN f.idade < 45 THEN '30-44'
            WHEN f.idade < 60 THEN '45-59'
            WHEN f.idade < 80 THEN '60-79'
            ELSE '80+' END                                    AS faixa,
       SUM(f.qtd_pessoas)                                     AS pessoas,
       SUM(f.flag_obito)                                      AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2) AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_transporte tr USING (sk_transporte)
WHERE tr.tipo_de_vitima = 'PEDESTRE'
GROUP BY 1
ORDER BY 1;

-- [a1_idosos_pedestres]
-- Entre os mortos com 60 anos ou mais, quantos eram pedestres.
SELECT SUM(f.flag_obito)                                                                         AS mortos_60_mais,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE tr.tipo_de_vitima = 'PEDESTRE') / SUM(f.flag_obito), 1) AS pct_pedestres
FROM fato_pessoa_sinistro f
JOIN dim_transporte tr USING (sk_transporte)
WHERE f.idade >= 60;

-- [a2_tipo_via]
-- Análise 2: onde se morre. Participação e letalidade por tipo de via.
SELECT v.tipo_via,
       SUM(f.qtd_pessoas)                                                    AS pessoas,
       SUM(f.flag_obito)                                                     AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)              AS letalidade,
       ROUND(100.0 * SUM(f.qtd_pessoas) / SUM(SUM(f.qtd_pessoas)) OVER (), 1) AS pct_pessoas,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(SUM(f.flag_obito)) OVER (), 1)   AS pct_obitos
FROM fato_pessoa_sinistro f
JOIN dim_via v USING (sk_via)
GROUP BY v.tipo_via
ORDER BY pessoas DESC;

-- [a2_cenarios]
-- Letalidade em via urbana e em rodovia: todos, motociclistas e pedestres.
SELECT CASE WHEN tr.tipo_de_vitima = 'PEDESTRE' THEN 'Pedestres'
            WHEN tr.tipo_veiculo_vitima = 'MOTOCICLETA' THEN 'Motociclistas'
            ELSE 'Demais' END                                                      AS grupo,
       v.tipo_via,
       SUM(f.qtd_pessoas)                                                          AS pessoas,
       SUM(f.flag_obito)                                                           AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)                    AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_via v USING (sk_via)
JOIN dim_transporte tr USING (sk_transporte)
WHERE v.tipo_via <> 'NÃO INFORMADO'
GROUP BY 1, 2
UNION ALL
SELECT 'Todos', v.tipo_via, SUM(f.qtd_pessoas), SUM(f.flag_obito),
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)
FROM fato_pessoa_sinistro f
JOIN dim_via v USING (sk_via)
WHERE v.tipo_via <> 'NÃO INFORMADO'
GROUP BY v.tipo_via
ORDER BY 1, 2;

-- [a2_local_obito]
-- Onde a vítima morreu (na via ou no hospital), por tipo de via.
SELECT v.tipo_via, lo.local_obito,
       SUM(f.flag_obito)                                                                     AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(SUM(f.flag_obito)) OVER (PARTITION BY v.tipo_via), 1) AS pct
FROM fato_pessoa_sinistro f
JOIN dim_via v USING (sk_via)
JOIN dim_local_obito lo USING (sk_local_obito)
WHERE f.flag_obito = 1 AND v.tipo_via <> 'NÃO INFORMADO'
GROUP BY 1, 2
ORDER BY 1, obitos DESC;

-- [a2_dias_ate_obito]
-- Tempo entre o sinistro e o óbito.
SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE dias_ate_obito = 0) / COUNT(*), 1)  AS mesmo_dia,
       ROUND(100.0 * COUNT(*) FILTER (WHERE dias_ate_obito <= 1) / COUNT(*), 1) AS ate_1_dia,
       ROUND(100.0 * COUNT(*) FILTER (WHERE dias_ate_obito <= 7) / COUNT(*), 1) AS ate_7_dias
FROM fato_pessoa_sinistro
WHERE flag_obito = 1;

-- [a2_regiao]
-- Letalidade por região e peso da rodovia em cada uma.
SELECT l.regiao_administrativa,
       SUM(f.qtd_pessoas)                                                                       AS pessoas,
       SUM(f.flag_obito)                                                                        AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)                                 AS letalidade,
       ROUND(100.0 * SUM(f.qtd_pessoas) FILTER (WHERE v.tipo_via = 'ESTRADAS E RODOVIAS') / SUM(f.qtd_pessoas), 1) AS pct_pessoas_rodovia,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE v.tipo_via = 'ESTRADAS E RODOVIAS') / SUM(f.flag_obito), 1)   AS pct_obitos_rodovia
FROM fato_pessoa_sinistro f
JOIN dim_localidade l USING (sk_localidade)
JOIN dim_via v USING (sk_via)
GROUP BY l.regiao_administrativa
ORDER BY letalidade DESC;

-- [a2_capital]
-- Capital (município de São Paulo) × resto do estado.
SELECT CASE WHEN l.municipio = 'SAO PAULO' THEN 'CAPITAL' ELSE 'DEMAIS MUNICÍPIOS' END AS local,
       SUM(f.qtd_pessoas) AS pessoas, SUM(f.flag_obito) AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2) AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_localidade l USING (sk_localidade)
GROUP BY 1;

-- [a3_dia_semana]
-- Análise 3: quando se morre. Letalidade por dia da semana do sinistro.
SELECT t.dia_semana, t.nome_dia_semana,
       SUM(f.qtd_pessoas)                                     AS pessoas,
       SUM(f.flag_obito)                                      AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2) AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
GROUP BY t.dia_semana, t.nome_dia_semana
ORDER BY t.dia_semana;

-- [a3_tipo_dia]
-- Dia útil × fim de semana × feriado nacional (feriado vale mais que fim de semana).
SELECT CASE WHEN t.feriado THEN 'FERIADO' WHEN t.fim_de_semana THEN 'FIM DE SEMANA' ELSE 'DIA ÚTIL' END AS tipo_dia,
       COUNT(DISTINCT t.sk_tempo)                                           AS dias,
       SUM(f.qtd_pessoas)                                                   AS pessoas,
       SUM(f.flag_obito)                                                    AS obitos,
       ROUND(1.0 * SUM(f.qtd_pessoas) / COUNT(DISTINCT t.sk_tempo), 0)      AS pessoas_por_dia,
       ROUND(1.0 * SUM(f.flag_obito) / COUNT(DISTINCT t.sk_tempo), 1)       AS obitos_por_dia,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2)             AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
GROUP BY 1
ORDER BY 1;

-- [a3_feriados]
-- Letalidade em cada feriado nacional (3 ocorrências de cada, 2021 a 2023).
SELECT t.nome_feriado,
       SUM(f.qtd_pessoas) AS pessoas, SUM(f.flag_obito) AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2) AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
WHERE t.feriado
GROUP BY t.nome_feriado
ORDER BY letalidade DESC;

-- [a3_fim_de_semana_grupos]
-- Letalidade de segunda a sexta × fim de semana, para motociclistas, pedestres e rodovias.
SELECT CASE WHEN t.fim_de_semana THEN 'FIM DE SEMANA' ELSE 'SEGUNDA A SEXTA' END AS periodo,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE tr.tipo_veiculo_vitima = 'MOTOCICLETA' AND tr.tipo_de_vitima <> 'PEDESTRE')
                   / SUM(f.qtd_pessoas) FILTER (WHERE tr.tipo_veiculo_vitima = 'MOTOCICLETA' AND tr.tipo_de_vitima <> 'PEDESTRE'), 2) AS letalidade_moto,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE tr.tipo_de_vitima = 'PEDESTRE')
                   / SUM(f.qtd_pessoas) FILTER (WHERE tr.tipo_de_vitima = 'PEDESTRE'), 2)                                         AS letalidade_pedestre,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE v.tipo_via = 'ESTRADAS E RODOVIAS')
                   / SUM(f.qtd_pessoas) FILTER (WHERE v.tipo_via = 'ESTRADAS E RODOVIAS'), 2)                                     AS letalidade_rodovia,
       ROUND(100.0 * SUM(f.flag_obito) FILTER (WHERE v.tipo_via = 'VIAS URBANAS')
                   / SUM(f.qtd_pessoas) FILTER (WHERE v.tipo_via = 'VIAS URBANAS'), 2)                                            AS letalidade_urbana
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
JOIN dim_transporte tr USING (sk_transporte)
JOIN dim_via v USING (sk_via)
GROUP BY 1
ORDER BY 1 DESC;

-- [a3_mes]
-- Óbitos e letalidade por mês (2021 a 2023 somados).
SELECT t.mes, t.nome_mes,
       SUM(f.qtd_pessoas) AS pessoas, SUM(f.flag_obito) AS obitos,
       ROUND(100.0 * SUM(f.flag_obito) / SUM(f.qtd_pessoas), 2) AS letalidade
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON t.sk_tempo = f.sk_data_sinistro
GROUP BY t.mes, t.nome_mes
ORDER BY t.mes;

-- [qualidade_preenchimento]
-- Insight transversal: % de campos não informados entre mortos e sobreviventes.
SELECT CASE WHEN f.flag_obito = 1 THEN 'MORTOS' ELSE 'SOBREVIVENTES' END                    AS grupo,
       ROUND(100.0 * COUNT(*) FILTER (WHERE p.grau_de_instrucao = 'NÃO INFORMADO') / COUNT(*), 1) AS escolaridade,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.sk_profissao = -1) / COUNT(*), 1)                AS profissao,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.idade IS NULL) / COUNT(*), 1)                    AS idade,
       ROUND(100.0 * COUNT(*) FILTER (WHERE v.tipo_via = 'NÃO INFORMADO') / COUNT(*), 1)       AS tipo_via,
       ROUND(100.0 * COUNT(*) FILTER (WHERE f.sk_gravidade = -1) / COUNT(*), 1)                AS gravidade
FROM fato_pessoa_sinistro f
JOIN dim_perfil_vitima p USING (sk_perfil_vitima)
JOIN dim_via v USING (sk_via)
GROUP BY 1
ORDER BY 1;
