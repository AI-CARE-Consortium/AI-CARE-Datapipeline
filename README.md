# AI-CARE Data Pipeline
A pipeline to transfer ZfKD data across cancer registries into a standardized format.
## Further information and citation
If you want to know more, have a look at our [preprint](https://doi.org/10.2139/ssrn.5722854). If you use this data pipeline in your work, please cite it in the following way:
```
@article{germer2025harmonizing,
  title = {Harmonizing Regional Cancer Registry Data to Facilitate Germany-Wide Epidemiological Analyses},
  author = {Germer, Sebastian and Sauerberg, Markus and Johanns, Ole and Rudolph, Christiane and Gundler, Christopher and Meisegeier, Stefan and Abnaof, Khalid and Kim-Wanner, Soo-Zin
            and Krauß, Anna and Langholz, Manuela and Luttmann, Sabine and Rath, Natalie and Rausch, Katharina and Katalinic, Alexander and {AI-CARE Working Group} 
            and Handels, Heinz and Nennecke, Alice and Kusche, Henrik},
  date = {2025},
  journaltitle = {SSRN},
  doi = {10.2139/ssrn.5722854}
}
```

## Principle
The data pipeline first translates the data set from XML to csv tables via multiple, thematically structured, XQueries.
Starting from those csv files, the data is compared to reference data. Improper values are either deleted from the output data set or transformed to fitting values with regard to the reference data.
The reference data used in this pipeline is based upon common reference data from the ZFKD, the XML-scheme from the clinical ZfKD-Lieferdatensatz or preliminarily self-designed reference data gathered within AI-CARE.

## Usage
The data pipeline can be executed as an image in docker / podman  or by running the scripts individually after installing R and BaseX.

### Docker / Podman
#### Building the image
Building the image requires Docker or a compatible alternative. The container is build by executing `docker build -t aicare_datenpipeline:latest .`. If you want to skip the comparison to reference lists, you can replace the last line in the Dockerfile with `ENTRYPOINT ["Rscript", "Rahmenskript.R", "--skiptransformation"]` before building the image.

#### Executing the pipeline
The pipeline requires two (or three) explicit endpoints:

1. *INPUT*: A directory with the raw xml file(s) in the standard files of the ZfKD
2. (*INTERMEDIATE*: Optional: A directory which will contain raw csv files which are not yet standartized)
3. *OUTPUT*: A directory which will contain the standartized csv files as output.

Afterwards, the container could be run with `docker run --rm --mount type=bind,source=*INPUT*,target=/Rohdaten --mount type=bind,source=*OUTPUT*,target=/Ausgabedaten (--mount type=bind,source=*INTERMEDIATE*,target=/Eingabedaten) aicare_datenpipeline:latest`.

### Executing the R- and BaseX-scripts individually
#### Setup
Install R and BaseX on your machine and start both applications to finish their setups. Download the folders and scripts provided here and place the XML-file in the format of the ZfKD-reporting data set in the input directory (Rohdaten). 

#### Executing the pipeline via scripts
Open R and define the folder containing the scripts as the working directory (`setwd()`). Execute the R-script called "Framework.R" which will initiate the data processing via BaseX and the other R-scripts.

## Background information
### Reference data
The reference data should be provided in csv-tables. For reference data of the type "Reference" or "Set (Menge)", the csv-table should be comma-separated with the valid expressions in the first column.
### Reference data allignment methods
The pipeline utilizes different approaches to compare the data of interest to the reference data. 
#### Reference:
The entries in the data of interest are compared to the list of permitted entries given by the reference data. For certain variables a transformation of the data of interest is performed in order to align these values to the reference data. The reference tables for this method carry the list of permitted values in their first column. 
#### Set (Menge): 
The entries consist of concatenated expressions. Each element is compared individually to the reference data. For certain variables a transformation of the data of interest is performed in order to align these values to the reference data. The reference tables for this method carry the list of permitted values in their first column.
#### Numeric: 
The entries in this variable are expected to be numeric values. The data is compared with the permitted range of values including the upper and lower limit values, given by the reference data. The reference tables for this method carry the lower limit in their first row and the upper limit in their second.
#### Date: 
The entries in this variable are expected to be dates. The data is compared with permitted range of values including the upper and lower limit, given by the reference data. The reference tables for this method carry the earliest date in the first row and the latest in the second. The years are given in the first column, the months in the second and the days in the third.
#### Individual: 
The entries in these variables are IDs and other values that are defined by the delivering source registry for which no common reference data exists. These values are not compared to any reference data.
### The log file 
The log file (Halde) contains information about values in the datasets that do not adhere to the reference lists. 
For each value, the following information are present in the log:
- patid: Patient-ID given in the XML from the registry.
- tumoricd10: ICD10-code of primary diagnosis of this tumor or diagnoses from this patient.
- register: Registry code given in the XML.
- table: Name of the csv-table from the not-adhering value.
- variable: Name of this variable from the not-adhering value.
- auspraegung: Name of the not adhering value.
- status: Category of transformation, either "mapped" or "deleted".

For the registry-internal quality control, this log file exists in its complete extent.
For different other applications, such as the pure management of flawed values in the log file, multiple variants with a reduced number of colums is produced.

## License
This work is licensed under MIT License.
