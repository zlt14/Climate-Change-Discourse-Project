SELECT
    ct.climate_term,
    SUM(CASE WHEN strftime('%Y', d.date) = '1996' THEN 1 ELSE 0 END) AS freq_1996,
    SUM(CASE WHEN strftime('%Y', d.date) = '1997' THEN 1 ELSE 0 END) AS freq_1997,
    SUM(CASE WHEN strftime('%Y', d.date) = '1998' THEN 1 ELSE 0 END) AS freq_1998,
    SUM(CASE WHEN strftime('%Y', d.date) = '1999' THEN 1 ELSE 0 END) AS freq_1999,
   SUM(CASE WHEN strftime('%Y', d.date) = '2019' THEN 1 ELSE 0 END) AS freq_2019,
   SUM(CASE WHEN strftime('%Y', d.date) = '2020' THEN 1 ELSE 0 END) AS freq_2020,
    SUM(CASE WHEN strftime('%Y', d.date) = '2021' THEN 1 ELSE 0 END) AS freq_2021,
    SUM(CASE WHEN strftime('%Y', d.date) = '2022' THEN 1 ELSE 0 END) AS freq_2022
FROM
    quotes_climate_terms qct
JOIN
    climate_terms ct ON qct.climate_terms_id = ct.id
JOIN
    quotes q ON q.id = qct.quotes_id
JOIN
    debates d ON q.debates_id = d.id
GROUP BY
    ct.climate_term
ORDER BY
    freq_1998 + freq_1999 + freq_2021 + freq_2022 DESC
LIMIT 5;