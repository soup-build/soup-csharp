@echo off
SETLOCAL
SET RootDir=%~dp0

soup run ..\soup\code\generate-test\ -args %RootDir%\code\run-tests.wren %RootDir%\out\Wren\Local\CSharp\0.15.2\J_HqSstV55vlb-x6RWC_hLRFRDU\script\Bundles.sml
if %ERRORLEVEL% NEQ  0 exit /B %ERRORLEVEL%

soup run ..\soup\code\generate-test\ -args %RootDir%\code\run-nuget-tests.wren %RootDir%\out\Wren\Local\CSharp\0.15.2\J_HqSstV55vlb-x6RWC_hLRFRDU\script\Bundles.sml
if %ERRORLEVEL% NEQ  0 exit /B %ERRORLEVEL%