@echo off

:: This command reads "filename_numbered.txt"
:: /V = Invert match (keep lines that do NOT match)
:: /E = End of line (checks the very last character)
:: "=" = The character we are looking for

findstr /V /E "=" "filename_numbered.txt" > "final_list.txt"

echo Done! Saved valid lines to final_list.txt
pause