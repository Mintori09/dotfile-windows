# Alias
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias rc Invoke-RoboCopy

Import-Module -Name Terminal-Icons

# PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# PSFzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'



function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}


oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/amro.omp.json" | Invoke-Expression

function komorebi {
    komorebic stop
    komorebic start --whkd
}


New-Alias vi nvim
New-Alias new New-Item

function Startup {
    Start-Process "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
}

function sd {
    start .
}

function NewExcel {
    param (
        [string]$FileName = "newexcel"  
    )
    $currentDirectory = Get-Location
    $fullPath = Join-Path -Path $currentDirectory -ChildPath "$FileName.xlsx"
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $workbook = $excel.Workbooks.Add()
    try {
        $workbook.SaveAs($fullPath)
    }
    catch {
        Write-Error "Không thể lưu file: $_"
    }
    return $workbook
}


function gcif {
    param (
        [string]$Filter,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Filter "*$Filter*"
}


function Install-Fonts {
    
    $FontFolder = Get-Location

    
    $FontList = Get-ChildItem -Path $FontFolder -Include ('*.fon', '*.otf', '*.ttc', '*.ttf') -Recurse

    foreach ($Font in $FontList) {
        Write-Host "Cài đặt phông chữ -" $Font.BaseName
        Copy-Item $Font.FullName "C:\Windows\Fonts" -Force

        
        New-ItemProperty -Name $Font.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType String -Value $Font.Name -Force
    }

    Write-Host "Cài đặt phông chữ hoàn tất." -ForegroundColor Green
}


function Extract-With7Zip {
    param (
        [string]$archivePath,
        [string]$extractPath = (Get-Location).Path,
        [switch]$All
    )

    $sevenZipPath = "C:\Program Files\7-Zip\7z.exe"

    if (-not (Test-Path -Path $sevenZipPath)) {
        Write-Error "7-Zip không được cài đặt hoặc không tìm thấy tại đường dẫn: $sevenZipPath"
        return
    }

    if ($All) {
        # Lấy tất cả các tệp ZIP và RAR trong thư mục hiện tại
        $archiveFiles = Get-ChildItem -Path (Get-Location) -Filter *.zip -Recurse
        $archiveFiles += Get-ChildItem -Path (Get-Location) -Filter *.rar -Recurse

        if ($archiveFiles.Count -eq 0) {
            Write-Host "Không có tệp ZIP hoặc RAR nào trong thư mục hiện tại."
            return
        }

        foreach ($file in $archiveFiles) {
            $currentExtractPath = Join-Path -Path $extractPath -ChildPath ($file.BaseName)
            if (-not (Test-Path -Path $currentExtractPath)) {
                New-Item -ItemType Directory -Path $currentExtractPath | Out-Null
            }

            Write-Host "Giải nén tệp: $($file.FullName) vào $currentExtractPath"
            Start-Process -FilePath $sevenZipPath -ArgumentList "x -y -o`"$currentExtractPath`" `"$($file.FullName)`"" -NoNewWindow -Wait
        }

        Write-Host "Hoàn tất giải nén tất cả các tệp ZIP và RAR."
    }
    else {
        if (-not (Test-Path -Path $archivePath)) {
            Write-Error "Tệp nén không tồn tại tại đường dẫn: $archivePath"
            return
        }

        Write-Host "Giải nén tệp: $archivePath vào $extractPath"
        Start-Process -FilePath $sevenZipPath -ArgumentList "x -y -o`"$extractPath`" `"$archivePath`"" -NoNewWindow -Wait
        Write-Host "Giải nén hoàn tất."
    }
}

function ky {
    komorebi && yasb
}
