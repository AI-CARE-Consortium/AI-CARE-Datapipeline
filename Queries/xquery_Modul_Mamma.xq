declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $MM in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Primaerdiagnose/Modul_Mamma
    (:let $cTNM := $Tumor/Primaerdiagnose/cTNM:)
    where not(empty($MM/*))
    return <record>
      <Register_ID_FK>{$MM/../../../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$MM/../../../../@Patient_ID/data()}</Patient_ID_FK>
      <Tumor_ID_FK>{$MM/../../@Tumor_ID/data()}</Tumor_ID_FK>
      <Praetherapeutischer_Menopausenstatus>{$MM/Praetherapeutischer_Menopausenstatus/data()}</Praetherapeutischer_Menopausenstatus>
      <HormonrezeptorStatus_Oestrogen>{$MM/HormonrezeptorStatus_Oestrogen/data()}</HormonrezeptorStatus_Oestrogen>
      <HormonrezeptorStatus_Progesteron>{$MM/HormonrezeptorStatus_Progesteron/data()}</HormonrezeptorStatus_Progesteron>
      <Her2neuStatus>{$MM/Her2neuStatus/data()}</Her2neuStatus>
      <TumorgroesseInvasiv>{$MM/TumorgroesseInvasiv/data()}</TumorgroesseInvasiv>
      <TumorgroesseDCIS>{$MM/TumorgroesseDCIS/data()}</TumorgroesseDCIS>
      
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)