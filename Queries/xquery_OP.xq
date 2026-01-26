declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $OP at $id in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Menge_OP/OP
    (:let $cTNM := $Tumor/Primaerdiagnose/cTNM:)
    return <record>
      <OP_ID>{$id}</OP_ID>
      <Register_ID_FK>{$OP/../../../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$OP/../../../../@Patient_ID/data()}</Patient_ID_FK>
      <Tumor_ID_FK>{$OP/../../@Tumor_ID/data()}</Tumor_ID_FK>
      <Intention>{$OP/Intention/data()}</Intention>
      <Datum_OP>{$OP/Datum_OP/data()}</Datum_OP>
      <Anzahl_Tage_Diagnose_OP>{$OP/Anzahl_Tage_Diagnose_OP/data()}</Anzahl_Tage_Diagnose_OP>
      <Beurteilung_Residualstatus>{$OP/Lokale_Beurteilung_Residualstatus/data()}</Beurteilung_Residualstatus>
      <Menge_OPS_code>{string-join($OP/Menge_OPS/OPS/Code/data(), ";")}</Menge_OPS_code>
      <Menge_OPS_version>{string-join($OP/Menge_OPS/OPS/Version/data(), ";")}</Menge_OPS_version>
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)