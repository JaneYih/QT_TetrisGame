@echo off

::@cd /d d:
::@cd /d D:\Qt\Qt5.13.2\5.13.2\msvc2017\bin

set /p SourcePath=�����롾EXE·������
set SourcePath="%SourcePath%\

set /p ExeName=�����롾EXE���ơ���
set ExeName=%ExeName%"

echo=

set cmdString=D:\Qt\Qt5.13.2\5.13.2\msvc2017\bin\windeployqt.exe %SourcePath%%ExeName% -qmldir "D:\Qt\Qt5.13.2\5.13.2\msvc2017\qml" --release
echo �������£�
echo %cmdString%
echo=
echo=
echo ��ʼִ��...
%cmdString%

pause
#exit