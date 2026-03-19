param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("common", "efrotas", "erh", "gateway", "frontend")]
    [string]$Service
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$mvn = "C:\Program Files\Maven\apache-maven-3.9.8\bin\mvn.cmd"
$npm = "npm.cmd"

function Get-EnvValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $line = Get-Content $FilePath | Where-Object { $_ -match "^$Key=" } | Select-Object -First 1
    if (-not $line) {
        throw "Variavel '$Key' nao encontrada em '$FilePath'."
    }

    return $line.Split("=", 2)[1]
}

function Set-RemoteFrotasEnv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    $env:SPRING_DATASOURCE_URL = "jdbc:postgresql://srv752535.hstgr.cloud:5432/frotas"
    $env:SPRING_DATASOURCE_USERNAME = "postgres"
    $env:SPRING_DATASOURCE_PASSWORD = $Password
    $env:SPRING_DATASOURCE_HIKARI_JDBC_URL = "jdbc:postgresql://srv752535.hstgr.cloud:5432/frotas"
}

$dbPass = Get-EnvValue -FilePath (Join-Path $root ".env.prod") -Key "POSTGRES_PASSWORD"

switch ($Service) {
    "common" {
        Set-RemoteFrotasEnv -Password $dbPass
        $env:COMMON_SERVER_PORT = "9081"
        $env:EUREKA_SERVER_URL = "http://localhost:9876/eureka"

        Push-Location (Join-Path $root "common")
        try {
            & $mvn spring-boot:run
        } finally {
            Pop-Location
        }
    }

    "efrotas" {
        Set-RemoteFrotasEnv -Password $dbPass
        $env:EFROTAS_SERVER_PORT = "9082"
        $env:EUREKA_SERVER_URL = "http://localhost:9876/eureka"

        Push-Location (Join-Path $root "eFrotas")
        try {
            & $mvn spring-boot:run
        } finally {
            Pop-Location
        }
    }

    "erh" {
        Set-RemoteFrotasEnv -Password $dbPass
        $env:ERH_SERVER_PORT = "9083"
        $env:SPRING_DATASOURCE_ERH_URL = "jdbc:postgresql://srv752535.hstgr.cloud:5432/erh"
        $env:SPRING_DATASOURCE_ERH_USERNAME = "postgres"
        $env:SPRING_DATASOURCE_ERH_PASSWORD = $dbPass
        $env:SPRING_DATASOURCE_ERH_HIKARI_JDBC_URL = "jdbc:postgresql://srv752535.hstgr.cloud:5432/erh"
        $env:EUREKA_SERVER_URL = "http://localhost:9876/eureka"
        $env:ERH_STORAGE_TYPE = "REMOTE"
        $env:FILE_STORAGE_SERVICE_URL = "http://localhost:9085"

        Push-Location (Join-Path $root "eRH-Service")
        try {
            & $mvn spring-boot:run
        } finally {
            Pop-Location
        }
    }

    "gateway" {
        $env:API_GATEWAY_PORT = "9080"
        $env:EUREKA_SERVER_URL = "http://localhost:9876/eureka"
        $env:WS_GATEWAY_ALLOWED_ORIGINS = "http://localhost:9300,http://localhost:3000"

        Push-Location (Join-Path $root "api-gateway")
        try {
            & $mvn spring-boot:run
        } finally {
            Pop-Location
        }
    }

    "frontend" {
        $env:NEXT_PUBLIC_GATEWAY_URL = "http://localhost:9080"
        $env:NEXT_PUBLIC_API_PREFIX = "/api/v1"
        $env:NEXT_PUBLIC_AUTH_PREFIX = "/api/auth"
        $env:NEXT_PUBLIC_FROTAS_PREFIX = "/frotas"
        $env:NEXT_PUBLIC_ERH_PREFIX = "/erh"

        Push-Location (Join-Path $root "frontend-services")
        try {
            & $npm run dev
        } finally {
            Pop-Location
        }
    }
}
