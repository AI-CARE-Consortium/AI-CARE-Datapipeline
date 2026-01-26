declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $Folgeereignis at $id in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor/Menge_Folgeereignis/Folgeereignis
    (:let $cTNM := $Tumor/Primaerdiagnose/cTNM:)
    return <record>
      <Folgeereignis_ID>{$id}</Folgeereignis_ID>
      <Register_ID_FK>{$Folgeereignis/../../../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$Folgeereignis/../../../../@Patient_ID/data()}</Patient_ID_FK>
      <Tumor_ID_FK>{$Folgeereignis/../../@Tumor_ID/data()}</Tumor_ID_FK>

      <Datum_Folgeereignis>{$Folgeereignis/Datum_Folgeereignis/data()}</Datum_Folgeereignis>
      <Folgeereignis_TNM_Version>{$Folgeereignis/TNM/Version/data()}</Folgeereignis_TNM_Version>
      <Folgeereignis_y_Symbol>{$Folgeereignis/TNM/y_Symbol/data()}</Folgeereignis_y_Symbol>
      <Folgeereignis_r_Symbol>{$Folgeereignis/TNM/r_Symbol/data()}</Folgeereignis_r_Symbol>
      <Folgeereignis_a_Symbol>{$Folgeereignis/TNM/a_Symbol/data()}</Folgeereignis_a_Symbol>
      <Folgeereignis_praefix_T>{$Folgeereignis/TNM/c_p_u_Praefix_T/data()}</Folgeereignis_praefix_T>
      <Folgeereignis_TNM_T>{$Folgeereignis/TNM/T/data()}</Folgeereignis_TNM_T>
      <Folgeereignis_praefix_N>{$Folgeereignis/TNM/c_p_u_Praefix_N/data()}</Folgeereignis_praefix_N>
      <Folgeereignis_TNM_N>{$Folgeereignis/TNM/N/data()}</Folgeereignis_TNM_N>
      <Folgeereignis_praefix_M>{$Folgeereignis/TNMc_p_u_Praefix_M/data()}</Folgeereignis_praefix_M>
      <Folgeereignis_TNM_M>{$Folgeereignis/TNM/M/data()}</Folgeereignis_TNM_M>
      <Folgeereignis_m_Symbol>{$Folgeereignis/TNM/m_symbol/data()}</Folgeereignis_m_Symbol>
      <Folgeereignis_L_Kategorie>{$Folgeereignis/TNM/L/data()}</Folgeereignis_L_Kategorie>
      <Folgeereignis_V_Kategorie>{$Folgeereignis/TNM/V/data()}</Folgeereignis_V_Kategorie>
      <Folgeereignis_Pn_Kategorie>{$Folgeereignis/TNM/Pn/data()}</Folgeereignis_Pn_Kategorie>
      <Folgeereignis_S_Kategorie>{$Folgeereignis/TNM/S/data()}</Folgeereignis_S_Kategorie>
      <Folgeereignis_TNM_UICC>{$Folgeereignis/TNM/UICC_Stadium/data()}</Folgeereignis_TNM_UICC>
      <Folgeereignis_Menge_weitere_Klassifikationen_Name>{(
            normalize-space(
                  string-join($Folgeereignis/Menge_Weitere_Klassifikation/Weitere_Klassifikation/Name/data(),";")
                            ))}
      </Folgeereignis_Menge_weitere_Klassifikationen_Name>
      <Folgeereignis_Menge_weitere_Klassifikationen_Stadium>{(
            normalize-space(
                  string-join($Folgeereignis/Menge_Weitere_Klassifikation/Weitere_Klassifikation/Stadium/data(),";")
                            ))}
      </Folgeereignis_Menge_weitere_Klassifikationen_Stadium>
      <Gesamtbeurteilung_Tumorstatus>{$Folgeereignis/Gesamtbeurteilung_Tumorstatus/data()}</Gesamtbeurteilung_Tumorstatus>
      <Verlauf_Lokaler_Tumorstatus>{$Folgeereignis/Verlauf_Lokaler_Tumorstatus/data()}</Verlauf_Lokaler_Tumorstatus>
      <Verlauf_Tumorstatus_Lymphknoten>{$Folgeereignis/Verlauf_Tumorstatus_Lymphknoten/data()}</Verlauf_Tumorstatus_Lymphknoten>
      <Verlauf_Tumorstatus_Fernmetastasen>{$Folgeereignis/Verlauf_Tumorstatus_Fernmetastasen/data()}</Verlauf_Tumorstatus_Fernmetastasen>
      
      <Menge_FM>{string-join($Folgeereignis/Menge_FM/Fernmetastase/Lokalisation/data(), ";")}</Menge_FM>
    
    </record>}
  </csv>)
let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)
return file:write-text($out, $csv)