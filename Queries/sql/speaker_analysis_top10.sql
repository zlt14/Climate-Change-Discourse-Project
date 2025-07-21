/* Speaker Analysis: Top 20 speakers (incl. party affiliations) by frequency of climate terms in quotes */

SELECT
    s.first_name || ' ' || s.last_name AS speaker_name,
    s.party_affiliation,
    COUNT(DISTINCT qct.quotes_id) AS climate_quote_count
FROM
    quotes_climate_terms qct
JOIN
    quotes q ON q.id = qct.quotes_id
JOIN
    speaker s ON q.speaker_id = s.id
GROUP BY
    s.id
ORDER BY
    climate_quote_count DESC
LIMIT 10;