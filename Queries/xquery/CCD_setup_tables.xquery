xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $persons := doc('../input/ParlaMint-AT-listPerson.xml')
let $climateTermsDoc := doc('../input/climate_terms.xml')
let $terms := $climateTermsDoc//term

let $createTables := (
  "CREATE TABLE IF NOT EXISTS climate_terms (id INTEGER PRIMARY KEY, climate_term TEXT NOT NULL);",
  "CREATE TABLE IF NOT EXISTS debates (id INTEGER PRIMARY KEY, date TEXT NOT NULL, sitting_number TEXT, legislative_period TEXT);",
  "CREATE TABLE IF NOT EXISTS speaker (id TEXT PRIMARY KEY, first_name TEXT, last_name TEXT, party_affiliation TEXT, sex TEXT);",
  "CREATE TABLE IF NOT EXISTS quotes (id INTEGER PRIMARY KEY, quote TEXT NOT NULL, debates_id INTEGER NOT NULL, speaker_id TEXT NOT NULL, FOREIGN KEY (debates_id) REFERENCES debates(id), FOREIGN KEY (speaker_id) REFERENCES speaker(id));",
  "CREATE TABLE IF NOT EXISTS quotes_climate_terms (id INTEGER PRIMARY KEY, quotes_id INTEGER NOT NULL, climate_terms_id INTEGER NOT NULL, FOREIGN KEY (quotes_id) REFERENCES quotes(id), FOREIGN KEY (climate_terms_id) REFERENCES climate_terms(id));"
)

let $termInserts :=
  for $term in $terms
  return concat(
    "INSERT OR IGNORE INTO climate_terms (id, climate_term) VALUES (",
    $term/@id, ", '", normalize-space($term), "');"
  )

return string-join(($createTables, "", $termInserts), "&#10;")
