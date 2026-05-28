# ============================================================
#  Claude Statusline — Instalador
#  https://github.com/kevingilarevalo/claude-statusline
# ============================================================

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$repoDir   = $PSScriptRoot
$claudeDir = "$env:USERPROFILE\.claude"
$destScript  = "$claudeDir\statusline-command.sh"
$settingsFile = "$claudeDir\settings.json"

function Write-Step  { param($msg) Write-Host "  $msg" -ForegroundColor Cyan }
function Write-OK    { param($msg) Write-Host "  OK  $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "  --  $msg" -ForegroundColor Yellow }
function Write-Fail  { param($msg) Write-Host "  X   $msg" -ForegroundColor Red }

# ── DESINSTALAR ──────────────────────────────────────────────
if ($Uninstall) {
    Write-Host ""
    Write-Host " Desinstalando Claude Statusline..." -ForegroundColor Magenta

    if (Test-Path $destScript) {
        Remove-Item $destScript -Force
        Write-OK "statusline-command.sh eliminado"
    }

    if (Test-Path $settingsFile) {
        $s = Get-Content $settingsFile -Raw | ConvertFrom-Json
        if ($s.PSObject.Properties.Name -contains "statusLine") {
            $s.PSObject.Properties.Remove("statusLine")
            $s | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
            Write-OK "settings.json restaurado"
        }
    }

    Write-Host ""
    Write-Host " Listo. Reinicia Claude Code para aplicar." -ForegroundColor Magenta
    exit 0
}

# ── INSTALAR ─────────────────────────────────────────────────
Write-Host ""
Write-Host " Claude Statusline — Instalador" -ForegroundColor Magenta
Write-Host " --------------------------------" -ForegroundColor DarkGray
Write-Host ""

# 1. Verificar Claude Code
Write-Step "Verificando Claude Code..."
if (-not (Test-Path $claudeDir)) {
    Write-Fail "No se encontro ~/.claude"
    Write-Host "    Instala Claude Code desde: https://claude.ai/download" -ForegroundColor DarkGray
    exit 1
}
Write-OK "Claude Code encontrado"

# 2. Instalar jq
Write-Step "Verificando jq..."
if (Get-Command jq -ErrorAction SilentlyContinue) {
    Write-OK "jq ya instalado"
} else {
    Write-Warn "jq no encontrado, instalando via winget..."
    winget install jqlang.jq --silent --accept-package-agreements --accept-source-agreements | Out-Null
    Write-OK "jq instalado"
}

# 3. Copiar script
Write-Step "Copiando statusline-command.sh..."
$src = Join-Path $repoDir "statusline-command.sh"
if (-not (Test-Path $src)) {
    Write-Fail "No se encontro statusline-command.sh en $repoDir"
    exit 1
}
Copy-Item $src $destScript -Force
Write-OK "Script copiado a ~/.claude/"

# 4. Actualizar settings.json
Write-Step "Configurando settings.json..."
if (-not (Test-Path $settingsFile)) {
    '{}' | Set-Content $settingsFile -Encoding UTF8
}

$raw = Get-Content $settingsFile -Raw
$s   = $raw | ConvertFrom-Json

$statusLineConfig = [PSCustomObject]@{
    type    = "command"
    command = "bash ~/.claude/statusline-command.sh"
}

if ($s.PSObject.Properties.Name -contains "statusLine") {
    $s.statusLine = $statusLineConfig
} else {
    $s | Add-Member -MemberType NoteProperty -Name "statusLine" -Value $statusLineConfig
}

$s | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
Write-OK "settings.json actualizado"

# ── RESULTADO ────────────────────────────────────────────────
Write-Host ""
Write-Host " Instalacion completa." -ForegroundColor Green
Write-Host ""
Write-Host "  La barra aparece en la parte inferior de Claude Code." -ForegroundColor White
Write-Host "  Verde bajo 60% · Amarillo 60-80% · Rojo sobre 80%"    -ForegroundColor White
Write-Host ""
Write-Host "  Para desinstalar: .\install.ps1 -Uninstall" -ForegroundColor DarkGray
Write-Host ""
