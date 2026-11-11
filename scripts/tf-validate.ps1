$ErrorActionPreference = "Stop"
foreach ($dir in @("infra/bootstrap", "infra/bootstrap-prod")) {
    terraform "-chdir=$dir" validate
    if ($LASTEXITCODE -ne 0) { exit 1 }
}