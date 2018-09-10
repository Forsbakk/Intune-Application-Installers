# Samle AutoPilot-info

**Mappestruktur**
 - *Microsoft AutoPilot*
 -- *CSVs*
 -- *Get-WindowsAutoPilotInfo.ps1*
 -- *Merge-AutoPilotInfo.ps1*

#### Microsoft Deployment Toolkit
Vi ruller ut Windows 10 Education 1803 til eksisterende maskiner. (Tidligere domene-maskiner)  
Vi har laget en applikasjon i MDT vi kaller **Get-AutoPilotInfo**.  
Den kjører kommandoen ```powershell.exe -Executionpolicy Bypass -Command "& { . .\Get-WindowsAutoPilotInfo.ps1; Add-AutoPilot } ``` og har "Working Directory" ```.\Applications\Microsoft AutoPilot```

Da lages en CSV per maskin i mappa *"CSVs"*. Vi kjører så scriptet *"Merge-AutoPilotInfo.ps1"* manuelt for å samle alle maskinene i en fil som heter *"AutoPilot.csv"*.  
Denne kan lastes rett opp til **AutoPilot**