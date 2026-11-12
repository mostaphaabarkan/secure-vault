$ErrorActionPreference = "Stop"
$dirs = @(
    "infra/bootstrap",
    "infra/bootstrap-prod",
    "infra/envs/dev",
    "infra/envs/prod"
)
foreach ($dir in $dirs) {
    terraform "-chdir=$dir" validate
    if ($LASTEXITCODE -ne 0) { exit 1 }
}