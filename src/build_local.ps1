param(
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion,

    [string]$SolutionPath = "$PSScriptRoot\Lumina.sln",

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [switch]$Push,

    [string]$FeedPath
)

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

if ($Push) {
    if ([string]::IsNullOrWhiteSpace($FeedPath)) {
        throw "When -Push is specified, -FeedPath is required."
    }

    if (-not (Test-Path $FeedPath)) {
        New-Item -ItemType Directory -Path $FeedPath -Force | Out-Null
    }

    $resolvedFeedPath = (Resolve-Path $FeedPath).Path

    $packagePath = "$PSScriptRoot\Lumina\bin\$Configuration\Lumina.$PackageVersion.nupkg"

    if (-not (Test-Path $packagePath)) {
        throw "Package file not found: $packagePath"
    }

    $resolvedPackagePath = (Resolve-Path $packagePath).Path

    Write-Host "Pushing package: $resolvedPackagePath"
    Write-Host "Local feed: $resolvedFeedPath"

    dotnet nuget push $resolvedPackagePath `
        --source $resolvedFeedPath

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet nuget push failed with exit code $LASTEXITCODE"
    }

    Write-Host "Push completed successfully."
}