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
  output_string <- gsub("[^a-zA-Z0-9 ]", "", output_string, perl = TRUE)
  
  
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

replace_SZT <- function(input_string) {
  if (str_detect(input_string, regex("\\bSZT\\b",
                                 ignore_case = TRUE))){
    return("Stammzellentherapie")
  }
  return(input_string)
}


remove_short_words <- function(input_string) {
  
  string_length <- nchar(input_string)
  
  if (string_length < 3) {
    output_string <- NA
  } else {
    output_string <- input_string
  }
  return(output_string)
}

remove_duplicates <- function(text) {
  
  strings <- unlist(str_split(text, " "))
  unique_strings <- unique(strings)
  return(paste(unique_strings, collapse = " "))
  
}

preprocess_text <- function(input_string) {
  
  processed_5FU <- find_5FU(input_string)
  processed_BSC <- find_BSC(processed_5FU)
  processed_paclitaxel <- find_Paclitaxel(processed_BSC)
  translated_SZT <- replace_SZT(processed_paclitaxel)
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
  
  if (preprocessed_text == "") {
    return("")
  }
  
  match_substance <- reference_table$Substanz[str_detect(tolower(reference_table$Substanz_lower), fixed(tolower(preprocessed_text)))]
  
  if (length(match_substance) == 1) {
    return(match_substance)
  }
  
  if(length(match_substance) > 1) {
    distances <- adist(preprocessed_text, match_substance)
    return(match_substance[which.min(distances)])
  }
  
  match_synonym <- reference_table$Substanz[str_detect(tolower(reference_table$Synonym), fixed(tolower(preprocessed_text)))]
  
  if (length(match_synonym) == 1) {
    return(match_synonym)
  }
  
  if(length(match_synonym) > 1) {
    distances <- adist(preprocessed_text, match_synonym)
    return(match_synonym[which.min(distances)])
  }
  
  return("")
}

get_relative_distance <- function(splitted_input, match) {
  
  distance <- adist(match, splitted_input)
  max_length <- pmax(nchar(splitted_input), nchar(match))
  similarity <- 1 - (distance / max_length)
  
  return(max(similarity))
}

find_fuzzy_match <- function(preprocessed_text, reference_table) {
  
  fuzzy_match <- reference_table$Substanz[adist(tolower(preprocessed_text), 
                                                tolower(reference_table$Substanz)) <= 2]
  
  if (length(fuzzy_match) == 1) {
    rel_dist <- get_relative_distance(tolower(preprocessed_text),
                                      tolower(fuzzy_match))
    if (rel_dist < 0.8) {
      fuzzy_match <- ""
    }
    return(fuzzy_match)
  }
  
  if(length(fuzzy_match) > 1) {
    distances <- adist(preprocessed_text, fuzzy_match)
    fuzzy_match <- fuzzy_match[which.min(distances)][1]
    
    rel_dist <- get_relative_distance(tolower(preprocessed_text),
                                      tolower(fuzzy_match))
    if (rel_dist < 0.8) {
      fuzzy_match <- ""
    }
    return(fuzzy_match)
  }
  
  fuzzy_match_synonym <- reference_table$Substanz[adist(tolower(preprocessed_text), 
                                                        tolower(reference_table$Synonym)) <= 2]
  
  if (length(fuzzy_match_synonym) == 1) {
    rel_dist <- get_relative_distance(tolower(preprocessed_text),
                                      tolower(fuzzy_match_synonym))
    if (rel_dist < 0.8) {
      fuzzy_match_synonym <- ""
    }
    return(fuzzy_match_synonym)
  }
  
  if(length(fuzzy_match_synonym) > 1) {
    distances <- adist(preprocessed_text, fuzzy_match_synonym)
    fuzzy_match_synonym <- fuzzy_match_synonym[which.min(distances)][1]
    rel_dist <- get_relative_distance(tolower(preprocessed_text),
                                      tolower(fuzzy_match_synonym))
    if (rel_dist < 0.8) {
      fuzzy_match_synonym <- ""
    }
    return(fuzzy_match_synonym)
  }
  
  return("")
}

get_match <- function(preprocessed_text, reference_table) {
  
  preprocessed_text <- trimws(preprocessed_text)
  
  match_perfect <- find_detected_match(preprocessed_text, reference_table)
  
  if (nzchar(match_perfect)) {
    return(match_perfect)
  } 
  
 
  #match_detect <-  find_detected_match(preprocessed_text, reference_table) 
  #
  #if (nzchar(match_detect)) {
  #  return(match_detect)
  #}
  
  match_fuzzy <-  find_fuzzy_match(preprocessed_text, reference_table) 
  
  if (nzchar(match_fuzzy)) {
    return(match_fuzzy)
  }
  
  return("")
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

