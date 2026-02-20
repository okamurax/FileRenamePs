# FileRenamePs

ファイル名の長さ制限に対応するバッチリネームツール（PowerShell）。

Windows の MAX_PATH 制限や Linux NAS のファイル名バイト制限に引っかかるファイルを、対話的にリネームします。

## 機能

- **フルパス 260 文字制限**（Windows MAX_PATH）: 文字数ベースで切り詰め
- **ファイル名 255 バイト制限**（Linux NAS / ext4 / XFS / Btrfs）: UTF-8 バイト数で計測し切り詰め
- **絵文字・特殊文字の除去**: サロゲートペア（絵文字等）、ゼロ幅文字、異体字セレクタなどを削除
- 拡張子は常に保持
- UTF-16 サロゲートペアの分断を防止
- 連続する空白を 1 つに圧縮
- ドットファイル（`.bridgesort` 等）はスキップ
- 260 文字超のパスにも `\\?\` プレフィックスで対応
- リネーム前に変更内容を表示し Y/N で確認

## 使い方

### PowerShell から実行

```powershell
.\FileRename.ps1
```

### ダブルクリックで実行

`Run.bat` をダブルクリックすると、ExecutionPolicy を自動でバイパスしてスクリプトを起動します。

### 設定

スクリプト冒頭の変数で上限値を変更できます:

```powershell
$maxBytes = 255       # ファイル名のバイト上限（Linux NAS 用）
$maxPathChars = 260   # フルパスの文字数上限（Windows 用）
```

## 処理順序

1. Windows フルパス 260 文字制限のチェック・切り詰め
2. 絵文字・特殊文字の削除（削除後にファイル名が空になる場合は `renamed` にフォールバック）
3. Linux NAS ファイル名 255 バイト制限のチェック・切り詰め

## 動作例

```
Path:     D:\NAS\Photos
Before:   🎉🎊 とても長いファイル名の写真.jpg (58 bytes)
After:    とても長いファイル名の写真.jpg (40 bytes, path: 42 chars)
Rename? (Y/N): Y
      Done.
```

## 動作環境

- Windows PowerShell 5.1 以降 / PowerShell 7+
