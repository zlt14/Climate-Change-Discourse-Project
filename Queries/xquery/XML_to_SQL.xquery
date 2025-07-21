xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $persons := doc('../input/ParlaMint-AT-listPerson.xml')
let $climate-terms-doc := doc('../input/climate_terms.xml')
let $terms := $climate-terms-doc//term

let $all-results :=
for $doc in collection('../input?select=ParlaMint-AT_*.xml;recurse=no')//tei:TEI
let $file-name := tokenize(base-uri($doc), '/')[last()]
let $matches := analyze-string($file-name, '^ParlaMint-AT_(\d{4})-(\d{2})-(\d{2}).*-([0-9]{5})\.xml$')//fn:match
let $date := string-join(($matches/fn:group[@nr = "1"], $matches/fn:group[@nr = "2"], $matches/fn:group[@nr = "3"]), "")
let $number := $matches/fn:group[@nr = "4"]
let $debate-id := xs:integer(concat($date, $number))
let $debate-date := $doc//tei:sourceDesc//tei:bibl//tei:date/@when/string()
let $sitzung := $doc//tei:meeting[@ana = '#parla.lower #parla.sitting'][1]/@n/string()
let $periode := $doc//tei:meeting[contains(@ana, '#parla.term') and @xml:lang = 'de'][1]/@n/string()

let $debate-insert := concat("INSERT OR IGNORE INTO debates (id, date, sitting_number, legislative_period) VALUES (", $debate-id, ", '", $debate-date, "', '", $sitzung, "', '", $periode, "');")

let $quote-inserts :=
  for $seg at $i in $doc//tei:seg
  let $text := normalize-space(string-join(
    $seg//text()[
      not(ancestor::tei:vocal) and
      not(ancestor::tei:kinesic) and
      not(ancestor::tei:note)
    ], ' '))
  where some $term in $terms satisfies contains(lower-case($text), lower-case(string($term)))

  let $u := $seg/ancestor::tei:u[1]
  let $speaker-id := substring-after($u/@who, '#')
  let $person := $persons//tei:person[@xml:id = $speaker-id]
  let $first := replace(string-join($person/tei:persName/tei:forename, " "), "'", "''")
  let $last := replace(string-join($person/tei:persName/tei:surname, " "), "'", "''")
  let $party := substring-after($person/tei:affiliation[contains(@ref,'#parliamentaryGroup.')][1]/@ref, '#parliamentaryGroup.')
  let $sex := replace($person/tei:sex/@value/string(), "'", "''")
  let $quote := replace($text, "'", "''")
  let $quote-id := $debate-id * 100000 + $i

  return (
    concat("INSERT OR IGNORE INTO speaker (id, first_name, last_name, party_affiliation, sex) VALUES ('", $speaker-id, "', '", $first, "', '", $last, "', '", $party, "', '", $sex, "');"),
    concat("INSERT INTO quotes (id, quote, debates_id, speaker_id) VALUES (", $quote-id, ", '", $quote, "', ", $debate-id, ", '", $speaker-id, "');"),

    for $term at $term-id in $terms
    where contains(lower-case($text), lower-case(string($term)))
    return concat("INSERT INTO quotes_climate_terms (quotes_id, climate_terms_id) VALUES (", $quote-id, ", ", $term-id, ");")
  )

return
    (
    $debate-insert,
    distinct-values($quote-inserts)
    )

return
    string-join(distinct-values($all-results), "&#10;")
