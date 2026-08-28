: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for aiboarding hook scripts.
REM Windows: cmd runs this batch block, finds Git Bash, calls the named script.
REM Unix: bash treats this block as a heredoc no-op and runs the tail below.
REM Usage: run-hook.cmd <script-path-or-name> [args...]
if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)
set "SCRIPT=%~f1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0%~1"
if exist "%ProgramFiles%\Git\bin\bash.exe" (
    "%ProgramFiles%\Git\bin\bash.exe" "%SCRIPT%" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    "%ProgramFiles(x86)%\Git\bin\bash.exe" "%SCRIPT%" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
for %%I in (git.exe) do if exist "%%~dpI..\bin\bash.exe" (
    "%%~dpI..\bin\bash.exe" "%SCRIPT%" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
REM No compatible Git Bash - optional hooks remain silent.
exit /b 0
CMDBLOCK

# Unix: run an explicit script or a named sibling script.
if [ -z "${1:-}" ]; then
  echo "run-hook.cmd: missing script name" >&2
  exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$1"
shift
if [ ! -f "$SCRIPT" ]; then
  SCRIPT="${SCRIPT_DIR}/${SCRIPT}"
fi
exec bash "$SCRIPT" "$@"
