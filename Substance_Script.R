tidyverse_support <- FALSE
if(requireNamespace("stringr", quietly=TRUE) & requireNamespace("tidyr", quietly=TRUE) & requireNamespace("dplyr", quietly=TRUE)){
  library(stringr)
  library(tidyr)
  library(dplyr)
  tidyverse_support <- TRUE
}

source("./Substance_Utils.R", encoding = "UTF-8")
# subset the ATC codes to cancer-related codes only for more speed
ATC_refs <- read.csv("./Referenzdaten-Latest/substanz.csv", encoding = "UTF-8")

names(ATC_refs) <- tolower(names(ATC_refs))
#colnames(ATC_refs) <- c("Substanz", "Code", "Therapieart")

Substanzkatalog <- read.csv2("./Referenzdaten-Latest/ReferenzlisteSubstanzenV1.2.csv", encoding = "UTF-8")
Substanzkatalog$Substanz <- Substanzkatalog$Substanzname
Substanzkatalog$Substanz_lower <- tolower(Substanzkatalog$Substanz)
Substanzkatalog$Synonym <- Substanzkatalog$Bezeichnung
atc_codes <- c(ATC_refs$code, Substanzkatalog$ATC_Kode)
atc_names <- c(ATC_refs$substanz, Substanzkatalog$Substanz)
atc_class <- c(ATC_refs$therapieart, Substanzkatalog$Therapieart)
combined_ATC <- unique(tibble(atc_class, atc_names, atc_codes))
names(combined_ATC) <- c("Therapieart", "Substanz", "Code")

dta <- read.csv(paste0(OUTPUT_DIRECTORY,"/gesamt/", "systemtherapie.csv"),
                encoding = "UTF-8")[,c("SYST_ID", "Register_ID_FK", "Patient_ID_FK", "Tumor_ID_FK", "Substanzen")]


dta$Merge_ID <- 1:nrow(dta)
dta_no_NA <- subset(dta, !is.na(Substanzen) & trimws(Substanzen) != "")

# check whether df column Substanzen is solely NA. In this case, Substanzen_extracted will be NA as well
if (dim(dta_no_NA)[1] == 0) {
  dta_out <- dta
  dta_out$Substanzen_extracted <- NA
  write.csv(dta_out, paste0(OUTPUT_DIRECTORY,"/gesamt/", "systemtherapie_with_substance_service_variable.csv"), row.names=FALSE)
  print("Substance extraction: All Substances are NA or empty strings. Thus, service variable cannot be created.")

} else {

#   # code relies on tidyverse if available but falls back to base R if tidyverse is not installed
  if (FALSE) { #tidyverse_support) {
    
    dta_no_NA <- as_tibble(subset(dta, !is.na(Substanzen) & trimws(Substanzen) != ""))
    dta_split <- dta_no_NA %>% 
      mutate(Substanzen = trimws(Substanzen)) %>%
      separate_longer_delim(Substanzen, delim = regex("\\s*[,;]\\s*")) #%>%
      #as.data.table()
    
    #dta_split <- lazy_dt(dta_split, immutable=FALSE)
    substance_service <- dta_split %>%
      mutate(ATC_Code_Dummy = sapply(Substanzen, is_ATC_code)
      ) %>% collect()
    substance_service <- substance_service %>%
      mutate(Substanzen_extracted = if_else(
        ATC_Code_Dummy == 0,
        sapply(Substanzen, function(x) get_match(preprocess_text(x), Substanzkatalog)),
        sapply(Substanzen, function(x) get_ATC_code(x, combined_ATC))
      ))
    
    substance_service <- substance_service %>% group_by(Merge_ID) %>%
      summarise(Substanzen_extracted = {
        valid <- Substanzen_extracted[!is.na(Substanzen_extracted) & trimws(Substanzen_extracted) != ""]
        if (length(valid) > 0) paste(unique(valid), collapse = ";") else NA
      }, .groups = "drop") 
    
  } else {

    # This is the base R version
    dta_split <- dta_no_NA
    dta_split$Substanzen <- trimws(dta_split$Substanzen)

    split_rows <- strsplit(dta_split$Substanzen, "\\s*[,;]\\s*")
    dta_split <- dta_split[rep(seq_len(nrow(dta_split)), lengths(split_rows)), ]
    dta_split$Substanzen <- trimws(unlist(split_rows))

    dta_split$ATC_Code_Dummy <- sapply(dta_split$Substanzen, is_ATC_code)

    dta_split$Substanzen_cleaned <- ""
    dta_split$Substanzen_cleaned[dta_split$ATC_Code_Dummy == 0] <- sapply(
      dta_split$Substanzen[dta_split$ATC_Code_Dummy == 0],
      preprocess_text)
    dta_split$Substanzen_cleaned[dta_split$ATC_Code_Dummy == 1] <-
      trimws(dta_split$Substanzen[dta_split$ATC_Code_Dummy == 1])

    dta_split$Substanzen_extracted <- ""
    if(length(dta_split$Substanzen[dta_split$ATC_Code_Dummy == 0]) > 0){
      dta_split$Substanzen_extracted[dta_split$ATC_Code_Dummy == 0] <- sapply(
        dta_split$Substanzen_cleaned[dta_split$ATC_Code_Dummy == 0],
        function(x) get_match(x, Substanzkatalog))
    }
    if(length(dta_split$Substanzen[dta_split$ATC_Code_Dummy == 1]) > 0){
      dta_split$Substanzen_extracted[dta_split$ATC_Code_Dummy == 1] <- sapply(
        dta_split$Substanzen[dta_split$ATC_Code_Dummy == 1],
        function(x) get_ATC_code(x, ATC_refs))
    }

  #   #aggregieren
    substance_service <- aggregate(
      Substanzen_extracted ~ Merge_ID,
      data = dta_split,
      FUN = function(x) {
        valid <- x[!is.na(x) & trimws(x) != ""]
        if (length(valid) > 0) {
          paste(unique(valid), collapse = ";")
        } else {
          NA_character_
        }
      },
      na.action = na.pass
    )
  }
  
    #merge wieder mit Ausgangsdatensatz "dta"
    dta_out <- merge(dta, substance_service, by = "Merge_ID", all.x = TRUE)
    #dta_out <- merge(dta, dta_out)
    dta_out <- dta_out[order(dta_out$Merge_ID), ]
    
    if (!(nrow(dta_no_NA) == nrow(substance_service) && nrow(dta_out) == nrow(dta))) {
      warning("merge in substance extraction script did not work!")
    }
    
  #output speichern
  write.csv(dta_out, paste0(OUTPUT_DIRECTORY,"/gesamt/", "systemtherapie_with_substance_service_variable.csv"), row.names=FALSE)
  
  #output stats ersellen
  sub_halde <- dta_out
  sub_halde$Substanzen[sub_halde$Substanzen == ""] <- NA
  sub_halde <- subset(sub_halde, !is.na(Substanzen))
  
  sub_halde$Substanzen_extracted[is.na(sub_halde$Substanzen_extracted)] <- "NA"
  sub_halde$Substanzen_extracted[sub_halde$Substanzen_extracted == ""] <- "NA"
  
  sub_halde$status <- NA
  sub_halde$status[sub_halde$Substanzen_extracted != sub_halde$Substanzen] <- "transformed"
  sub_halde$status[sub_halde$Substanzen_extracted == "NA"] <- "nothing found"
  sub_halde$status[sub_halde$Substanzen_extracted == sub_halde$Substanzen] <- "unchanged"
  
  
  sub_halde$SYST_ID <- 1:nrow(sub_halde)
  sub_halde_count <- aggregate(SYST_ID ~ Substanzen + Substanzen_extracted + status,
                               data = sub_halde[,c("SYST_ID","Substanzen", "Substanzen_extracted", "status")],
                               FUN = length)
  colnames(sub_halde_count)[colnames(sub_halde_count) == "SYST_ID"] <- "count"
  sub_halde_count <- sub_halde_count[order(sub_halde_count$status,
                                           sub_halde_count$count, decreasing = TRUE), ]
  write.csv(sub_halde_count, paste0(OUTPUT_DIRECTORY,"/gesamt/", "substance_extraction_stats.csv"), row.names=FALSE)
  
  write.csv(sub_halde, paste0(OUTPUT_DIRECTORY,"/gesamt/", "Substanzen_Transformationen_NichtGefunden.csv"),
            row.names = FALSE)
  
  }
  