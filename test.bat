@echo off
setlocal enabledelayedexpansion
for /l %%i in (0, 1, 99) do (
    set "number=000%%i"
    set "number=!number:~-4!"
    set "inputFile=./in/!number!.txt"
    set "outputFile=./out/!number!.txt"
    echo Processing !inputFile!
    ruby main.rb < !inputFile! > !outputFile!
)
endlocal
