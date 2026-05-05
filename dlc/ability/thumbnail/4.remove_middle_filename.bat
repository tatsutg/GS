@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
set "InputFile=final_list.txt"
set "OutputFile=final_list_clean.txt"
:: ---------------------

if exist "%OutputFile%" del "%OutputFile%"

:: Loop through the file splitting by "="
:: tokens=1 means the first part (DA numbers) -> %%a
:: tokens=2 means the second part (Filename) -> %%b (We ignore this!)
:: tokens=* means everything else (Description) -> %%c

for /f "tokens=1,2* delims==" %%a in (%InputFile%) do (
    :: Rebuild the line using only the first and last parts
    echo %%a=%%c>> "%OutputFile%"
)

echo Done! Created %OutputFile%
pause