@echo off
echo ========================================
echo Actualizando repositorio GitHub
echo ========================================
echo.

:: Verificar el estado del repositorio
echo [1/4] Verificando estado del repositorio...
git status
echo.

:: Agregar todos los cambios
echo [2/4] Agregando cambios...
git add .
echo.

:: Hacer commit con mensaje
echo [3/4] Creando commit...
set /p commit_message="Ingresa el mensaje del commit: "
if "%commit_message%"=="" (
    echo No se ingreso mensaje. Usando mensaje por defecto...
    git commit -m "Actualizacion automatica"
) else (
    git commit -m "%commit_message%"
)
echo.

:: Subir cambios al repositorio remoto
echo [4/4] Subiendo cambios a GitHub...
git push origin master
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo Repositorio actualizado exitosamente!
    echo ========================================
) else (
    echo ========================================
    echo Error al actualizar el repositorio
    echo ========================================
)

echo.
pause
