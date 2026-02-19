$targetDir = ""
$maxBytes = 255
$maxPathChars = 260

Get-ChildItem -Path $targetDir -Recurse -File | ForEach-Object {
    $name = $_.Name
    $ext = $_.Extension
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($name)
    $dirPath = $_.DirectoryName
    $bytes = [System.Text.Encoding]::UTF8.GetByteCount($name)

    # ファイル名255バイト制限（Linux NAS用）
    if ($bytes -gt $maxBytes) {
        $extBytes = [System.Text.Encoding]::UTF8.GetByteCount($ext)
        $limit = $maxBytes - $extBytes

        while ([System.Text.Encoding]::UTF8.GetByteCount($stem) -gt $limit) {
            if ($stem.Length -ge 2 -and [char]::IsLowSurrogate($stem[$stem.Length - 1])) {
                $stem = $stem.Substring(0, $stem.Length - 2)
            } else {
                $stem = $stem.Substring(0, $stem.Length - 1)
            }
        }
    }

    # フルパス260文字制限（Windows用）
    while (("$dirPath\$stem$ext").Length -gt $maxPathChars) {
        if ($stem.Length -ge 2 -and [char]::IsLowSurrogate($stem[$stem.Length - 1])) {
            $stem = $stem.Substring(0, $stem.Length - 2)
        } else {
            $stem = $stem.Substring(0, $stem.Length - 1)
        }
    }

    $newName = $stem + $ext
    if ($newName -ne $name) {
        $newBytes = [System.Text.Encoding]::UTF8.GetByteCount($newName)
        $newPathLen = "$dirPath\$newName".Length
        Write-Host "[RENAME] $($_.FullName)"
        Write-Host "      -> $newName  (name: $bytes -> $newBytes bytes, path: $newPathLen chars)"
        $answer = Read-Host "      Rename? (Y/N)"
        if ($answer -eq "Y" -or $answer -eq "y") {
            Rename-Item -Path $_.FullName -NewName $newName
            Write-Host "      Done."
        } else {
            Write-Host "      Skipped."
        }
    }
}
Read-Host "Press Enter to continue..."
