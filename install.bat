@echo off
setlocal enabledelayedexpansion

set "target_base=%APPDATA%\.minecraft\versions\"

:: Поиск всех архивных файлов в текущей папке
set count=0
set "file_list="
echo Scanning for archive files...

for %%A in (*.rar *.zip *.7z *.tar *.gz) do (
    set /a count+=1
    set "file_!count!=%%A"
    set "file_list=!file_list!!count!. %%A\n"
    echo !count!. %%A
)

if !count!==0 (
    echo No archive files found in current directory!
    pause
    exit /b 1
)

echo.
echo Found !count! archive file(s)
echo.

:: Запрос выбора архивов
set /p "selection=Enter the numbers of archives to install (separated by spaces, or 'all' for all): "

:: Обработка выбора "all"
if /i "!selection!"=="all" (
    set "selected_files="
    for /l %%i in (1,1,!count!) do (
        set "selected_files=!selected_files! !file_%%i!"
    )
) else (
    :: Обработка выбранных номеров
    set "selected_files="
    for %%a in (!selection!) do (
        if defined file_%%a (
            set "selected_files=!selected_files! !file_%%a!"
        ) else (
            echo Warning: File number %%a is not valid.
        )
    )
)

if "!selected_files!"=="" (
    echo No valid files selected.
    pause
    exit /b 1
)

echo.
echo Selected files: !selected_files!
echo.

:: Поиск архиваторов
set "archiver_found=0"
set "archiver_cmd="
set "archiver_name="

:: Проверяем наличие WinRAR
set "winrar_path=%ProgramFiles%\WinRAR\WinRAR.exe"
set "winrar_path_x86=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"

if exist "!winrar_path!" (
    set "archiver_found=1"
    set "archiver_cmd=!winrar_path! x -ibck -y"
    set "archiver_name=WinRAR"
    goto :process_files
)

if exist "!winrar_path_x86!" (
    set "archiver_found=1"
    set "archiver_cmd=!winrar_path_x86! x -ibck -y"
    set "archiver_name=WinRAR"
    goto :process_files
)

:: Проверяем наличие 7-Zip
set "sevenzip_path=%ProgramFiles%\7-Zip\7z.exe"
set "sevenzip_path_x86=%ProgramFiles(x86)%\7-Zip\7z.exe"

if exist "!sevenzip_path!" (
    set "archiver_found=1"
    set "archiver_cmd=!sevenzip_path! x -y"
    set "archiver_name=7-Zip"
    goto :process_files
)

if exist "!sevenzip_path_x86!" (
    set "archiver_found=1"
    set "archiver_cmd=!sevenzip_path_x86! x -y"
    set "archiver_name=7-Zip"
    goto :process_files
)

:: Проверяем наличие Bandizip
set "bandizip_path=%ProgramFiles%\Bandizip\Bandizip.exe"
set "bandizip_path_x86=%ProgramFiles(x86)%\Bandizip\Bandizip.exe"

if exist "!bandizip_path!" (
    set "archiver_found=1"
    set "archiver_cmd=!bandizip_path! x -y"
    set "archiver_name=Bandizip"
    goto :process_files
)

if exist "!bandizip_path_x86!" (
    set "archiver_found=1"
    set "archiver_cmd=!bandizip_path_x86! x -y"
    set "archiver_name=Bandizip"
    goto :process_files
)

:: Если архиваторы не найдены
echo.
echo Couldn't find a suitable archiver!
echo Install one of the following archivers:
echo - WinRAR
echo - 7-Zip
echo - Bandizip
echo.
pause
exit /b 1

:process_files
echo Using !archiver_name! for extraction...
echo.

:: Обработка каждого выбранного файла
for %%F in (!selected_files!) do (
    echo Processing: %%F
    
    :: Извлекаем имя файла без расширения для папки
    for %%A in ("%%F") do set "folder_name=%%~nA"
    set "target=!target_base!!folder_name!\"
    
    echo Creating directory: !target!
    if not exist "!target!" mkdir "!target!"
    
    :: Распаковка в зависимости от архиватора
    if "!archiver_name!"=="WinRAR" (
        "!archiver_cmd!" "%%F" "!target!"
    ) else if "!archiver_name!"=="7-Zip" (
        "!archiver_cmd!" "%%F" -o"!target!"
    ) else if "!archiver_name!"=="Bandizip" (
        "!archiver_cmd!" "%%F" -o"!target!"
    )
    
    if errorlevel 1 (
        echo Error extracting: %%F
    ) else (
        echo Successfully extracted: %%F
    )
    echo.
)

echo All selected archives have been processed!

:: Удаление исходной папки и скрипта
set "script_path=%~f0"
set "script_dir=%~dp0"
cd /d "!script_dir!"
cd..

:: Создание временного скрипта для удаления
set "temp_script=%TEMP%\cleanup_%random%.bat"
(
echo @echo off
echo chcp 65001 ^>nul
echo timeout /t 2 /nobreak ^>nul
echo echo Cleaning up installation files...
echo rmdir /s /q "!script_dir!"
echo del "%%~f0"
) > "!temp_script!"

:: Запуск временного скрипта
echo Installation complete. Cleaning up...
start "" /min cmd /c "!temp_script!"

exit