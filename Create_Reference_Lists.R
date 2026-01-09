# Zuweisungstabelle ####
# Die folgenden Variablen werden in dieser Datenverarbeitungspipeline mit Referenzlisten abgeglichen. Alle anderen Variablen werden unverändert übernommen.
# Dafür wird in einem ersten Schritt jeder Variable eine Referenzliste zugeordnet und die Methode des Referenzlistenabgleichs definiert.
# The following variables are included in the Datapipeline and will be checked against reference data. All other variables will be kept unchanged.
# In the first step, covered in this script, all variables are associated with reference data and the method, used for the alignment to this reference data, is defined.

download_data <- function(mapping){
  if(!dir.exists("./Referenzdaten-Latest")){
    dir.create("./Referenzdaten-Latest")
  }
  reference_data_list <- list()
  
  for(i in seq_len(length(mapping$local_names))){
    localname <- mapping$local_names[i]
    rki_name <- mapping$rki_names[i]
    
    print(localname)
    if(rki_name != ""){
      if (RCurl::url.exists("https://gitlab.opencode.de/robert-koch-institut/zentrum-fuer-krebsregisterdaten/cancerdata-references/")){
        download.file(paste0("https://gitlab.opencode.de/robert-koch-institut/zentrum-fuer-krebsregisterdaten/cancerdata-references/-/raw/main/data/v2/Klassifikationen/",
                           rki_name,".csv"), destfile = paste0("./Referenzdaten-Latest/",localname,".csv"), method="curl")
        temp_reference <- read.csv2(paste0("./Referenzdaten-Latest/",localname, ".csv"),blank.lines.skip = FALSE, encoding="UTF-8")
        write.csv(temp_reference, paste0("./Referenzdaten-Latest/",localname, ".csv"), fileEncoding="UTF-8", row.names=FALSE)
      } else {
        file.copy(paste0("./Referenzdaten/",localname,".csv"),paste0("./Referenzdaten-Latest/",localname,".csv"), overwrite = TRUE)
      }
    }
    else{
      file.copy(paste0("./Referenzdaten/",localname,".csv"),paste0("./Referenzdaten-Latest/",localname,".csv"), overwrite = TRUE)
      
      
    }
    reference_data_list[[localname]] <- read.csv(paste0("./Referenzdaten-Latest/",localname, ".csv"),blank.lines.skip = FALSE, encoding="UTF-8")

    if (localname == "ops_codes_zfkd") {
      print("Extending OPS Codes...")

      # Get the number of rows in the original OPS code list
      ops_data <- reference_data_list$ops_codes_zfkd
      n <- nrow(ops_data)

      # Preallocate vectors for extended codes and names
      extended_length <- 4 * n
      code <- rep(NA, extended_length)
      name <- rep(NA, extended_length)

      # Add an empty placeholder at the beginning
      code[1] <- ""
      name[1] <- ""

      # Start filling from the second position
      index <- 2

      for (i in 2:n) {
        base_code <- ops_data[i, 1]
        base_name <- ops_data[i, 2]

        # Original code
        code[index]     <- base_code
        name[index]     <- base_name

        # Extended codes with suffixes
        code[index + 1] <- paste0(base_code, "R")
        code[index + 2] <- paste0(base_code, "L")
        code[index + 3] <- paste0(base_code, "B")

        # All variants share the same name
        name[(index + 1):(index + 3)] <- base_name

        # Move to the next block
        index <- index + 4
      }

      # Create the final data frame
      reference_data_list$ops_codes_zfkd <- data.frame(code = code, name = name)
    }

  }
  
  
  return(reference_data_list)
}
local_rki_mapping <- list()
local_rki_mapping$local_names <- c("geschlecht","menge_fm","tnm8_t_krsh","tnm8_n_krsh","tnm8_m_krsh", "tnm7_t_krhb","tnm7_n_krhb","tnm7_m_krhb", "tnm_t_gesamt","tnm_n_gesamt","tnm_m_gesamt",
                                   "tnm_L","tnm_V","tnm_Pn","tnm_S","tnm_y","tnm_r","tnm_a","tnm_m_symbol","tumorverlauf_gesamt","tumorverlauf_pt","tumorverlauf_lk","tumorverlauf_fm",
                                   "tage","seite","janein","grading","stadium","lk_anzahl","tumorgroesse",
                                   "icd_10codes_tod_zfkd","tnm_praefix","morphologie_zfkd","topographie_zfkd","icd_10codes_zfkd","residualstatus","ops_codes_zfkd","diagnosesicherung","datumsangabe",
                                   "therapieart","applikationsart","applikationsspezifizierung","zielgebiete","zielgebiete_version","intention_op","intention_st","intention_sy","stellung_op", 
                                   "landkreis","menopause","rezeptorstatus","icd10_version","icdo3_version","tnm_version","ops_version")
local_rki_mapping$rki_names <-c("geschlecht", "fm_lokalisation", "", "", "", "", "", "", "", "", "", "tnm_l", "tnm_v", "tnm_pn", "tnm_s", "", "", "", "",
                                "beurteilung_gesamt", "verlauf_lokal", "verlauf_lymphe", "verlauf_fern", "", "seitenlokalisation", "", "grading_clin", "tnm_uicc", "", "",
                                "icd10_todesursache", "tnm_cpu", "morphologie", "topographie", "icd10", "r_typ", "ops", "diagnosesicherung_clin", "",
                                "therapieart", "", "", "", "", "op_intention", "st_intention", "syst_intention", "st_op_stellung",
                                "", "menopausenstatus", "hormonrezeptor", "icd10_version", "morphologie_version", "tnm_auflage", "")
reference_data <- download_data(local_rki_mapping)


variablennamen <- c("Patient_ID","Geschlecht","Geburtsdatum","Verstorben","Datum_Vitalstatus","Todesursache_Grundleiden","Todesursache_Grundleiden_Version",
                    "Weitere_Todesursachen","Weitere_Todesursachen_Version","Tumor_ID","Patient_ID_FK","Diagnosedatum","Inzidenzort","Diagnosesicherung",
                    "Primaertumor_ICD","Primaertumor_ICD_Version","Primaertumor_Topographie_ICD_O","Primaertumor_Topographie_ICD_O_Version","Primaertumor_Morphologie_ICD_O",
                    "Primaertumor_Morphologie_ICD_O_Version","Primaertumor_LK_untersucht","Primaertumor_LK_befallen","Primaertumor_Grading","cTNM_Version","cTNM_y","cTNM_r",
                    "cTNM_a","cTNM_praefix_T","cTNM_T","cTNM_praefix_N","cTNM_N","cTNM_praefix_M","cTNM_M","c_m_Symbol","c_L.Kategorie","c_V.Kategorie","c_Pn.Kategorie",
                    "c_S.Kategorie","cTNM_UICC_Stadium","Seitenlokalisation","pTNM_Version","pTNM_y","pTNM_r","pTNM_a","pTNM_praefix_T","pTNM_T","pTNM_praefix_N","pTNM_N",
                    "pTNM_praefix_M","pTNM_M","p_m_Symbol","p_L.Kategorie","p_V.Kategorie","p_Pn.Kategorie","p_S.Kategorie","pTNM_UICC_Stadium","Primaertumor_DCN","Anzahl_Tage_Diagnose_Tod",
                    "Primaerdiagnose_Menge_FM","Tumor_ID_FK","Praetherapeutischer_Menopausenstatus","HormonrezeptorStatus_Oestrogen","HormonrezeptorStatus_Progesteron","Her2neuStatus","TumorgroesseInvasiv",
                    "TumorgroesseDCIS","Folgeereignis_ID","Datum_Folgeereignis","Folgeereignis_TNM_Version","Folgeereignis_y_Symbol","Folgeereignis_r_Symbol","Folgeereignis_a_Symbol","Folgeereignis_praefix_T",
                    "Folgeereignis_TNM_T","Folgeereignis_praefix_N","Folgeereignis_TNM_N","Folgeereignis_praefix_M","Folgeereignis_TNM_M","Folgeereignis_m_Symbol","Folgeereignis_L_Kategorie","Folgeereignis_V_Kategorie",
                    "Folgeereignis_Pn_Kategorie","Folgeereignis_S_Kategorie","Folgeereignis_TNM_UICC","Folgeereignis_Menge_weitere_Klassifikation_Name", "Folgeereignis_Menge_weitere_Klassifikation_Stadium", "Gesamtbeurteilung_Tumorstatus","Verlauf_Lokaler_Tumorstatus",
                    "Verlauf_Tumorstatus_Lymphknoten","Verlauf_Tumorstatus_Fernmetastasen","Menge_FM","OP_ID","Intention","Datum_OP","Anzahl_Tage_Diagnose_OP","Beurteilung_Residualstatus","Menge_OPS_code","Menge_OPS_version",
                    "Bestrahlung_ID","Stellung_OP","Beginn_Bestrahlung","Anzahl_Tage_Diagnose_ST","Anzahl_Tage_ST","Intention_st","Applikationsart","Applikationsspezifizierung","Zielgebiet_CodeVersion","Zielgebiet_Code",
                    "Seite_Zielgebiet","SYST_ID","Beginn_SYST","Anzahl_Tage_Diagnose_SYST","Intention_sy","Anzahl_Tage_SYST","Therapieart","Substanzen","Protokolle",
                    "cTNM_T7","pTNM_T7","Folgeereignis_TNM_T7", "cTNM_N7","pTNM_N7","Folgeereignis_TNM_N7", "cTNM_M7","pTNM_M7","Folgeereignis_TNM_M7", "cTNM_T8","pTNM_T8","Folgeereignis_TNM_T8", "cTNM_N8","pTNM_N8","Folgeereignis_TNM_N8",
                    "cTNM_M8","pTNM_M8","Folgeereignis_TNM_M8", "Anzahl_Monate_Diagnose_Zensierung")
#zuweisungstabelle <- readRDS("./zuweisungstabelle.RDS")
# Die Zuweisungstabelle enthält die Namen der betrachteten Variablen, der passenden Referenztabelle und der Methode, mit der die Daten gegen die Referenztabelle abgeglichen werden.
# Weiterhin enthält sie für einen späteren z.B. entitätsspezifischen Abgleich, das Feld Hilfsvariable, das auf die Variable hinweist, die den Umfang der Referenzliste definiert.
# The "Zuweisungstabelle" (assignment-table) contains a list of to be transformed variables, the names of the reference data and the method to be used for alignment of data against the reference.
zuweisungstabelle <- matrix(ncol = 4, nrow = length(variablennamen))
colnames(zuweisungstabelle) <- c("variable","referenztabelle","hilfsvariable","methode")
rownames(zuweisungstabelle) <- variablennamen
zuweisungstabelle[,1] <- variablennamen
zuweisungstabelle

# Zuweisung der Referenslisten
# Association of data to reference data.
zuweisungstabelle[c("cTNM_T","pTNM_T","Folgeereignis_TNM_T"),"referenztabelle"] <- "tnm_t_gesamt"
zuweisungstabelle[c("cTNM_N","pTNM_N","Folgeereignis_TNM_N"),"referenztabelle"] <- "tnm_n_gesamt"
zuweisungstabelle[c("cTNM_M","pTNM_M","Folgeereignis_TNM_M"),"referenztabelle"] <- "tnm_m_gesamt"
zuweisungstabelle[c("cTNM_T7","pTNM_T7","Folgeereignis_TNM_T7"),"referenztabelle"] <- "tnm7_t_krhb"
zuweisungstabelle[c("cTNM_N7","pTNM_N7","Folgeereignis_TNM_N7"),"referenztabelle"] <- "tnm7_n_krhb"
zuweisungstabelle[c("cTNM_M7","pTNM_M7","Folgeereignis_TNM_M7"),"referenztabelle"] <- "tnm7_m_krhb"
zuweisungstabelle[c("cTNM_T8","pTNM_T8","Folgeereignis_TNM_T8"),"referenztabelle"] <- "tnm8_t_krsh"
zuweisungstabelle[c("cTNM_N8","pTNM_N8","Folgeereignis_TNM_N8"),"referenztabelle"] <- "tnm8_n_krsh"
zuweisungstabelle[c("cTNM_M8","pTNM_M8","Folgeereignis_TNM_M8"),"referenztabelle"] <- "tnm8_m_krsh"
zuweisungstabelle[c("cTNM_T","pTNM_T","Folgeereignis_TNM_T",
                    "cTNM_N","pTNM_N","Folgeereignis_TNM_N",
                    "cTNM_M","pTNM_M","Folgeereignis_TNM_M",
                    "Primaertumor_Topographie_ICD_O","Primaertumor_Morphologie_ICD_O"),"hilfsvariable"] <- "Primaertumor_ICD"
zuweisungstabelle[c("c_m_Symbol","p_m_Symbol","Folgeereignis_m_Symbol"),"referenztabelle"] <- "tnm_m_symbol"
zuweisungstabelle["Geschlecht","referenztabelle"] <- "geschlecht"
zuweisungstabelle[c("Todesursache_Grundleiden","Weitere_Todesursachen"),"referenztabelle"] <- "icd_10codes_tod_zfkd" #"icd_10codes"
zuweisungstabelle["Primaertumor_ICD","referenztabelle"] <- "icd_10codes_zfkd"#"primaertumoricd10"
zuweisungstabelle[c("Primaertumor_Morphologie_ICD_O"),"referenztabelle"] <- "morphologie_zfkd" #"morphologie"
zuweisungstabelle[c("Primaertumor_Topographie_ICD_O"),"referenztabelle"] <- "topographie_zfkd" #"topographie"
zuweisungstabelle[c("Menge_FM","Primaerdiagnose_Menge_FM"),"referenztabelle"] <- "menge_fm"
zuweisungstabelle["Gesamtbeurteilung_Tumorstatus","referenztabelle"] <- "tumorverlauf_gesamt"
zuweisungstabelle["Verlauf_Lokaler_Tumorstatus","referenztabelle"] <- "tumorverlauf_pt"
zuweisungstabelle["Verlauf_Tumorstatus_Lymphknoten","referenztabelle"] <- "tumorverlauf_lk"
zuweisungstabelle["Verlauf_Tumorstatus_Fernmetastasen","referenztabelle"] <- "tumorverlauf_fm"
zuweisungstabelle[c("Anzahl_Tage_Diagnose_Tod","Anzahl_Tage_Diagnose_OP","Anzahl_Tage_Diagnose_ST","Anzahl_Tage_Diagnose_SYST",
                    "Anzahl_Tage_Diagnose_Tod","Anzahl_Tage_ST","Anzahl_Tage_SYST", "Anzahl_Monate_Diagnose_Zensierung"),"referenztabelle"] <- "tage"
zuweisungstabelle[c("Verstorben","Primaertumor_DCN"),"referenztabelle"] <- "janein"
zuweisungstabelle[c("Seitenlokalisation","Seite_Zielgebiet"),"referenztabelle"] <- "seite"
zuweisungstabelle["Menge_OPS_code","referenztabelle"] <- "ops_codes_zfkd"
zuweisungstabelle["Beurteilung_Residualstatus","referenztabelle"] <- "residualstatus"
zuweisungstabelle[c("Todesursache_Grundleiden_Version",
                    "Weitere_Todesursachen_Version",
                    "Primaertumor_ICD_Version"),"referenztabelle"] <- "icd10_version"
zuweisungstabelle[c("Primaertumor_Topographie_ICD_O_Version",
                    "Primaertumor_Morphologie_ICD_O_Version"),"referenztabelle"] <- "icdo3_version"
zuweisungstabelle["Diagnosesicherung","referenztabelle"] <- "diagnosesicherung"
zuweisungstabelle[c("cTNM_Version","pTNM_Version","Folgeereignis_TNM_Version"),"referenztabelle"] <- "tnm_version"
zuweisungstabelle["Primaertumor_Grading","referenztabelle"] <- "grading"
zuweisungstabelle[c("cTNM_UICC_Stadium","pTNM_UICC_Stadium","Folgeereignis_TNM_UICC"),"referenztabelle"] <- "stadium"
zuweisungstabelle[grep(x = zuweisungstabelle[,"variable"], pattern = "praefix"),"referenztabelle"] <- "tnm_praefix"
zuweisungstabelle[c("Primaertumor_LK_untersucht","Primaertumor_LK_befallen"),"referenztabelle"] <- "lk_anzahl"
zuweisungstabelle[c("cTNM_y","pTNM_y","Folgeereignis_y_Symbol"),"referenztabelle"] <- "tnm_y"
zuweisungstabelle[c("cTNM_r","pTNM_r","Folgeereignis_r_Symbol"),"referenztabelle"] <- "tnm_r"
zuweisungstabelle[c("cTNM_a","pTNM_a","Folgeereignis_a_Symbol"),"referenztabelle"] <- "tnm_a"
zuweisungstabelle[c("c_L.Kategorie","p_L.Kategorie","Folgeereignis_L_Kategorie"),"referenztabelle"] <- "tnm_L"
zuweisungstabelle[c("c_V.Kategorie","p_V.Kategorie","Folgeereignis_V_Kategorie"),"referenztabelle"] <- "tnm_V"
zuweisungstabelle[c("c_Pn.Kategorie","p_Pn.Kategorie","Folgeereignis_Pn_Kategorie"),"referenztabelle"] <- "tnm_Pn"
zuweisungstabelle[c("c_S.Kategorie","p_S.Kategorie","Folgeereignis_S_Kategorie"),"referenztabelle"] <- "tnm_S"
zuweisungstabelle["Intention","referenztabelle"] <- "intention_op"
zuweisungstabelle["Intention_st","referenztabelle"] <- "intention_st"
zuweisungstabelle["Intention_sy","referenztabelle"] <- "intention_sy"
zuweisungstabelle["Therapieart","referenztabelle"] <- "therapieart"
zuweisungstabelle["Inzidenzort","referenztabelle"] <- "landkreis" #"gemeindekennziffer"
zuweisungstabelle["Praetherapeutischer_Menopausenstatus","referenztabelle"] <- "menopause"
zuweisungstabelle[c("HormonrezeptorStatus_Oestrogen","HormonrezeptorStatus_Progesteron","Her2neuStatus"),"referenztabelle"] <- "rezeptorstatus"
zuweisungstabelle["Menge_OPS_version","referenztabelle"] <- "ops_version"
zuweisungstabelle["Applikationsart","referenztabelle"] <- "applikationsart"
zuweisungstabelle["Applikationsspezifizierung","referenztabelle"] <- "applikationsspezifizierung"
zuweisungstabelle["Zielgebiet_Code","referenztabelle"] <- "zielgebiete"
zuweisungstabelle["Zielgebiet_CodeVersion","referenztabelle"] <- "zielgebiete_version"
zuweisungstabelle["Stellung_OP","referenztabelle"] <- "stellung_op"
zuweisungstabelle[c("TumorgroesseDCIS","TumorgroesseInvasiv"),"referenztabelle"] <- "tumorgroesse"

# Zuweisung der Methode des Referenzlistenabgleichs
# Association of alignment method for data and reference data
zuweisungstabelle[grep("Menge", x = rownames(zuweisungstabelle), ignore.case = TRUE),"methode"] <- "menge"
zuweisungstabelle[c("Substanzen","Protokolle", "Zielgebiet_CodeVersion","Zielgebiet_Code"),"methode"] <- "menge"
zuweisungstabelle[c("Patient_ID","Tumor_ID","Patient_ID_FK","Tumor_ID_FK","OP_ID","SYST_ID","Bestrahlung_ID","Folgeereignis_ID"),"methode"] <- "individuell"
zuweisungstabelle[c("Geburtsdatum","Diagnosedatum","Datum_Vitalstatus","Datum_OP","Datum_Folgeereignis","Beginn_Bestrahlung","Beginn_SYST"),"methode"] <- "datum"
zuweisungstabelle[zuweisungstabelle[,"methode"]=="datum","referenztabelle"] <- "datumsangabe"
zuweisungstabelle[c("Anzahl_Tage_Diagnose_Tod","Anzahl_Tage_Diagnose_OP","Anzahl_Tage_Diagnose_ST","Anzahl_Tage_Diagnose_SYST",
                    "Anzahl_Tage_ST","Anzahl_Tage_SYST", "Anzahl_Monate_Diagnose_Zensierung",
                    "Primaertumor_LK_untersucht","Primaertumor_LK_befallen",
                    "TumorgroesseInvasiv","TumorgroesseDCIS"),"methode"] <- "numerisch"
zuweisungstabelle["Applikationsspezifizierung","methode"] <- "menge"
zuweisungstabelle[grep("m_symbol", x = rownames(zuweisungstabelle), ignore.case = TRUE),"methode"] <- "referenz"
zuweisungstabelle[c("Weitere_Todesursachen","Weitere_Todesursachen_Version"),"methode"] <- "menge"
zuweisungstabelle[is.na(zuweisungstabelle[,"methode"]),"methode"] <- "referenz"
zuweisungstabelle["Inzidenzort", "methode"] <- "referenz"

saveRDS(zuweisungstabelle,"./zuweisungstabelle.RDS")
write.csv(zuweisungstabelle, "./zuweisungstabelle.csv")


# Einlesen von Referenzdaten aus anderen Quellen oder aus selbst generierten Listen. 
# Die aktuellen Referenzlisten finden sich bereits im Ordner "./Referenzdaten" hinterlegt und müssen nicht mehr selbst generiert werden.
# Generation of reference data from external sources or by self-defined lists.
# The currently used reference data is already provided in the "./Referenzdaten" folder and should therefore not be generated again.

# TNM ####
# tnm <-read.csv("./Referenzdaten/ref_tnm.csv")
# tnm_short <- unique.data.frame(tnm[,c("TNM","STRLOKALISATIONSCODE","VALUE")])
# tnm_short[,1] <- tolower(tnm_short [,1])
# tnm_short[,2] <- tolower(tnm_short [,2])
# tnm_short[,3] <- tolower(tnm_short [,3])
# 
# tnm_short[tnm_short[,"TNM"]=="t",]
# 
# write.csv(tnm_short[tnm_short[,"TNM"]=="t",][,c(3,2,1)], file = "./Referenzdaten/tnm_t.csv",row.names = FALSE)
# write.csv(tnm_short[tnm_short[,"TNM"]=="n",][,c(3,2,1)], file = "./Referenzdaten/tnm_n.csv",row.names = FALSE)
# write.csv(tnm_short[tnm_short[,"TNM"]=="m",][,c(3,2,1)], file = "./Referenzdaten/tnm_m.csv",row.names = FALSE)
#tnm_t <- read.csv("./Referenzdaten/tnm_t.csv")
#tnm_t_hkr <- unique(tnm_t[,c(1,3)])
#write.csv(tnm_t_hkr,"./Referenzdaten/tnm_t_hkr.csv",row.names = FALSE)
#write.csv(rbind(as.matrix(tnm_t),""),"./Referenzdaten/tnm_t.csv",row.names = FALSE)
#tnm_n <- read.csv("./Referenzdaten/tnm_n.csv")
#tnm_n_hkr <- unique(tnm_n[,c(1,3)])
#write.csv(tnm_n_hkr,"./Referenzdaten/tnm_n_hkr.csv",row.names = FALSE)
#write.csv(rbind(as.matrix(tnm_n),""),"./Referenzdaten/tnm_n.csv",row.names = FALSE)
#tnm_m <- read.csv("./Referenzdaten/tnm_m.csv")
#tnm_m_hkr <- unique(tnm_m[,c(1,3)])
#write.csv(tnm_m_hkr,"./Referenzdaten/tnm_m_hkr.csv",row.names = FALSE)
#write.csv(rbind(as.matrix(tnm_m),""),"./Referenzdaten/tnm_m.csv",row.names = FALSE)

# Fernmetastasen ####
# write.csv(c("ADR","BRA","GEN","HEP","LYM","MAR","OSS","OTH","PER","PLE","PUL","SKI",""),"./Referenzdaten/menge_fm.csv",row.names = FALSE)
# Geschlecht ####
#str.geschl <- c("M","W","D","X","U")
#write.csv(str.geschl,"./Referenzdaten/geschlecht.csv",row.names = FALSE)
#read.csv("./Referenzdaten/geschlecht.csv")

# Verlauf Gesamtbeurteilung ####
#gesamtb.verlauf <- c("B", "D", "K", "P", "R", "T", "U", "V", "X","Y","")
#write.csv(gesamtb.verlauf, "./Referenzdaten/tumorverlauf_gesamt.csv", row.names = FALSE)
## Verlauf Primaertumor, Lymphknoten, Fernmetastasen####
#tumorverlauf_pt <- c("K","T","P","N","R","F","U","X","")
#write.csv(tumorverlauf_pt, "./Referenzdaten/tumorverlauf_pt.csv", row.names = FALSE)
#tumorverlauf_lk <- c("K","T","P","N","R","F","U","X","")
#write.csv(tumorverlauf_lk, "./Referenzdaten/tumorverlauf_lk.csv", row.names = FALSE)
#tumorverlauf_fm <- c("K","T","P","N","R","F","U","X","")
#write.csv(tumorverlauf_fm, "./Referenzdaten/tumorverlauf_fm.csv", row.names = FALSE)

# Seitenlokalisation ####
#seite <- c("","L","R","B","M","U","T")
#write.csv(seite, "./Referenzdaten/seite.csv",row.names = FALSE)
# verstorben ####
#janein <- c("J","N")
#write.csv(janein, "./Referenzdaten/janein.csv",row.names = FALSE)
# Abstand Tage ####
#tage <- c(0,36500)
#write.csv(tage, "./Referenzdaten/tage.csv",row.names = FALSE)

# icd10 Codes ####
#icd_10codes_tod_zfkd <- read.csv("./Material/Referenzlisten ZFKD/icd10_todesursache.csv",sep = ";",encoding = "UTF-8")[,c("code","name")]
#head(icd_10codes_tod_zfkd)
#write.csv(icd_10codes_tod_zfkd,"./Referenzdaten/icd_10codes_tod_zfkd.csv",row.names = FALSE)

# Histocodes ####
#morphologie_zfkd <- read.csv("./Material/Referenzlisten ZFKD/morphologie.csv",sep=";",encoding = "latin1")[,c(1,3)]
#colnames(morphologie_zfkd) <- c("code","name")
#write.csv(morphologie_zfkd,"./Referenzdaten/morphologie_zfkd.csv",row.names = FALSE)

# lokalisation ####
#topographie_zfkd <- read.csv("./Material/Referenzlisten ZFKD/topographie.csv",sep=";",encoding = "latin1")[,2:3]
#write.csv(topographie_zfkd,"./Referenzdaten/topographie_zfkd.csv",row.names = FALSE)

# diagnose_ICD####
#primaerturmoricd10 <- read.csv("./Material/diagnose_icd.csv")
#write.csv(primaerturmoricd10,"./Referenzdaten/primaerturmoricd10.csv", row.names = FALSE)

# Residualstatus ####
#residualstatus <- c("R1(is)","R1","RX","R2","R0","R1(cy+)","U","")
#write.csv(residualstatus,"./Referenzdaten/residualstatus.csv",row.names = FALSE)

# OPS-Codes ####
#ops_codes_zfkd_roh <- read.csv("./Material/Referenzlisten ZFKD/ops.csv",sep=";")
#grep(pattern = "unbe*",x=ops_codes_zfkd_roh[,3],ignore.case = TRUE)
#grep(pattern = "unbe*",x=ops_codes_zfkd_roh[,4],ignore.case = TRUE)
#ops_zfkd_vektor <- !grep(pattern = "unbe*",x=ops_codes_zfkd_roh[,4],ignore.case = TRUE)%in%grep(pattern = "unbe*",x=ops_codes_zfkd_roh[,3],ignore.case = TRUE)
#summary(ops_codes_zfkd_roh)
#ops_codes_zfkd_clean <- (ops_codes_zfkd_roh[-c(grep(pattern = "unbe*",x=ops_codes_zfkd[,4],ignore.case = TRUE)[ops_zfkd_vektor]),])[,c(1,8)]
#colnames(ops_codes_zfkd_clean) <- c("code","name")
#write.csv(ops_codes_zfkd_clean,"./Referenzdaten/ops_codes_zfkd.csv",row.names = FALSE)

# Versionen ####
#icd10_version <- c("10 2004 GM","10 2005 GM","10 2006 GM","10 2007 GM","10 2008 GM","10 2009 GM","10 2010 GM","10 2011 GM","10 2012 GM","10 2013 GM","10 2014 GM","10 2015 GM","10 2016 GM","10 2016 WHO","10 2017 GM","10 2018 GM","10 2019 GM","10 2020 GM","10 2021 GM","10 2022 GM","Sonstige")
#write.csv(icd10_version,"./Referenzdaten/icd10_version.csv",row.names = FALSE)

#icdo3_version <- c("31","32","33","bb")
#write.csv(icdo3_version,"./Referenzdaten/icdo3_version.csv",row.names = FALSE)

#tnm_version <- c(6,7,8)
#write.csv(tnm_version,"./Referenzdaten/tnm_version.csv",row.names = FALSE)

#ops_version <- c(2004:2029)
#write.csv(ops_version,"./Referenzdaten/ops_version.csv",row.names = FALSE)

# Diagnosesicherung ####
#diagnosesicherung <- c(0,1,2,4,5,6,7,9)
#write.csv(diagnosesicherung,"./Referenzdaten/diagnosesicherung.csv",row.names = FALSE)

# grading ####
#grading_werte <- c(0,1,2,3,4,5,"X","L","M","H","B","U","T")
#write.csv(grading_werte, "./Referenzdaten/grading.csv",row.names = FALSE)
#grading <- read.csv("./Referenzdaten/grading.csv")

# tnm symbole ####
#write.csv(x = c("","y"),"./Referenzdaten/tnm_y.csv", row.names = FALSE)
#tnm_y <- read.csv("./Referenzdaten/tnm_y.csv")
#write.csv(x =c("", "r"),"./Referenzdaten/tnm_r.csv", row.names = FALSE)
#tnm_r <- read.csv("./Referenzdaten/tnm_r.csv")
#write.csv(x = "a","./Referenzdaten/tnm_a.csv", row.names = FALSE)
#tnm_a <- read.csv("./Referenzdaten/tnm_a.csv")
#write.csv(x = c("c","p","u",""),"./Referenzdaten/tnm_praefix.csv", row.names = FALSE)
#tnm_praefix <- read.csv("./Referenzdaten/tnm_praefix.csv")
#write.csv(x = c("LX","L0","L1",""),"./Referenzdaten/tnm_L.csv", row.names = FALSE)
#tnm_L <- read.csv("./Referenzdaten/tnm_L.csv")
#write.csv(x = c("VX","V0","V1","V2",""),"./Referenzdaten/tnm_V.csv", row.names = FALSE)
#tnm_V <- read.csv("./Referenzdaten/tnm_V.csv")
#write.csv(x = c("PnX","","Pn0","Pn1"),"./Referenzdaten/tnm_Pn.csv", row.names = FALSE)
#tnm_Pn <- read.csv("./Referenzdaten/tnm_Pn.csv")
#write.csv(x = c("SX","S0","S1","S2","S3",""),"./Referenzdaten/tnm_S.csv", row.names = FALSE)
#tnm_S <- read.csv("./Referenzdaten/tnm_S.csv")
# m-symbol ####
# m_symbol <- c("","m","m,is","is",2:9,paste0(2:9,",is"),10:999,paste0(10:999,",is"))
# write.csv(m_symbol, "./Referenzdaten/m_symbol.csv",row.names = FALSE)

# stadium ####
#stadium_material <- read.csv("./Material/stadium_test.csv")
#write.csv(stadium_material,"./Referenzdaten/stadium.csv",row.names = FALSE)

# LK Anzahl ####
# write.csv(c(0,999),"./Referenzdaten/lk_anzahl.csv",row.names = FALSE)

# Intention####
# write.csv(c("K","P","S","X",""),"./Referenzdaten/intention_sy.csv",row.names = FALSE)
# intention_sy <- read.csv("./Referenzdaten/intention_sy.csv")
# write.csv(c("K","P","S","X","O",""),"./Referenzdaten/intention_st.csv",row.names = FALSE)
# intention_st <- read.csv("./Referenzdaten/intention_st.csv")
# write.csv(c("K","P","D","R","S","X",""),"./Referenzdaten/intention_op.csv",row.names = FALSE)
# intention_op <- read.csv("./Referenzdaten/intention_op.csv")

# stellung zu op ####
# write.csv(c("O","A","N","Z","S","I",""),"./Referenzdaten/stellung_op.csv",row.names = FALSE)
# stellung_op <- read.csv("./Referenzdaten/stellung_op.csv")

# gemeindeschluessel ####
# write.csv(c(01000,17999),"./Referenzdaten/gemeindekennziffer.csv",row.names = FALSE)
# gemeindekennziffer <- read.csv("./Referenzdaten/gemeindekennziffer.csv")
# landkreis <- read.csv("./Material/Referenzlisten ZFKD/landkreis.csv",sep=";",encoding = "UTF-8")[,1:2]
# colnames(landkreis) <- c("code","name")
# write.csv(landkreis,"./Referenzdaten/landkreis.csv",row.names = FALSE)

# mammamodul
# write.csv(c("1","3","U"),"./Referenzdaten/menopause.csv",row.names = FALSE)
# menopause <- read.csv("./Referenzdaten/menopause.csv")
# write.csv(c("P","N","U",""),"./Referenzdaten/rezeptorstatus.csv",row.names = FALSE)
# rezeptorstatus <- read.csv("./Referenzdaten/rezeptorstatus.csv")

# zielgebiete ####
#zielgebiete.2021 <- c("1.1","1.2","1.3","1.4","1.5","2.1","2.2","2.3","2.4","2.5","2.6","2.7","2.8","2.9","2.10","2.11","2.12","3.1","3.2","3.3","3.4","3.5","3.6","3.7","3.8","4.1","4.2","4.3","4.4","4.5","4.6","4.7","4.8","4.9","4.10","4.11","4.12","4.13","5.1","5.2","5.3","5.4","5.5","5.6","5.7","5.8","5.9","5.10","5.11","5.12","6.1","6.2","6.3","6.4","6.5","6.6","6.7","6.8","6.9","6.10","6.11","6.12","6.13","6.14","6.15","6.16","6.17","6.18","6.19","7.1","7.2","7.3","7.4","7.5","7.6","7.7","7.8","7.9","8.1","8.2","9.1","9.2","9.3","9.4","9.5","9.6","9.7","9.8","9.9","9.10","9.11","9.12","9.13","9.14","9.15","10.1","10.2","10.3")
#zielgebiete.2014 <-  c("1.","1.1.","1.2.","1.3.","2.","2.+","2.-","2.1.","2.1.+","2.1.-","2.2.","2.2.+","2.2.-","2.3.","2.3.+","2.3.-","2.4.","2.4.+","2.4.-","2.5.","2.5.+","2.5.-","2.6.","2.6.+","2.6.-","2.7.","2.7.+","2.7.-","2.8.","2.8.+","2.8.-","2.9.","3.","3.+","3.-","3.1.","3.1.+","3.1.-","3.2.","3.2.+","3.2.-","3.3.","3.3.+","3.3.-","3.4.","3.4.+","3.4.-","3.5.","3.5.+","3.5.-","3.6.","3.6.+","3.6.-","3.7.","4.","4.+","4.-","4.1.","4.1.+","4.1.-","4.2.","4.2.+","4.2.-","4.3.","4.3.+","4.3.-","4.4.","4.4.+","4.4.-","4.5.","4.5.+","4.5.-","4.6.","4.6.+","4.6.-","4.7.","4.8.","4.8.+","4.8.-","4.9.","4.9.+","4.9.-","5.","5.+","5.-","5.1.","5.1.+","5.1.-","5.2.","5.2.-","5.2.+","5.3.","5.3.-","5.3.+","5.4.","5.4.+","5.4.-","5.5.","5.5.+","5.5.-","5.6.","5.6.+","5.6.-","5.7.","5.7.+","5.7.2.-","5.7.2.+","5.7.2.","5.7.1.-","5.7.1.+","5.7.1.","5.7.-","5.8.","5.8.-","5.8.+","5.9.","5.9.-","5.9.+","5.10.","5.10.+","5.10.-","5.11.","5.11.+","5.11.-","5.12.","6.","6.1.","6.2.","6.3.","6.4.","6.5.","6.6.","6.7.","6.8.","6.9.","6.10.","6.11.","6.12.","6.13.","6.14.","6.15.","6.16.","7.","7.+","7.-","7.1.","7.2.","8.","8.1.","8.2.")
#zielgebiete.test <- matrix(data = c(zielgebiete.2014,zielgebiete.2021),ncol = 1)
#zielgebiete.test <- cbind(zielgebiete.test,"CodeVersion2021")
#zielgebiete.test[1:length(zielgebiete.2014),2] <- "CodeVersion2014"
# write.csv(zielgebiete.test,"./Referenzdaten/zielgebiete.csv",row.names = FALSE)
# zielgebiete version ####
#zielgebiete_version <- c("CodeVersion2014","CodeVersion2021","")
#write.csv(zielgebiete_version,"./Referenzdaten/zielgebiete_version.csv",row.names = FALSE)

# Datumsangaben ####
#datum_min <- c(1900,01,01)
#datum_max <- c(2023,12,31)
#datumsangabe <- matrix(c(datum_min, datum_max),nrow = 2,byrow = TRUE)
#write.csv(datumsangabe,"./Referenzdaten/datumsangabe.csv",row.names = FALSE)

#tumorgroesse <- c(0,500) ####
#write.csv(tumorgroesse,"./Referenzdaten/tumorgroesse.csv",row.names = FALSE)

# therapieart ####
#therapieart <- c("CH","HO","CHO","IM","ZS","CI","CZ","CIZ","IZ","SZ","AS","WS","WW","SO","")
#write.csv(therapieart,"./Referenzdaten/therapieart.csv",row.names = FALSE)

#Applikationsspezifizierung ####
#applikationsspezifizierung <- c("RCJ","RCN","ST","4D","I","K","HDR","LDR","PDR","SIRT","PRRT","PSMA","RJT","RIT","")
#write.csv(applikationsspezifizierung,"./Referenzdaten/applikationsspezifizierung.csv",row.names = FALSE)
#applikationsart <- c("Perkutan","Kontakt","Metabolisch","Sonstige","Unbekannt")
#write.csv(applikationsart,"./Referenzdaten/applikationsart.csv",row.names = FALSE)

