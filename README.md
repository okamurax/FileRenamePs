# FileRenamePs

ファイル名の長さ制限に対応するバッチリネームツール（PowerShell）。

## 機能

- **ファイル名 255バイト制限**（Linux NAS / ext4 / XFS / Btrfs 向け）: UTF-8バイト数で計測し、超過分を末尾から切り詰め
- **フルパス 260文字制限**（Windows MAX_PATH 向け）: ディレクトリパス＋ファイル名の文字数で計測し、超過分を切り詰め
- 拡張子は常に保持
- UTF-16サロゲートペアの分断を防止
- リネーム前に変更後のファイル名を提示し、Y/N で確認

## 使い方

```powershell
.\FileRename.ps1
```

スクリプト冒頭の設定値を環境に合わせて変更してください：

```powershell
$targetDir = "G:\Dropbox\Collection Movies\Adult\Unknown"  # 対象ディレクトリ
$maxBytes = 255       # ファイル名のバイト上限（Linux NAS用）
$maxPathChars = 260   # フルパスの文字数上限（Windows用）
```
