# AI-CARE XQueries
These Scripts are used to create CSV files based on a [oBDS-RKI](https://plattform65c.atlassian.net/wiki/spaces/P6/overview?homepageId=7143482) XML file. They were done as part of the AI-CARE project.   
## Workflow
### Using Docker
See https://git.opendfki.de/ai-care-working-group/ap2/aicare-datapipeline

### Using PowerShell
- Install [BaseX](https://files.basex.org/releases/10.7/BaseX107.exe)

- Edit the variables in the BatchScript.ps1 depending on your local enviroment
    - $XMLPath: Path to your XML file
    - $CSVFolder: Path to the Folder where the results will be stored
- Depending on your PowerShell Execution Policy, unblock the Script using 
  `Unblock-File -Path .\BatchScript.ps1` in your PowerShell
- Execute the Script with `.\BatchScript.ps1`


