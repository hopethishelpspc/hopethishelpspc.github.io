#1. Go to https://www.catalog.update.microsoft.com/Home.aspx
#2. Search for the current month's Servicing Stack Update and Security Monthly Quality Rollup (SMQR) updates
#3. Save the two .msu files to a folder called "KBs" and copy that folder to c:\windows\temp on the target 2012 server.
#4. Review the below commands, replacing the .msu and .cab files with the appropriate names of the files you downloaded and extracted
#5. After you have updated the paths in the below commands, run them

#SSU
#In some rare cases, the SSU update requires a reboot when able
mkdir c:\windows\temp\ExtractSSU;
expand -f:* c:\windows\temp\KBs\SSU_windows8-rt-kb4566426-x64_ed3f2c06d774af0138d4ca3e17b7151cbc5d0fc5.msu c:\windows\temp\ExtractSSU;
dism /online /add-package /packagepath:c:\windows\temp\ExtractSSU\Windows8-RT-KB4566426-x64.cab;

#SMQR
#NOTE: It will ask for a reboot at the end, warning: pressing 'y' will immediately reboot the system.
mkdir c:\windows\temp\ExtractSMQR;
expand -f:* c:\windows\temp\KBs\SMQR_windows8-rt-kb4565537-x64_75b08237ab33956a109201b54fa904a1c0b44bf5.msu c:\windows\temp\ExtractSMQR;
dism /online /add-package /packagepath:c:\windows\temp\ExtractSMQR\Windows8-RT-KB4565537-x64.cab;