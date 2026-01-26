declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in  external;
declare variable $out  external;

let $record:= (
  <csv>
  {for $Patient in doc($in)/oBDS_RKI/Menge_Patient/Patient
    return <record>
      <Patient_ID>{$Patient/@Patient_ID/data()}</Patient_ID>
      <Register_ID_FK>{$Patient/../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Geschlecht>{$Patient/Patienten_Stammdaten/Geschlecht/data()}</Geschlecht>
      <Geburtsdatum>{$Patient/Patienten_Stammdaten/Geburtsdatum/data()}</Geburtsdatum>
      <Verstorben>{$Patient/Patienten_Stammdaten/Vitalstatus/Verstorben/data()}</Verstorben>
      <Datum_Vitalstatus>{$Patient/Patienten_Stammdaten/Vitalstatus/Datum_Vitalstatus/data()}</Datum_Vitalstatus>
      <Todesursache_Grundleiden>{$Patient/Patienten_Stammdaten/Vitalstatus/Todesursachen/Grundleiden/Code/data()}</Todesursache_Grundleiden>
      <Todesursache_Grundleiden_Version>{$Patient/Patienten_Stammdaten/Vitalstatus/Todesursachen/Grundleiden/Version/data()}</Todesursache_Grundleiden_Version>
      <Weitere_Todesursachen>{string-join($Patient/Patienten_Stammdaten/Vitalstatus/Todesursachen/Menge_Weitere_Todesursachen/Todesursache_ICD/Code/data(),";")}</Weitere_Todesursachen>
      <Weitere_Todesursachen_Version>{string-join($Patient/Patienten_Stammdaten/Vitalstatus/Todesursachen/Menge_Weitere_Todesursachen/Todesursache_ICD/Version/data(),";")}</Weitere_Todesursachen_Version>
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)