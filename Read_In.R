# Datenextraktion
# Liste der Datentabellen, die zum ausgewählten Register gehören, wird erstellt (z.B. kkn_tumor.csv, hkr_patient.csv)
# List all data tables containing the specific registry name as a pattern in their filename.
register.daten <- list.files(path =paste0(CSV_DIRECTORY,"/"),pattern = paste(register,"_*",sep = ""))
#print("hello world")
#print(paste("hello register", register))
# Datentabellen des ausgewählten Registers werden in R geladen (temp.patient, temp.tumor, etc...)
# Read and assign the data tables of the specific registry into R (temp.patient, temp.tumor, etc...)
temp.patient <- matrix(NA)
if (paste0(register,"_patient.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_patient.csv"))$size>0){
        temp.patient <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_patient.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID"="character"), strip.white=TRUE)
    }
}

temp.fe <- matrix(NA)
if (paste0(register,"_folgeereignis.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_folgeereignis.csv"))$size>0){
        temp.fe <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_folgeereignis.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

temp.modul_mamma <- matrix(NA)
if (paste0(register,"_modul-mamma.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_modul-mamma.csv"))$size>0){
        temp.modul_mamma <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_modul-mamma.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

temp.op <- matrix(NA)
if (paste0(register,"_op.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_op.csv"))$size>0){
        temp.op <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_op.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

temp.strahlentherapie <- matrix(NA)
if (paste0(register,"_strahlentherapie.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_strahlentherapie.csv"))$size>0){
        temp.strahlentherapie <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_strahlentherapie.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

temp.systemtherapie <- matrix(NA)
if (paste0(register,"_systemtherapie.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_systemtherapie.csv"))$size>0){
        temp.systemtherapie <- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_systemtherapie.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

temp.tumor <- matrix(NA)
if (paste0(register,"_tumor.csv")%in%register.daten){
    if(file.info(file=paste0(CSV_DIRECTORY,"/",register,"_tumor.csv"))$size>0){
        temp.tumor<- read.csv(file=paste0(CSV_DIRECTORY,"/",register,"_tumor.csv"),stringsAsFactors = FALSE, colClasses=c("Patient_ID_FK"="character"), strip.white=TRUE)
    }
}

# Es wird ein vollständiger Datensatz des ausgewählten Registers generiert (datensatz). Mit "list()" werden die einzelnen Datentabellen kombiniert.
# Combine all data tables from this specific registry to one data set with the "list()" statement.
datensatz <- list(temp.patient,temp.fe,temp.modul_mamma,temp.op,temp.strahlentherapie,temp.systemtherapie,temp.tumor)
names(datensatz) <- c("temp.patient","temp.fe","temp.modul_mamma","temp.op","temp.strahlentherapie","temp.systemtherapie","temp.tumor")
