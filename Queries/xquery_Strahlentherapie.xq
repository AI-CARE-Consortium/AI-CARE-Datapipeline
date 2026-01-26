declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $Bestrahlung at $id in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Menge_ST/ST/Menge_Bestrahlung/Bestrahlung
    (:let $cTNM := $Tumor/Primaerdiagnose/cTNM:)
    return <record>
      <Bestrahlung_ID>{$id}</Bestrahlung_ID>
      <Register_ID_FK>{$Bestrahlung/../../../../../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$Bestrahlung/../../../../../../@Patient_ID/data()}</Patient_ID_FK>
      <Tumor_ID_FK>{$Bestrahlung/../../../../@Tumor_ID/data()}</Tumor_ID_FK>
      <Intention_st>{$Bestrahlung/../../Intention/data()}</Intention_st>
      <Stellung_OP>{$Bestrahlung/../../Stellung_OP/data()}</Stellung_OP>
      <Beginn_Bestrahlung>{$Bestrahlung/Datum_Beginn_Bestrahlung/data()}</Beginn_Bestrahlung>
      <Anzahl_Tage_Diagnose_ST>{$Bestrahlung/Anzahl_Tage_Diagnose_ST/data()}</Anzahl_Tage_Diagnose_ST>
      <Anzahl_Tage_ST>{$Bestrahlung/Anzahl_Tage_ST_Dauer/data()}</Anzahl_Tage_ST>
      <Applikationsart>{local-name($Bestrahlung/Applikationsart/*)}</Applikationsart>
      <Applikationsspezifikation>{string-join(($Bestrahlung/Applikationsart/*/Radiochemo/data(),
                                               $Bestrahlung/Applikationsart/*/Stereotaktisch/data(),
                                               $Bestrahlung/Applikationsart/*/Atemgetriggert/data(),
                                               $Bestrahlung/Applikationsart/*/Interstitiell_endokavitaer/data(),
                                               $Bestrahlung/Applikationsart/*/Rate_Type/data(),
                                               $Bestrahlung/Applikationsart/*/Metabolisch_Typ/data()),";")}
      </Applikationsspezifikation>
      <Zielgebiet_CodeVersion>{local-name($Bestrahlung/Applikationsart/*/Zielgebiet/*)}</Zielgebiet_CodeVersion>
      <Zielgebiet_Code>{$Bestrahlung/Applikationsart/*/Zielgebiet/*/data()}</Zielgebiet_Code>
      <Seite_Zielgebiet>{$Bestrahlung/Applikationsart/*/Seite_Zielgebiet/data()}</Seite_Zielgebiet>
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)