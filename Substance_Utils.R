is_ATC_code <- function(input) {
  #match the atc pattern (1 letter, 2 digits, 2 letters, 2 digits, 4 optional year digits)
  pattern <- "^[A-Za-z]\\d{2}[A-Za-z]{2}\\d{2}(?:\\s?\\d{4})?$"
  
  if (grepl(pattern, input, perl=TRUE)) {
    return(1)
    
  } else {
    return(0)
    
  }
}

remove_words <- function(input_data) {
  
  
  removed_expressions <- str_remove_all(input_data, "(?i)o\\.n\\.a\\.?")
  removed_expressions <- str_remove_all(removed_expressions, "(?i)i\\.v\\.?")
  removed_expressions <- str_remove_all(removed_expressions, "(?i)p\\.o\\.?")
  removed_expressions <- str_remove_all(removed_expressions, "(?i)i\\.th\\.?")
  removed_expressions <- str_remove_all(removed_expressions, "(?i)\\d+\\s*mg")
  
  words_to_remove <- c("wöchentlich", "weekly", "woche", "allgemein",
                       "entsprechend", "beendet", "zyklus", "version",
                       "bis", "mg", "kg", "m2", "m²", "©", "bezeichnet",
                       "entfällt", "watch & wait", "watch and wait", "®", "n\\.n\\.",
                       "\\(CBCDA\\)", "\\(CDDP\\)", "\\(EPI\\)", "\\(MTX\\)", "\\(AraC\\)",
                       "\\(IDA\\)", "o\\.n\\.A.", " p\\.o\\.", "\\(MPL\\)", "\\(MPL\\)", "\\(VP16\\)",
                       "\\(CTX\\)", "\\(VCR\\)", "\\(BLEO\\)", "\\(VP 116\\)", "\\(PBZ\\)", "\\(Kadcyla\\)",
                       "natürlich", "\\(DDP\\)", "T-DM1", "\\(T-DM1\\)", "\\(Taxol\\)", "\\(.*\\)",
                       "ohne nähere Angabe")
  
  formatted_regex <-  paste0("(?i)", words_to_remove, collapse = "|")
  output_string <- str_squish(str_remove_all(removed_expressions, formatted_regex))  
#  output_string <- gsub("[^a-zA-Z0-9 ]", "", output_string, perl = TRUE)
  
  
  return(output_string)
  
}

find_BSC <- function(input_string) {
  
  if (str_detect(input_string, regex("\\bBSC\\b",
                                      ignore_case = TRUE))) {
    return("Best Supportive Care")
  }
  
  return(input_string)
}

find_5FU <- function(input_string) {
  
  if (str_detect(input_string,
                 regex("\\b5 FU|5 fu|5FU|5fu|5-FU|5-fu|Fluoruracil|flourouracil|
                 5-fluoruuracil|5-fluoro-uracil|5-fluoruuracil|
                 5-fluoruracil|floururacil|5-fluorounacil|
                 flourouraci|5-fluourouracil|5-Fluorouracil\\b", ignore_case = TRUE))) {
    
    input_string <- "Fluorouracil"
  }
  
  output_string <- input_string
  
  return(output_string)
}

find_Paclitaxel <- function(input_string) {
  
  if (str_detect(input_string, regex("\\bnab[- ]?Paclitaxel\\b", ignore_case=TRUE))) {
    return("Paclitaxel nab")
  }
  
  return(input_string)
  
}

find_carboplatin <- function(input_string) {
  
  if (str_detect(input_string, regex("\\bCarboplat\\b", ignore_case=TRUE))) {
    return("Carboplatin")
  }
    
  return(input_string)
}

replace_SZT <- function(input_string) {
  if (str_detect(input_string, regex("\\bSZT\\b",
                                 ignore_case = TRUE))){
    return("Stammzellentherapie")
  }
  return(input_string)
}


remove_short_words <- function(input_string) {
  
  if (is.na(input_string)) return(NA)
  
  cleaned <- trimws(input_string)
  
  if (nchar(cleaned) < 3) return(NA)
  if (tolower(cleaned) %in% c("k a", "ka", "k.a", "k.a.", "n a", "na")) return(NA)
  
  cleaned
}


remove_duplicates <- function(text) {
  
  strings <- unlist(str_split(text, " "))
  unique_strings <- unique(strings)
  return(paste(unique_strings, collapse = " "))
  
}

preprocess_text <- function(input_string) {
  
  remove_dots <- gsub(".", "", input_string, fixed = TRUE)
  remove_slash <- gsub("/", "", remove_dots, fixed = TRUE)
  
  processed_5FU <- find_5FU(remove_slash)
  processed_BSC <- find_BSC(processed_5FU)
  processed_paclitaxel <- find_Paclitaxel(processed_BSC)
  processed_carbo <- find_carboplatin(processed_paclitaxel)
  translated_SZT <- replace_SZT(processed_carbo)
  processed_remove_words <- remove_words(translated_SZT)
  processed_remove_short_words <- remove_short_words(processed_remove_words)
  processed_removed_duplicates <- remove_duplicates(processed_remove_short_words)
  out <- trimws(processed_removed_duplicates)
  return(out)
}

####
find_perfect_match <- function(preprocessed_text, reference_table) {
  
  match_substance <- reference_table$Substanz[reference_table$Substanz_lower %in% tolower(preprocessed_text)]
  
  
  if (length(match_substance)==1) {
    return(match_substance)
  }
  match_synonym <- reference_table$Substanz[tolower(reference_table$Synonym) %in% tolower(preprocessed_text)]
  
  if (length(match_synonym)==1) {
    return(match_synonym)
  }
  return("")
}


find_detected_match <- function(preprocessed_text, reference_table) {
  
  if (!nzchar(preprocessed_text)) return("")
  
  txt <- tolower(preprocessed_text)
  
  substance_patterns <- paste0("(?<!\\w)", 
                               gsub("([-.+*?^$(){}|\\[\\]\\\\])", "\\\\\\1", 
                                    reference_table$Substanz_lower),
                               "(?!\\w)")
  
  hits <- reference_table$Substanz[
    sapply(substance_patterns, function(pattern) {
      str_detect(txt, regex(pattern, ignore_case = TRUE))
    })
  ]
  
  if (length(hits) == 1) return(hits)
  if (length(hits) > 1) {
    d <- adist(txt, tolower(hits))
    return(hits[which.min(d)])
  }
  

  if ("Synonym" %in% colnames(reference_table)) {
    valid_synonyms <- !is.na(reference_table$Synonym) & nzchar(reference_table$Synonym)
    
    if (any(valid_synonyms)) {
      synonym_patterns <- paste0("(?<!\\w)", 
                                 gsub("([-.+*?^$(){}|\\[\\]\\\\])", "\\\\\\1", 
                                      tolower(reference_table$Synonym[valid_synonyms])),
                                 "(?!\\w)")
      
      syn_hits <- reference_table$Substanz[valid_synonyms][
        sapply(synonym_patterns, function(pattern) {
          str_detect(txt, regex(pattern, ignore_case = TRUE))
        })
      ]
      
      if (length(syn_hits) == 1) return(syn_hits)
      if (length(syn_hits) > 1) {
        d <- adist(txt, tolower(syn_hits))
        return(syn_hits[which.min(d)])
      }
    }
  }
  
  return("")
}

find_fuzzy_match <- function(preprocessed_text, reference_table) {
  
  txt <- trimws(tolower(preprocessed_text))
  
  if (nchar(txt) < 3) return("")
  if (grepl("^[a-z]{1,3}$", txt)) return("")   # short abbreviations
  
  idx <- agrep(
    pattern = paste0("^",stringr::str_escape(txt), "$"),
    x = tolower(reference_table$Substanz),
    max.distance = list(all = 0.2),
    ignore.case = TRUE
  )
  
  if (length(idx) == 1) {
    return(reference_table$Substanz[idx])
  }
  
  if (length(idx) > 1) {
    d <- adist(txt, tolower(reference_table$Substanz[idx]))
    return(reference_table$Substanz[idx[which.min(d)]])
  }
  
  idx_syn <- agrep(
    pattern = paste0("^",stringr::str_escape(txt), "$"),
    x = tolower(reference_table$Synonym),
    max.distance = list(all = 0.2),
    ignore.case = TRUE
  )
  
  if (length(idx_syn) == 1) {
    return(reference_table$Substanz[idx_syn])
  }
  
  if (length(idx_syn) > 1) {
    d <- adist(txt, tolower(reference_table$Synonym[idx_syn]))
    return(reference_table$Substanz[idx_syn[which.min(d)]])
  }
  
  return("")
}

get_match <- function(preprocessed_text, reference_table) {
  
  preprocessed_text <- trimws(preprocessed_text)
  
  if (is.na(preprocessed_text)) return(NA)
  if (nchar(preprocessed_text) < 3) return(NA)
  if (tolower(preprocessed_text) %in% c("k a", "ka", "k.a", "k.a.", "n a", "na")) return(NA)
  
  match_detect <- find_detected_match(preprocessed_text, reference_table)
  if (nzchar(match_detect)) return(match_detect)
  
  match_fuzzy <- find_fuzzy_match(preprocessed_text, reference_table)
  if (nzchar(match_fuzzy)) return(match_fuzzy)
  
  return(NA)
}


get_ATC_code <- function(preprocessed_text, reference_table_ATC) {
  
  preprocessed_text <- trimws(preprocessed_text)
  if(preprocessed_text == "") return("")
  
  safe_pattern <- str_replace_all(tolower(
    preprocessed_text
  ), "([\\^$.|?*+()\\[\\]{}])", "")

  safe_pattern <- trimws(gsub("\\d{4}$", "", safe_pattern, perl = TRUE))
  
  match_substance <- reference_table_ATC$Substanz[
    str_detect(tolower(reference_table_ATC$Code), safe_pattern)
  ]
  if(length(match_substance) == 1) return(match_substance)
  if(length(match_substance) > 1) return(match_substance[1])
  
  
  return("")
}

