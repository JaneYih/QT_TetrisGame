@echo off

::@cd /d d:
::@cd /d D:\Qt\Qt5.13.2\5.13.2\msvc2017\bin

set /p SourcePath=请输入【EXE路径】：
set SourcePath="%SourcePath%\

set /p ExeName=请输入【EXE名称】：
set ExeName=%ExeName%"

echo=

set cmdString=D:\Qt\Qt5.13.2\5.13.2\msvc2017\bin\windeployqt.exe %SourcePath%%ExeName% -qmldir "D:\Qt\Qt5.13.2\5.13.2\msvc2017\qml" --release
echo 命令如下：
echo %cmdString%
echo=
echo=
echo 开始执行...
%cmdString%

pause
#exit