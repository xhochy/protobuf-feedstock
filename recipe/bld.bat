@echo on
setlocal enabledelayedexpansion

md py_toolchain

for /f "tokens=*" %%i in (%RECIPE_DIR%\py_toolchain_win.bzl) do (
    set line=%%i
    set line=!line:PYTHON_EXE=!PYTHON!!
    echo !line! >> %SRC_DIR%\py_toolchain\BUILD
)

cd python

set PROTOC=%LIBRARY_BIN%\protoc

..\bazel build --extra_toolchains=//py_toolchain:py_toolchain //python/dist:binary_wheel
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\protobuf*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\bazel-bin\python\dist') do (
    python -m pip install %%f==%PKG_VERSION%
    if %ERRORLEVEL% neq 0 exit 1
)
