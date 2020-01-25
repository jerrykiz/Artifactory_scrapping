:::::::::::::::::::::::::::::::::
:: Variables for python script ::
:::::::::::::::::::::::::::::::::

@echo off
set python_exe=
:: EXAMPLE=> C:\Users\User\AppData\Local\Programs\Python\Python38\python.exe

set user=
:: EXAMPLE=> username

set api=
:: EXAMPLE=> AKCp5e3KvXkna3LA9LHop7zyV8x...

set repo=
:: EXAMPLE=> my-artifactory-repository

set path=
:: EXAMPLE=> ABCD/CCD/GYTY-T1.1B_Work

:: In %filename% _VERSION_ is the placeholder of the latest version
set file_name=
:: EXAMPLE=> GYTY-T1.1B_Work_VERSION_+blob.zip

:: Optional local logfile path for the logfile
set logpath=

:: Optional download path
:: If not specified, a search will only occur and the name of the file will be returned
set download_path=
:: EXAMPLE=> C:\Users\User\Desktop\

::::::::::::::::::::::::::::::::
:: Variables for copying file ::
::::::::::::::::::::::::::::::::
set copy_file=true
:: EXAMPLE=> true OR false (bool)

set file_to_copy=
:: EXAMPLE=> file.txt

set in_which_dir_to_copy=
:: EXAMPLE=> C:\Users\User\Desktop\

set create_new_dir_name=
:: EXAMPLE=> new_folder

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::
if "%logpath%"=="" (
  set log_var=
) else (
  set log_var=-l %logpath%
)
:::::::::::::::::::::::::::

:::::::::::::::::::
:: Download file ::
:::::::::::::::::::

if "%download_path%"=="false" (
  goto dontdowloadit
) else (
  goto downloadit
)

:downloadit
%python_exe% get_latest.py -u %user% -a %api% -r %repo% -p %path% -f %file_name% %log_var% -d %download_path%>C:\Users\KZG8FE\Desktop\Output.txt
<C:\Users\KZG8FE\Desktop\Output.txt (
    set /p MYVAR=
)
echo File successfully downloaded from Artifactory!
@echo off
goto copyOrNot
:: End of downloadit

:dontdowloadit
C:\Users\KZG8FE\AppData\Local\Programs\Python\Python38\python.exe C:\Users\KZG8FE\Desktop\SHARED\get_latest.py -u %user% -a %api% -r %repo% -p %path% -f %file_name% %log_var%>C:\Users\KZG8FE\Desktop\Output.txt
<C:\Users\KZG8FE\Desktop\Output.txt (
    set /p MYVAR=
)
@echo on
echo %MYVAR%
@echo off
goto DeleteTemporaryFile
:: End of dontdowloadit

::::::::::::::::::::::::::::::::::::::::
:: Create a new directory if required ::
::::::::::::::::::::::::::::::::::::::::
:createOrNot
if "%create_new_dir_name%"=="" (
  goto copyingFile
) else (
  goto createit
)
:: End of createOrNot

:createit
if exist %in_which_dir_to_copy%\%create_new_dir_name% (
  goto copyingFile
) else (
  mkdir %in_which_dir_to_copy%\%create_new_dir_name%
  goto copyingFile
)
:: End of createit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copy file from downloaded folder to new local folder ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:copyOrNot
if "%copy_file%"=="false" (
  goto DeleteTemporaryFile
) else (
  goto createOrNot
)
:: End of copyOrNot

:copyingFile
cd %MYVAR%
copy %file_to_copy% %in_which_dir_to_copy%\%create_new_dir_name%\%file_to_copy%
echo File successfully copied to specified directory!
goto DeleteTemporaryFile
:: End of copyingFile


:::::::::::::::::::::::::::
:: Delete temporary file ::
:::::::::::::::::::::::::::

:DeleteTemporaryFile
del C:\Users\KZG8FE\Desktop\Output.txt
:: End of DeleteTemporaryFile

:::::::::::::
:: THE END ::
:::::::::::::

:End
