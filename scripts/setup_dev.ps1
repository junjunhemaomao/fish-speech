Param(
    [string]$venvPath = ".venv",
    [switch]$skipFrontend
)

Write-Host "Creating virtual environment at $venvPath"
python -m venv $venvPath

Write-Host "Activating virtual environment"
if (Test-Path "$venvPath\Scripts\Activate.ps1") {
    & "$venvPath\Scripts\Activate.ps1"
} else {
    Write-Warning "Activation script not found; please activate the venv manually: $venvPath\\Scripts\\Activate.ps1"
}

Write-Host "Upgrading pip and installing python packages"
python -m pip install --upgrade pip setuptools wheel

try {
    pip install -e ".[stable]"
} catch {
    Write-Warning "Editable install failed; attempting fallback to requirements.txt"
    if (Test-Path "requirements.txt") { pip install -r requirements.txt }
}

if (Test-Path "docs/requirements.txt") {
    Write-Host "Installing docs requirements"
    pip install -r docs/requirements.txt
}

if (-not $skipFrontend) {
    if (Test-Path "awesome_webui/package.json") {
        Write-Host "Installing frontend dependencies (awesome_webui)"
        Push-Location awesome_webui
        if (Get-Command npm -ErrorAction SilentlyContinue) { npm install } 
        elseif (Get-Command pnpm -ErrorAction SilentlyContinue) { pnpm install }
        else { Write-Warning "npm/pnpm not found; please install Node.js and run 'npm install' inside awesome_webui" }
        Pop-Location
    }
}

Write-Host "Setup finished. To activate the venv in a new shell run:`n    .\\$venvPath\\Scripts\\Activate.ps1"
