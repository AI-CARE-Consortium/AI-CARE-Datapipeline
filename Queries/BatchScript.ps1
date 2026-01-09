# Define input and output paths
$XMLPath = ".\Data\oBDS_v3.0.0.8_RKI_Sample.xml"
$CSVFolder = ".\Tmp"



$BaseXCommand = "-b in=$XMLPath -b out=$CSVFolder"

Start-Process basex -ArgumentList "$BaseXCommand\Patient.csv xquery_Patient.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\Tumor.csv xquery_Tumor.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\Modul_Mamma.csv xquery_Modul_Mamma.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\OP.csv xquery_OP.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\Strahlentherapie.csv xquery_Strahlentherapie.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\Systemtherapie.csv xquery_Systemtherapie.xq" -Wait -NoNewWindow
Start-Process basex -ArgumentList "$BaseXCommand\Folgeereignis.csv xquery_Folgeereignis.xq" -Wait -NoNewWindow
