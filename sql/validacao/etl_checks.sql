-- Consultas de validação pós-carga (ETL-25)
-- Geradas pelo notebook notebooks/etl/10_validacao.ipynb

-- contagem_por_tabela
SELECT 'dim_tempo' AS tabela, COUNT(*) AS linhas FROM dim_tempo
UNION ALL SELECT 'dim_gravidade', COUNT(*) FROM dim_gravidade
UNION ALL SELECT 'dim_perfil_vitima', COUNT(*) FROM dim_perfil_vitima
UNION ALL SELECT 'dim_transporte', COUNT(*) FROM dim_transporte
UNION ALL SELECT 'dim_localidade', COUNT(*) FROM dim_localidade
UNION ALL SELECT 'dim_via', COUNT(*) FROM dim_via
UNION ALL SELECT 'dim_profissao', COUNT(*) FROM dim_profissao
UNION ALL SELECT 'dim_local_obito', COUNT(*) FROM dim_local_obito
UNION ALL SELECT 'fato_pessoa_sinistro', COUNT(*) FROM fato_pessoa_sinistro;

-- fk_sem_correspondencia
SELECT 'dim_tempo (data_sinistro)' AS chave, COUNT(*) AS orfaos
FROM fato_pessoa_sinistro f LEFT JOIN dim_tempo d ON f.sk_data_sinistro = d.sk_tempo
WHERE d.sk_tempo IS NULL
UNION ALL SELECT 'dim_tempo (data_obito)', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_tempo d ON f.sk_data_obito = d.sk_tempo
WHERE d.sk_tempo IS NULL
UNION ALL SELECT 'dim_gravidade', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_gravidade d ON f.sk_gravidade = d.sk_gravidade
WHERE d.sk_gravidade IS NULL
UNION ALL SELECT 'dim_perfil_vitima', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_perfil_vitima d ON f.sk_perfil_vitima = d.sk_perfil_vitima
WHERE d.sk_perfil_vitima IS NULL
UNION ALL SELECT 'dim_transporte', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_transporte d ON f.sk_transporte = d.sk_transporte
WHERE d.sk_transporte IS NULL
UNION ALL SELECT 'dim_localidade', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_localidade d ON f.sk_localidade = d.sk_localidade
WHERE d.sk_localidade IS NULL
UNION ALL SELECT 'dim_via', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_via d ON f.sk_via = d.sk_via
WHERE d.sk_via IS NULL
UNION ALL SELECT 'dim_profissao', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_profissao d ON f.sk_profissao = d.sk_profissao
WHERE d.sk_profissao IS NULL
UNION ALL SELECT 'dim_local_obito', COUNT(*)
FROM fato_pessoa_sinistro f LEFT JOIN dim_local_obito d ON f.sk_local_obito = d.sk_local_obito
WHERE d.sk_local_obito IS NULL;

-- total_obitos
SELECT SUM(flag_obito) AS obitos, COUNT(*) AS vitimas
FROM fato_pessoa_sinistro;

-- obitos_por_ano
SELECT t.ano, SUM(f.flag_obito) AS obitos, COUNT(*) AS vitimas
FROM fato_pessoa_sinistro f
JOIN dim_tempo t ON f.sk_data_sinistro = t.sk_tempo
GROUP BY t.ano
ORDER BY t.ano;

-- top10_municipios_obitos
SELECT l.municipio, SUM(f.flag_obito) AS obitos
FROM fato_pessoa_sinistro f
JOIN dim_localidade l ON f.sk_localidade = l.sk_localidade
GROUP BY l.municipio
ORDER BY obitos DESC
LIMIT 10;

-- vitimas_por_sexo_e_tipo
SELECT p.sexo, tr.tipo_de_vitima, COUNT(*) AS vitimas, SUM(f.flag_obito) AS obitos
FROM fato_pessoa_sinistro f
JOIN dim_perfil_vitima p ON f.sk_perfil_vitima = p.sk_perfil_vitima
JOIN dim_transporte tr ON f.sk_transporte = tr.sk_transporte
GROUP BY p.sexo, tr.tipo_de_vitima
ORDER BY vitimas DESC;
