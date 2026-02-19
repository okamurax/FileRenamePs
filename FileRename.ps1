$targetDir = Read-Host "Enter target directory path"
$maxBytes = 255
$maxPathChars = 260

# 260文字超のパスに対応するため \\?\ プレフィックスを使用
$searchPath = "\\?\$targetDir"

Get-ChildItem -LiteralPath $searchPath -Recurse -File | ForEach-Object {
    $name = $_.Name
    $ext = $_.Extension
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($name)
    # \\?\ を除去して実際のパス長を計算
    $dirPath = $_.DirectoryName -replace '^\\\\\?\\', ''
    $bytes = [System.Text.Encoding]::UTF8.GetByteCount($name)

    # ドットファイル（.bridgesort等）はスキップ
    if ($name.StartsWith(".") -and $stem -eq "") { return }

    # フルパス260文字制限（Windows用）- Rename-Itemが失敗しないよう最初にチェック
    while (("$dirPath\$stem$ext").Length -gt $maxPathChars -and $stem.Length -gt 1) {
        if ($stem.Length -ge 2 -and [char]::IsLowSurrogate($stem[$stem.Length - 1])) {
            $stem = $stem.Substring(0, $stem.Length - 2)
        } else {
            $stem = $stem.Substring(0, $stem.Length - 1)
        }
    }

    # 絵文字・特殊文字の削除
    $cleanStem = ""
    for ($i = 0; $i -lt $stem.Length; $i++) {
        $c = $stem[$i]
        if ([char]::IsHighSurrogate($c)) {
            $i++
            continue
        }
        if ([char]::IsLowSurrogate($c)) {
            continue
        }
        $code = [int]$c
        if (($code -ge 0xFE00 -and $code -le 0xFE0F) -or
            ($code -ge 0x200B -and $code -le 0x200F) -or
            $code -eq 0x200D -or $code -eq 0xFEFF -or
            ($code -ge 0x2600 -and $code -le 0x27BF)) {
            continue
        }
        $cleanStem += $c
    }
    $cleanStem = ($cleanStem -replace '\s{2,}', ' ').Trim()
    if ($cleanStem.Length -eq 0) {
        $cleanStem = "renamed"
    }
    $stem = $cleanStem

    # ファイル名255バイト制限（Linux NAS用）
    $extBytes = [System.Text.Encoding]::UTF8.GetByteCount($ext)
    $limit = $maxBytes - $extBytes
    while ([System.Text.Encoding]::UTF8.GetByteCount($stem) -gt $limit -and $stem.Length -gt 1) {
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
        Write-Host "[RENAME] $dirPath\$name"
        Write-Host "      -> $newName  (name: $bytes -> $newBytes bytes, path: $newPathLen chars)"
        $answer = Read-Host "      Rename? (Y/N)"
        if ($answer -eq "Y" -or $answer -eq "y") {
            Rename-Item -LiteralPath $_.FullName -NewName $newName
            Write-Host "      Done."
        } else {
            Write-Host "      Skipped."
        }
    }
}
Read-Host "Press Enter to continue..."
