@echo off
setlocal

set "archive=gunfire-mod.rar"
for %%A in ("%archive%") do set "folder_name=%%~nA"
set "target=%APPDATA%\.minecraft\versions\%folder_name%"

:: Проверка существования архива
if not exist "%archive%" (
    echo Archive %archive% not found!
    pause
    exit /b 1
)

:: Создание целевой директории
if not exist "%target%" mkdir "%target%"

echo Search for a way to unpack the RAR archive...

:: Метод 1: Проверяем наличие WinRAR
set "winrar_path=%ProgramFiles%\WinRAR\WinRAR.exe"
set "winrar_path_x86=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

if exist "%winrar_path%" (
    echo WinRAR is used...
    "%winrar_path%" x -ibck -y "%archive%" "%target%"
    goto :cleanup
)

if exist "%winrar_path_x86%" (
    echo WinRAR (x86) is used...
    "%winrar_path_x86%" x -ibck -y "%archive%" "%target%"
    goto :cleanup
)

:: Метод 2: Проверяем наличие 7-Zip
set "sevenzip_path=%ProgramFiles%\7-Zip\7z.exe"
set "sevenzip_path_x86=%ProgramFiles(x86)%\7-Zip\7z.exe"

if exist "%sevenzip_path%" (
    echo 7-Zip is used...
    "%sevenzip_path%" x "%archive%" -o"%target%" -y
    goto :cleanup
)

if exist "%sevenzip_path_x86%" (
    echo 7-Zip (x86) is used...
    "%sevenzip_path_x86%" x "%archive%" -o"%target%" -y
    goto :cleanup
)

:: Метод 3: Проверяем наличие Bandizip
set "bandizip_path=%ProgramFiles%\Bandizip\Bandizip.exe"
set "bandizip_path_x86=%ProgramFiles(x86)%\Bandizip\Bandizip.exe"

if exist "%bandizip_path%" (
    echo Bandizip is used...
    "%bandizip_path%" x -y "%archive%" -o"%target%"
    goto :cleanup
)

if exist "%bandizip_path_x86%" (
    echo Bandizip (x86) is used...
    "%bandizip_path_x86%" x -y "%archive%" -o"%target%"
    goto :cleanup
)

:: Если архиваторы не найдены
echo.
echo Couldn't find a suitable archiver for unpacking RAR!
echo Install one of the following archivers:
echo - WinRAR
echo - 7-Zip
echo - Bandizip
echo.
echo Or convert the archive to ZIP format.
echo.
pause
exit /b 1

:cleanup
if errorlevel 1 (
    echo Error when unpacking the archive!
    echo Make sure that the archive is intact and that you have write permissions.
    pause
    exit /b 1
)

echo The archive has been successfully unpacked!

:: Удаление исходной папки и скрипта
set "script_path=%~f0"
set "script_dir=%~dp0"
cd /d "%script_dir%"
cd..

:: Создание временного скрипта для удаления
set "temp_script=%TEMP%\cleanup_%random%.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo timeout /t 2 /nobreak ^>nul
echo rmdir /s /q "%script_dir%"
echo del "%%~f0"
) > "%temp_script%"

:: Запуск временного скрипта
start "" /min cmd /c "%temp_script%"

exit