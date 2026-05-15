# Intro ####
# In diesem Projekt sollen die Daten der teilnehmenden Krebsregister inhaltlich vereinheitlicht werden.
# Rohdaten sind die XML der klinischen Lieferdatensaetze der beteiligten Register an das ZfKD.
# Eingabedaten sind die csv Tabellen, die aus den gelieferten ZfKD-XML Dateien durch BaseX Xqueries umgewandelt worden sind (im Rahmen dieses Skriptes aufgerufen).
# Ausgabedaten sind csv-Tabellen die der Form der Eingabedaten entsprechen, allerdings inhaltlich an gemeinsame Standards angepasst worden sind.
# Es werden Referenztabellen zur Hilfe genommen, die eine Uebersicht zugelassener Werte Pro Variable enthalten.

# This project tries to harmonize the data from participating clinical cancer registries.
# ZFKD_DIRECTORY contains the raw data, the XML formatted dataset for the clinical reporting of cancer registries to the center for cancer registry data in Germany.
# CSV_DIRECTORY contains the csv tabular representation of the formerly mentioned xml, queried by XQueries in BaseX
# The output are csv tables comparable to the input tables. Their data has been checked against common reference tables 
# and non conform data entries are either deleted or transformed.
# The reference tables provide an overview of permitted values per variable.

# Initialisierung: ####
working_dir <- getwd()
ZFKD_DIRECTORY <- paste0(working_dir, "/Rohdaten")
CSV_DIRECTORY <- paste0(working_dir, "/Eingabedaten")
OUTPUT_DIRECTORY <- paste0(working_dir, "/Ausgabedaten")
args <- commandArgs(trailingOnly=TRUE)
if (length(args) == 0) {
  SKIP_TRANSFORMATION <- FALSE
} else if (args[1] == "--skiptransformation") {
  SKIP_TRANSFORMATION <- TRUE
} else {
  print("Ignored unknown command line argument.")
}

# Clean if the "Eingabedatenfolder" is externally linked"
if (file.exists(CSV_DIRECTORY) && file.info(CSV_DIRECTORY)$isdir) {
  unlink(paste0(CSV_DIRECTORY, "/", "*"), recursive = TRUE)
} else {
  dir.create(CSV_DIRECTORY)
}
if (file.exists(OUTPUT_DIRECTORY) && file.info(OUTPUT_DIRECTORY)$isdir) {
  unlink(paste0(OUTPUT_DIRECTORY, "/", "*"), recursive = TRUE)
} else {
  dir.create(OUTPUT_DIRECTORY)
}


# Check if the input folder exists
if (!file.exists(ZFKD_DIRECTORY) || !file.info(ZFKD_DIRECTORY)$isdir) {
  stop(paste0("Error: The folder '", ZFKD_DIRECTORY, "' does not exist."))
}

# Check if the output folder exists
if (!file.exists(OUTPUT_DIRECTORY) || !file.info(OUTPUT_DIRECTORY)$isdir) {
  stop(paste0("Error: The folder '", OUTPUT_DIRECTORY, "' does not exist."))
}

# Get a list of files in the folder
xml_files <- list.files(ZFKD_DIRECTORY, pattern = "\\.xml$", full.names = TRUE)

# Check if there are any XML files in the folder
if (length(xml_files) == 0) {
  stop("Error: No XML files found in input directory.")
}

query_files <- list.files("./Queries", pattern = "\\.xq$", full.names = TRUE)

# Iterate through each XML file
for (xml_file in xml_files) {
  base_file_name <- tools::file_path_sans_ext(basename(xml_file))

  for (query_file in query_files) {
    # Extract the filename without extension
    file_name <- tools::file_path_sans_ext(basename(query_file))

    # Split the filename by underscore
    parts <- strsplit(file_name, "_")[[1]]

    # Check if there are at least two parts
    if (length(parts) < 2) {
      warning(paste("Warnung: Query", file_name, "enthaelt keinen Unterstrich und wird ignoriert."))
      next
    }

    output_file <- paste0(CSV_DIRECTORY, "/", base_file_name, "_", paste(tolower(parts[-1]), collapse = "-"), ".csv")
    
    system(paste0('basex -b in="', xml_file, '" -b out="', output_file, '" "', query_file,'"'), ignore.stdout=FALSE, ignore.stderr=FALSE)
  }
}
# check if there are already generated csv files in the zfkd directory, which can be copied to the csv directory
csv_files <- list.files(ZFKD_DIRECTORY, pattern = "\\.csv", full.names = TRUE)
lapply(csv_files, function(x) file.copy(x, paste0(CSV_DIRECTORY, "/", basename(x))))

# Erstelle eine Liste der beitragenden Register anhand der vorhandenen Datentabellen (Schema der Daten: register_patient.csv, strsplit nach "_" und Auswahl des ersten Abschnitts [1])
# List all registries by the names of the data tables (naming scheme follows: registry_table.csv e.g. kkn_patient.csv or hkr_tumor.csv)
eingabe_liste <- unlist(list.files(paste0(CSV_DIRECTORY,"/")))
register_liste <- NA
for (objekt in 1:length(eingabe_liste)) {
  register_liste[objekt] <- unlist(strsplit(eingabe_liste[objekt],split="_"))[1]
}
register_liste <- unique(register_liste) # Reduzierung der Liste der Register auf einzigartige Angaben (aus "kkn,kkn,kkn,hkr,hkr,hkr,zfkd,zfkd,zfkd" wird "kkn,hkr,zfkd")
 

# Creation of table for not processable data
halde <- matrix(ncol = 7, nrow = 1, data = NA)
halde[,1] <- as.character(halde[,1])
halde[,2] <- as.character(halde[,2])
halde[,3] <- as.character(halde[,3])
halde[,4] <- as.character(halde[,4])
halde[,5] <- as.character(halde[,5])
halde[,6] <- as.character(halde[,6])
halde[,7] <- as.character(halde[,7])
colnames(halde) <- c("patid","tumoricd10","register","table","variable","auspraegung","status")

write.csv(halde, file = paste0(OUTPUT_DIRECTORY,"/halde.csv"),row.names = FALSE)
# Ausfuehren des Referenztabellen-Skriptes zum Einlesen der Referenztabellen in R und Erstellung der Zuweisungstabelle (Variable <-> Referenztabelle <-> Methode etc.)
# Run the reference data script to read in the provided reference data and associate them to the variables (variable <-> reference data <-> alignment method used)
source("./Create_Reference_Lists.R", echo = FALSE)
# Ausfuehren der Datenverarbeitenden Skripte. Es wird durch die Registerspezifischen Tabellen gelooped (register in register_liste).
# Pro Register werden die Daten mit dem Einleseskript in R eingelesen (siehe einlese_skript).
# Anschliessend werden die in den Datentabellen enthaltenen Werte mit den Referenztabellen abgeglichen (Transformationsskript und ggf. ueberfuehrungsskript).
# Run the data transformation scripts. The scripts are looped through the registry specific data (register in register_liste).
# For each registry the data is read into R via "einlese_skript".
# Afterwards, the data of this registry is aligned to the reference data ((Transformationsskript and ueberfuehrungsskript, if started within Transformationsskript)
for (register in register_liste) {
  print(register)
  # Load csvs from registry
  source("./Read_In.R", echo = FALSE)
  # Transformation of the registry data with the reference tables
  source("./Transform.R", echo = FALSE)
}
# Das Ergebnis der Datenverarbeitung wird in einem R-Objekt lokal abgespeichert um ggf. spaeter drauf zugreifen zu koennen.
# The results of the transformation are saved locally to an R-object to allow for easy access.
saveRDS(datensatz_transformiert,paste0(OUTPUT_DIRECTORY,"/datensatz_transformiert.rds"))
# Erstellung des Ordners "Gesamt" fuer die Kombination der Register-Daten in gemeinsame Datensaetze.
# Creation of the folder "Gesamt" for the complete and combined data of multiple registries in one data set.
if(!file.exists(paste0(OUTPUT_DIRECTORY,"/gesamt"))){
  dir.create(paste0(OUTPUT_DIRECTORY,"/gesamt"))
}


# Combine csvs over multiple registry datasets

for (query in c("patient","fe","modul_mamma","op","strahlentherapie","systemtherapie","tumor")) {
  #print(query)
  print(list.files(paste0(OUTPUT_DIRECTORY,"/"),pattern = query,recursive = FALSE))
  document_list <- list.files(paste0(OUTPUT_DIRECTORY,"/"),pattern = query,recursive = FALSE)
  document.vector <- rep(NA, length(document_list))
  #use only csvs that are not empty
  for (document in c(1:length(document_list))) {
    document.vector[document] <- isTRUE(file.size(paste0(OUTPUT_DIRECTORY, "/", document_list[document])) > 32)
  }
  print(document.vector)
  document_list <- document_list[document.vector]
  if (length(document_list) > 0) {
    temp.gesamt <- read.csv(paste0(OUTPUT_DIRECTORY, "/", document_list[1]))
  }

  if (length(document_list) > 1) {
    for (variable in 2:length(document_list)) {
      temp.neu <- read.csv(paste0(OUTPUT_DIRECTORY, "/", document_list[variable]))
      temp.gesamt <- rbind(temp.gesamt,temp.neu)
    }
  }
  write.csv(temp.gesamt,paste0(OUTPUT_DIRECTORY,"/gesamt/",query,".csv"),row.names = FALSE)
}


# Put the files into seperate folders ####
files <- list.files(OUTPUT_DIRECTORY, full.names = TRUE)
for (file in files) {

  # Extract the filename without extension
  file_name <- tools::file_path_sans_ext(basename(file))

  # Split the filename by underscore and check if the filename has at least two parts
  parts <- strsplit(file_name, "_")[[1]]
  if (length(parts) < 3) {
    next
  }

  # Create subfolder name and new file name
  subfolder <- parts[2]
  tmp_file_name <- paste(tail(parts, -2), collapse = "_")
  new_file_name <- paste0(substr(tmp_file_name, 6, nchar(tmp_file_name)) , ".csv")

  # Create subfolder if it doesn't exist
  subfolder_path <- file.path(OUTPUT_DIRECTORY, subfolder)
  if (!file.exists(subfolder_path)) {
    dir.create(subfolder_path)
  }

  # Construct the new file path, rename and move the file to the subfolder
  new_file_path <- file.path(subfolder_path, new_file_name)
  file.rename(file, new_file_path)
}


# Split data for entity
tumor.daten <- read.csv(paste0(OUTPUT_DIRECTORY,"/gesamt/tumor.csv"))
tumor.unique <- tumor.daten[,colnames(tumor.daten)%in%c("Primaertumor_ICD","Register_ID","Register_ID_FK","Patient_ID_FK","Patient_ID","Tumor_ID","Tumor_ID_FK")]
tumor.unique <- tumor.unique[,sort(colnames(tumor.unique))]
entitaeten <-  c("C34","C50","C73","C8") # Auf realen Daten sind das die Sortierer fuer die Entitaeten, im Testdatensatz nicht enthalten
for (entit in entitaeten) {
  if(!file.exists(paste0(OUTPUT_DIRECTORY,"/gesamt/",entit))) {
    dir.create(paste0(OUTPUT_DIRECTORY,"/gesamt/",entit))
  }
}

for (entit in entitaeten) {
  print(entit)
  # print(tumor.unique[grep(pattern = entit,x = tumor.unique$Primaertumor_ICD),])
  if (nrow(tumor.unique[grep(pattern = entit,x = tumor.unique$Primaertumor_ICD),]) > 0) {
    ident.temp <- tumor.unique[grep(pattern = entit,x = tumor.unique$Primaertumor_ICD),!c(colnames(tumor.unique) %in% c("Primaertumor_ICD"))]
    ident.temp <- ident.temp[,sort(colnames(ident.temp))]
    for (query in c("patient","fe","modul_mamma","op","strahlentherapie","systemtherapie","tumor")) {
      temp.daten <- read.csv(paste0(OUTPUT_DIRECTORY,"/gesamt/",query,".csv"))
      if(!all(is.na(temp.daten))) {
        spalten.temp.daten <- sort(colnames(temp.daten)[which(colnames(temp.daten) %in% c("Register_ID","Register_ID_FK","Patient_ID","Patient_ID_FK","Tumor_ID","Tumor_ID_FK"))])
        spalten.ident.temp <- c("Patient_ID_FK","Register_ID_FK","Tumor_ID")[1:length(spalten.temp.daten)]
        temp.merge <- merge(x = temp.daten, y = ident.temp, by.x = spalten.temp.daten, by.y =spalten.ident.temp)
        temp.merge <- unique(temp.merge[,c(colnames(temp.merge)%in%colnames(temp.daten))])
        write.csv(temp.merge, file = (paste0(OUTPUT_DIRECTORY,"/gesamt/",entit,"/", entit, "_",query,".csv")),row.names = FALSE)
      }
    }
  }
}

if (requireNamespace("stringr", quietly = TRUE) & !SKIP_TRANSFORMATION) {
  # run the script for substances
  source("./Substance_Script.R", echo = FALSE)
}

if (requireNamespace("rmarkdown", quietly = TRUE)) {
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    
    rmarkdown::render("Report.Rmd", knit_root_dir = getwd())
    file.copy("Report.html", "Ausgabedaten/Report.html", overwrite = TRUE)
    if (requireNamespace("tinytex", quietly = TRUE)) {
      tinytex::install_tinytex(bundle = 'TinyTeX')
      rmarkdown::render("Report_en.Rmd", knit_root_dir = getwd())
      
      file.copy("Report_en.pdf", "Ausgabedaten/Report_en.pdf", overwrite = TRUE)
    }
    

  }
}

