@echo off
setlocal enabledelayedexpansion

:: --- CONFIGURATION ---
:: Output file name (changed to .csv)
set "OutputFile=filenames.csv"

:: How many characters define the "Group"?
:: "unit_thumbnail_1" = 16 chars
:: + "0001" (The Unit ID) = 4 chars
:: Total = 20 chars.
set "GroupLength=20"
:: ---------------------

:: Clear old file if it exists
if exist "%OutputFile%" del "%OutputFile%"

set "prev_group="
set "line="

:: Loop through all unit_thumbnail PNGs, sorted by name
for /f "delims=" %%F in ('dir /b /on unit_thumbnail_*.png') do (
    set "filename=%%F"
    
    :: Extract the first 20 characters to check if it's the same unit
    set "curr_group=!filename:~0,%GroupLength%!"
    
    :: If the group prefix changed (meaning we found a new Unit ID)
    if "!curr_group!" neq "!prev_group!" (
        
        :: If we have a previous line built, write it to the CSV now
        if defined line (
            echo !line!>> "%OutputFile%"
        )
        
        :: Reset for the new group
        set "prev_group=!curr_group!"
        set "line=%%F"
        
    ) else (
        :: Same group? Add a comma and append the next filename
        set "line=!line!,%%F"
    )
)

:: Write the final line captured after the loop finishes
if defined line echo !line!>> "%OutputFile%"

echo Done! Grouped list saved to %OutputFile%
pause