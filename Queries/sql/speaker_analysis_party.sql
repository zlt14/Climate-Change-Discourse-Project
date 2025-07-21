SELECT
    s.party_affiliation,
    COUNT(DISTINCT qct.quotes_id) AS climate_quote_count
FROM
    quotes_climate_terms qct
JOIN
    quotes q ON q.id = qct.quotes_id
JOIN
    speaker s ON q.speaker_id = s.id
GROUP BY
    s.party_affiliation
ORDER BY
    climate_quote_count DESC;