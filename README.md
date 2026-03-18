# Spresense App Template

Docker + [just](https://github.com/casey/just) を使った Spresense アプリ開発テンプレートです。
Spresense SDK はこのリポジトリの外側に置き、`.env` で参照します。

## 前提条件

- Docker
- [just](https://github.com/casey/just)
- picocom（シリアルモニタ用）
- Python 3（フラッシュ書き込み用）

## Spresense SDK のセットアップ

Spresense SDK を任意の場所にクローンします（このリポジトリの外）：

```sh
git clone --recursive https://github.com/sonydevworld/spresense.git ~/spresense
```

`.env` ファイルを作成し、SDK のパスを設定します：

```sh
echo "SPRESENSE_SDK=/path/to/spresense" > .env
```

## プロジェクト構成

```
.
├── Dockerfile          # ビルド環境
├── Justfile            # タスクランナー
├── Makefile            # 外部appsディレクトリ登録用
├── Make.defs           # 同上
├── .env                # SPRESENSE_SDK パス（git管理外）
└── myapp/
    ├── Kconfig         # menuconfig用の設定定義
    ├── Make.defs       # ビルドシステムへのアプリ登録
    ├── Makefile        # アプリのビルド設定
    └── myapp_main.c    # アプリ本体
```

## 初回セットアップ

```sh
# Dockerイメージをビルド
just build-image
```

## 開発フロー

### 1. 初回 / `just clean` 後

```sh
just config
```

ベースの defconfig (`examples/hello`) を適用します。

### 2. 機能の有効化（PWM・GPIO 等）

```sh
just menuconfig
```

初回は `just config` が自動的に先に実行されます。

### 3. ビルド

```sh
just build
```

### 4. フラッシュ書き込み

```sh
just flash                        # デフォルト: /dev/ttyUSB0
just flash port="/dev/ttyACM0"    # ポート指定
```

### 5. シリアルモニタ

```sh
just monitor                      # デフォルト: /dev/ttyUSB0
just monitor port="/dev/ttyACM0"
```

### クリーン

```sh
just clean  # make distclean（SDK側のビルド成果物をすべて削除）
```

## アプリの追加

新しいアプリを追加する場合は `myapp/` を参考に以下のファイルを用意します：

**`myapp/Kconfig`**
```kconfig
config MYAPP
    tristate "My App"
    default y

if MYAPP

config MYAPP_PROGNAME
    string "Program name"
    default "myapp"

config MYAPP_PRIORITY
    int "My App task priority"
    default 100

config MYAPP_STACKSIZE
    int "My App stack size"
    default DEFAULT_TASK_STACKSIZE

endif
```

**`myapp/Make.defs`**
```makefile
ifneq ($(CONFIG_MYAPP),)
CONFIGURED_APPS += $(APPDIR)/myapp
endif
```

**`myapp/Makefile`**
```makefile
include $(APPDIR)/Make.defs

PROGNAME  = $(CONFIG_MYAPP_PROGNAME)
PRIORITY  = $(CONFIG_MYAPP_PRIORITY)
STACKSIZE = $(CONFIG_MYAPP_STACKSIZE)
MODULE    = $(CONFIG_MYAPP)

MAINSRC = myapp_main.c

include $(APPDIR)/Application.mk
```

## アプリ名の変更

`myapp` を別の名前（例: `cansat`）に変更する場合、以下のファイルをすべて変更する必要があります。

| ファイル | 変更箇所 |
|---|---|
| `myapp/` ディレクトリ | ディレクトリ名自体をリネーム |
| `myapp/Kconfig` | `MYAPP` → `CANSAT`、`"myapp"` → `"cansat"` |
| `myapp/Make.defs` | `CONFIG_MYAPP` → `CONFIG_CANSAT`、`$(APPDIR)/myapp` → `$(APPDIR)/cansat` |
| `myapp/Makefile` | `CONFIG_MYAPP_*` → `CONFIG_CANSAT_*`、`MAINSRC` のファイル名 |
| `myapp/myapp_main.c` | ファイル名と関数名 `myapp_main` → `cansat_main` |

> **注意:** `Make.defs` の `CONFIGURED_APPS += $(APPDIR)/myapp` の行を変更し忘れると、ビルドシステムにアプリが認識されずコマンドとして登録されません。
