Clear-Host

function Show-Message {
    param (
        [string]$Text,
        [string]$Color = "Green"
    )
    Write-Host $Text -ForegroundColor $Color
}

function Login {
    Show-Message "`n[LOGIN] Inicia sesion en SSC`n" "Cyan"
    $ssc = Read-Host "Ingresa la URL de SSC"
    $username = Read-Host "Ingresa tu username"
    $password = Read-Host "Ingresa tu contrasena (se ocultara)" -AsSecureString
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    fcli ssc session login --url $ssc -u $username -p $plainPassword -c M1crofocus.
    Write-Host ""
}

function Show-Apps {
    Show-Message "`nAplicaciones en Software Security Center:`n" "Green"
    fcli ssc app list -o json
    Write-Host ""
}

function Show-AppVersions {
    Show-Message "`nVersiones de aplicaciones en Software Security Center:`n" "Green"
    fcli ssc appversion list -o json
    Write-Host ""
}

function Run-SAST {
    Show-Message "`nStatic Application Security Testing`n" "Green"
    $project = Read-Host "Ingresa la ruta de tu proyecto (.zip)"
    $app = Read-Host "Ingresa el nombre de la aplicacion (SSC)"
    $version = Read-Host "Ingresa la version de $app (SSC)"
    fcli sc-sast scan start -v 23.2 -f $project --publish-to "$app`:$version" --store x
    fcli sc-sast scan wait-for ::x::jobToken
    Write-Host ""
}

function Package-Project {
    Show-Message "`nEmpaquetar Proyecto`n" "Green"
    $path = Read-Host "Ingresa la ruta completa del proyecto"
    Set-Location $path
    $binary = Read-Host "Ingresa el nombre del binario (.zip)"
    
    Write-Host "Selecciona la herramienta de build:"
    Write-Host "1. Maven"
    Write-Host "2. Gradle"
    Write-Host "3. MSBuild"
    Write-Host "4. Ninguno"
    $choice = Read-Host "Opcion (1-4)"

    switch ($choice) {
        "1" { scancentral package -bt mvn -bf pom.xml -o $binary }
        "2" { scancentral package -bt gradle -bf build.gradle -o $binary }
        "3" { scancentral package -bt msbuild -bf my.sln -o $binary }
        "4" { scancentral package -bt none -o $binary }
        default { Show-Message "Opcion invalida" "Red" }
    }
    Write-Host ""
}

function Package-OSS {
    Show-Message "`nEmpaquetar Proyecto para OSS`n" "Green"
    $path = Read-Host "Ingresa la ruta completa del proyecto"
    Set-Location $path
    $binary = Read-Host "Ingresa el nombre del binario (.zip)"
    scancentral package -bt none -oss -o $binary
}

function Show-Menu {
    do {
        Write-Host "`nSelecciona una opcion:"
        Write-Host "1. Ver aplicaciones"
        Write-Host "2. Ver versiones de aplicaciones"
        Write-Host "3. Ejecutar escaneo SAST"
        Write-Host "4. Empaquetar proyecto"
        Write-Host "5. Empaquetar OSS"
        Write-Host "6. Salir"
        $opt = Read-Host "Opcion"

        switch ($opt) {
            "1" { Show-Apps }
            "2" { Show-AppVersions }
            "3" { Run-SAST }
            "4" { Package-Project }
            "5" { Package-OSS }
            "6" { return }
            default { Show-Message "Opcion invalida" "Red" }
        }
    } while ($true)
}

Login
Show-Menu