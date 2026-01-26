declare namespace xsd = "http://www.w3.org/2001/XMLSchema";
declare namespace xsi = "http://www.w3.org/2001/XMLSchema-instance";
declare default element namespace "http://www.basisdatensatz.de/oBDS/XML";
declare variable $in external;
declare variable $out external;

let $record:= (
  <csv>
  {for $Tumor in doc($in)/oBDS_RKI/Menge_Patient/Patient/Menge_Tumor/Tumor
    let $cTNM := $Tumor/Primaerdiagnose/cTNM
    let $pTNM := $Tumor/Primaerdiagnose/pTNM
    return <record>
      <Tumor_ID>{$Tumor/@Tumor_ID/data()}</Tumor_ID>
      <Register_ID_FK>{$Tumor/../../../../Lieferregister/@Register_ID/data()}</Register_ID_FK>
      <Patient_ID_FK>{$Tumor/../../@Patient_ID/data()}</Patient_ID_FK>
      <Diagnosedatum>{$Tumor/Primaerdiagnose/Diagnosedatum/data()}</Diagnosedatum>
      <Inzidenzort>{$Tumor/Primaerdiagnose/Inzidenzort/data()}</Inzidenzort>
      <Diagnosesicherung>{$Tumor/Primaerdiagnose/Diagnosesicherung/data()}</Diagnosesicherung>
      <Primaertumor_ICD>{$Tumor/Primaerdiagnose/Primaertumor_ICD/Code/data()}</Primaertumor_ICD>
      <Primaertumor_ICD_Version>{$Tumor/Primaerdiagnose/Primaertumor_ICD/Version/data()}</Primaertumor_ICD_Version>
      <Primaertumor_Topographie_ICD_O>{$Tumor/Primaerdiagnose/Primaertumor_Topographie_ICD_O/Code/data()}</Primaertumor_Topographie_ICD_O>
      <Primaertumor_Topographie_ICD_O_Version>{$Tumor/Primaerdiagnose/Primaertumor_Topographie_ICD_O/Version/data()}</Primaertumor_Topographie_ICD_O_Version>
      <Primaertumor_Morphologie_ICD_O>{$Tumor/Primaerdiagnose/Histologie/Morphologie_ICD_O/Code/data()}</Primaertumor_Morphologie_ICD_O>
      <Primaertumor_Morphologie_ICD_O_Version>{$Tumor/Primaerdiagnose/Histologie/Morphologie_ICD_O/Version/data()}</Primaertumor_Morphologie_ICD_O_Version>
      <Primaertumor_LK_untersucht>{$Tumor/Primaerdiagnose/Histologie/LK_untersucht/data()}</Primaertumor_LK_untersucht>
      <Primaertumor_LK_befallen>{$Tumor/Primaerdiagnose/Histologie/LK_befallen/data()}</Primaertumor_LK_befallen>
      <Primaertumor_Grading>{$Tumor/Primaerdiagnose/Histologie/Grading/data()}</Primaertumor_Grading>
      <cTNM_Version>{$cTNM/Version/data()}</cTNM_Version>
      <cTNM_y>{$cTNM/y_Symbol/data()}</cTNM_y>
      <cTNM_r>{$cTNM/r_Symbol/data()}</cTNM_r>
      <cTNM_a>{$cTNM/a_Symbol/data()}</cTNM_a>
      <cTNM_praefix_T>{$cTNM/c_p_u_Praefix_T/data()}</cTNM_praefix_T>
      <cTNM_T>{$cTNM/T/data()}</cTNM_T>
      <cTNM_praefix_N>{$cTNM/c_p_u_Praefix_N/data()}</cTNM_praefix_N>
      <cTNM_N>{$cTNM/N/data()}</cTNM_N>
      <cTNM_praefix_M>{$cTNM/c_p_u_Praefix_M/data()}</cTNM_praefix_M>
      <cTNM_M>{$cTNM/M/data()}</cTNM_M>
      <c_m_Symbol>{$cTNM/m_Symbol/data()}</c_m_Symbol>
      <c_L-Kategorie>{$cTNM/L/data()}</c_L-Kategorie>
      <c_V-Kategorie>{$cTNM/V/data()}</c_V-Kategorie>
      <c_Pn-Kategorie>{$cTNM/Pn/data()}</c_Pn-Kategorie>
      <c_S-Kategorie>{$cTNM/S/data()}</c_S-Kategorie>
      <cTNM_UICC_Stadium>{$cTNM/UICC_Stadium/data()}</cTNM_UICC_Stadium>
      <Seitenlokalisation>{$Tumor/Primaerdiagnose/Seitenlokalisation/data()} </Seitenlokalisation>
      <pTNM_Version>{$pTNM/Version/data()}</pTNM_Version>
      <pTNM_y>{$pTNM/y_Symbol/data()}</pTNM_y>
      <pTNM_r>{$pTNM/r_Symbol/data()}</pTNM_r>
      <pTNM_a>{$pTNM/a_Symbol/data()}</pTNM_a>
      <pTNM_praefix_T>{$pTNM/c_p_u_Praefix_T/data()}</pTNM_praefix_T>
      <pTNM_T>{$pTNM/T/data()}</pTNM_T>
      <pTNM_praefix_N>{$pTNM/c_p_u_Praefix_N/data()}</pTNM_praefix_N>
      <pTNM_N>{$pTNM/N/data()}</pTNM_N>
      <pTNM_praefix_M>{$pTNM/c_p_u_Praefix_M/data()}</pTNM_praefix_M>
      <pTNM_M>{$pTNM/M/data()}</pTNM_M>
      <p_m_Symbol>{$pTNM/m_Symbol/data()}</p_m_Symbol>
      <p_L-Kategorie>{$pTNM/L/data()}</p_L-Kategorie>
      <p_V-Kategorie>{$pTNM/V/data()}</p_V-Kategorie>
      <p_Pn-Kategorie>{$pTNM/Pn/data()}</p_Pn-Kategorie>
      <p_S-Kategorie>{$pTNM/S/data()}</p_S-Kategorie>
      <pTNM_UICC_Stadium>{$pTNM/UICC_Stadium/data()}</pTNM_UICC_Stadium>

      <Primaertumor_DCN>{$Tumor/Primaerdiagnose/DCN/data()}</Primaertumor_DCN>
      
      <Anzahl_Tage_Diagnose_Tod>{$Tumor/Primaerdiagnose/Anzahl_Tage_Diagnose_Tod/data()}</Anzahl_Tage_Diagnose_Tod>
      <Anzahl_Monate_Diagnose_Zensierung>{""}</Anzahl_Monate_Diagnose_Zensierung>
      <Anzahl_Monate_Diagnose_Zensierung>{$Tumor/Primaerdiagnose/Anzahl_Monate_Diagnose_Zensierung/data()}</Anzahl_Monate_Diagnose_Zensierung>
      <Primaerdiagnose_Menge_FM>{string-join($Tumor/Primaerdiagnose/Menge_FM/Fernmetastase/Lokalisation/data(), ";")}</Primaerdiagnose_Menge_FM>
      <Weitere_Klassifikation_UICC>{""}</Weitere_Klassifikation_UICC>
        
      {
        for $Klassifikation in $Tumor/Primaerdiagnose/Menge_Weitere_Klassifikation/Weitere_Klassifikation
        return if($Klassifikation/Name="UICC") then(
          <Weitere_Klassifikation_UICC>
          {string-join($Klassifikation/Stadium/data(),";")}
          </Weitere_Klassifikation_UICC>
        )else ()
      } 
          
      <Weitere_Klassifikation_Name>
      {string-join($Tumor/Primaerdiagnose/Menge_Weitere_Klassifikation/Weitere_Klassifikation/Name/data(),";")}
      </Weitere_Klassifikation_Name>,
      <Weitere_Klassifikation_Stadium>
      {string-join($Tumor/Primaerdiagnose/Menge_Weitere_Klassifikation/Weitere_Klassifikation/Stadium/data(),";")}
      </Weitere_Klassifikation_Stadium>

        
      
    </record>}
  </csv>)

let $options := map {'header':true()}
let $csv := csv:serialize($record, $options)

return file:write-text($out, $csv)