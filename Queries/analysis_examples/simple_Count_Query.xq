declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
let $cTNM := doc("Data/oBDS_v3.0.0.8_RKI_Sample.xml")/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Primaerdiagnose/cTNM
let $cT := $cTNM/T/data()

for $value in distinct-values($cT)
  let $count := count($cTNM[T eq $value])
  order by $count descending
  return concat($value,",",$count)
    
    
    
(: string-join(distinct-values(doc("Data/oBDS_v3.0.0.8_RKI_Sample.xml")/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Primaerdiagnose/cTNM/T/data()),",")
return $cTNM:)