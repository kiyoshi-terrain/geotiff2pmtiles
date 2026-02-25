# geotiff2pmtiles

GeoTIFF を PMTiles (WebP タイル) に変換するツール。
鉄道斜面点検で使用する赤色立体地図等の地図タイル生成に特化。

## 🌐 Web版（ブラウザで即使用可）

**https://kiyoshi-terrain.github.io/geotiff2pmtiles/**

インストール不要。ブラウザでGeoTIFFをドラッグ＆ドロップするだけで PMTiles に変換できます。
- 複数ファイル・フォルダ一括変換対応
- CRS自動検出（平面直角座標系 I〜XIX）
- gdal3.js (WASM) でブラウザ内完結

---

## 🖥️ CLI版

## セットアップ (macOS)

```bash
git clone <repo-url>
cd geotiff2pmtiles
bash setup.sh
```

`setup.sh` が以下をインストール・確認します:
- GDAL (`brew install gdal`)
- pmtiles CLI (`brew install pmtiles`)
- WebP サポートの確認
- 設定ファイルのコピー

### PATH の設定

```bash
echo 'export PATH="/path/to/geotiff2pmtiles/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 使い方

### 単一ファイル変換

```bash
# 系番号を指定（四国 = 系IV）
geotiff2pmtiles --zone IV slope_map.tif

# EPSG コードを直接指定
geotiff2pmtiles --srs 6672 slope_map.tif

# CRS 情報が埋め込まれている場合は自動検出
geotiff2pmtiles slope_map.tif

# 出力先を指定
geotiff2pmtiles --zone IV slope_map.tif ./output/
```

### フォルダ一括変換

```bash
# フォルダ内の全 .tif を変換
geotiff2pmtiles --zone IV ./input_tifs/

# 出力先を分ける
geotiff2pmtiles --zone IV ./input_tifs/ ./pmtiles_output/
```

### オプション

```
-s, --srs EPSG       ソースEPSGコード (例: 6672)
-z, --zone ZONE      平面直角座標系の系番号 (例: IV, 4)
-q, --quality NUM    WebP品質 1-100 (デフォルト: 85)
-n, --nodata VALUE   透過にするピクセル値 (デフォルト: "255 255 255")
-k, --keep           中間ファイルを残す
-v, --verbose        GDAL出力を表示
-d, --dry-run        実行せず内容を表示
-h, --help           ヘルプ表示
```

### 実行例

```
$ geotiff2pmtiles --zone IV 04GE763.tif

[INFO]  変換開始
  入力: 04GE763.tif
  CRS:  系IV (四国) (EPSG:6672)
  品質: WebP q=85
  出力: ./

[1/4] リプロジェクション (EPSG:6672 → EPSG:3857) ...
[2/4] MBTiles 変換 (WebP q=85) ...
[3/4] オーバービュー生成 (2 4 8 16 32 64) ...
[4/4] PMTiles 変換 ...

[OK]    04GE763.pmtiles 完成!
     入力: 34M → 出力: 1.8M (12秒)
     場所: ./04GE763.pmtiles
```

## 平面直角座標系 (JGD2011) 対応表

| 系番号 | EPSG | 地域 | 系番号 | EPSG | 地域 |
|--------|------|------|--------|------|------|
| I | 6669 | 長崎 | X | 6678 | 青森 |
| II | 6670 | 福岡 | XI | 6679 | 札幌 |
| III | 6671 | 山口 | XII | 6680 | 北見 |
| IV | 6672 | 四国 | XIII | 6681 | 帯広 |
| V | 6673 | 広島 | XIV | 6682 | 離島 |
| VI | 6674 | 大阪 | XV | 6683 | 離島 |
| VII | 6675 | 金沢 | XVI | 6684 | 離島 |
| VIII | 6676 | 新潟 | XVII | 6685 | 離島 |
| IX | 6677 | 東京 | XVIII-XIX | 6686-6687 | 離島 |

系番号はローマ数字 (`IV`) でもアラビア数字 (`4`) でも指定できます。

## デフォルト設定

`~/.geotiff2pmtiles.conf` でデフォルト値を設定できます:

```bash
# デフォルトの系番号（チーム共通設定として便利）
DEFAULT_ZONE=IV

# WebP 品質
DEFAULT_QUALITY=85

# ノーデータ値（白枠除去）
DEFAULT_NODATA="255 255 255"
```

`setup.sh` 実行時にテンプレートが `~/.geotiff2pmtiles.conf` にコピーされます。

## 変換パイプライン

内部では以下の4ステップを実行しています:

1. **gdalwarp** — 座標系変換 (平面直角 → Web Mercator) + 透過処理
2. **gdal_translate** — MBTiles 化 (WebP タイル)
3. **gdaladdo** — オーバービュー生成 (ズームレベル対応)
4. **pmtiles convert** — PMTiles アーカイブ化

## トラブルシューティング

### "GDAL に WebP サポートがありません"
```bash
brew reinstall gdal
```

### "EPSG コードを自動検出できませんでした"
ファイルに CRS 情報が埋め込まれていません。`--zone` または `--srs` を指定してください:
```bash
geotiff2pmtiles --zone IV input.tif
```

### 白枠が残る
デフォルトは白 (`"255 255 255"`) を透過にします。黒枠の場合:
```bash
geotiff2pmtiles --nodata "0 0 0" --zone IV input.tif
```

### 変換が遅い
大きなファイル (>500MB) の場合、`--verbose` で進捗を確認:
```bash
geotiff2pmtiles --verbose --zone IV large_file.tif
```

## ライセンス

MIT
