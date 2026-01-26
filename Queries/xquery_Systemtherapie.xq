declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $SYST at $id in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Menge_SYST/SYST
    (:let $cTNM := $Tumor/Primaerdiagnose/cTNM:)
    return <record>
      <SYST_ID>{$id}</SYST_ID>
      <Register_ID_FK>{$SYST/../../../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$SYST/../../../../@Patient_ID/data()}</Patient_ID_FK>
      <Tumor_ID_FK>{$SYST/../../@Tumor_ID/data()}</Tumor_ID_FK>
      <Intention_sy>{$SYST/Intention/data()}</Intention_sy>
      <Stellung_OP>{$SYST/Stellung_OP/data()}</Stellung_OP>
      <Beginn_SYST>{$SYST/Datum_Beginn_SYST/data()}</Beginn_SYST>
      <Anzahl_Tage_Diagnose_SYST>{$SYST/Anzahl_Tage_Diagnose_SYST/data()}</Anzahl_Tage_Diagnose_SYST>
      <Anzahl_Tage_SYST>{$SYST/Anzahl_Tage_SYST_Dauer/data()}</Anzahl_Tage_SYST>
      <Therapieart>{$SYST/Therapieart/data()}</Therapieart>
      <Substanzen>{normalize-space(string-join($SYST/Menge_Substanz/Substanz/*/data(), ";"))}</Substanzen>
      <Protokolle>{normalize-space(string-join($SYST/Protokoll/*/data(), ";"))}</Protokolle>
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)