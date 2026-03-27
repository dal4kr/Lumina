param(
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion,

    [string]$SolutionPath = "",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release"
)

if (-not $PSScriptRoot -or [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

if ([string]::IsNullOrWhiteSpace($SolutionPath)) {
    $SolutionPath = Join-Path $PSScriptRoot "Lumina.sln"
}

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SolutionPath)) {
    throw "Solution file not found: $SolutionPath"
}

$resolvedSolutionPath = (Resolve-Path $SolutionPath).Path

Write-Host "Building solution: $resolvedSolutionPath"
Write-Host "Configuration: $Configuration"
Write-Host "PackageVersion: $PackageVersion"

dotnet build `
    --configuration $Configuration `
    $resolvedSolutionPath `
    -p:PackageVersion=$PackageVersion `
    -p:MinVerSkip=true

if ($LASTEXITCODE -ne 0) {
    throw "dotnet build failed with exit code $LASTEXITCODE"
}

Write-Host "Build completed successfully."
