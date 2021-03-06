PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX IAO: <http://purl.obolibrary.org/obo/IAO_>
PREFIX UBPROP: <http://purl.obolibrary.org/obo/UBPROP_>

DELETE { ?s IAO:0000115 ?definition . }
INSERT { ?s UBPROP:0000001 ?definition . }
WHERE {
  ?s IAO:0000115 ?definition .
  FILTER (STRSTARTS(str(?s), "http://purl.obolibrary.org/obo/UBERON_"))
}