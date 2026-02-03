## backend/compose.yaml の解説

このドキュメントはリポジトリ内の `backend/compose.yaml`（Docker Compose 定義）の各項目を日本語で簡潔に解説します。

**目的**: 開発環境のサービス構成（Laravel アプリ、MySQL 等）を理解・編集しやすくするための参照資料。

---

**Top-level**:
- **services**: 起動するコンテナ群を定義します。各サービス名（例: `laravel.test`, `mysql`）に対してビルド設定、イメージ、ポート、環境変数、ボリュームなどを指定します。
- **networks**: サービス間のネットワーク設定。ここでは `sail` というブリッジネットワークを使用しています。
- **volumes**: ホストとコンテナ間で永続化するデータ領域の定義（例: `sail-mysql`）。

---

**services: laravel.test**
- **build**:
  - `context`: ビルド時のコンテキスト（ここでは `./docker/8.5`）。Dockerfile と関連ファイルがある場所です。
  - `dockerfile`: 使用する Dockerfile の名前（`Dockerfile`）。
  - `args`: ビルド引数。例: `WWWGROUP` を渡してコンテナ内のファイルグループIDを揃えます。
- **image**: ビルド後に付けるイメージ名（例: `sail-8.5/app`）。開発用に固定イメージ名を付けています。
- **extra_hosts**: コンテナの /etc/hosts にエントリを追加します。`host.docker.internal:host-gateway` によってコンテナからホストへ名前解決できます。
- **ports**: ホストとコンテナのポートマッピング。環境変数展開が使われており、デフォルトは `80`（アプリ）と `5173`（Vite）です。例: `${APP_PORT:-80}:80`。
- **environment**: コンテナ内で利用する環境変数一覧。
  - `WWWUSER` / `WWWGROUP`：ホストと UID/GID を合わせるために使用されることが多いです（ファイルパーミッション対策）。
  - `LARAVEL_SAIL`: Sail 特有のフラグ（1 等）
  - `XDEBUG_MODE` / `XDEBUG_CONFIG`: Xdebug の設定（デバッグ時に使用）。
  - `IGNITION_LOCAL_SITES_PATH`: Ignition（Laravel のエラーページ）がプロジェクトルートを見つけるためのパス。
- **volumes**: ホストとコンテナのファイル共有。ここではプロジェクトルート `.` をコンテナの `/var/www/html` にマウントして、コードを即時反映させます。
- **networks**: このサービスが参加するネットワーク（`sail`）。
- **depends_on**: 起動順序のヒント。`mysql` が先に起動している必要があることを示します（注意: 完全な「準備完了」までは保証しません。アプリ側で接続リトライが必要です）。

---

**services: mysql**
- **image**: 利用する MySQL イメージ（ここでは `mysql:8.4`）。バージョン固定により挙動を安定させます。
- **ports**: ホスト側に公開するポート（`${FORWARD_DB_PORT:-3306}:3306`）。ローカル開発で外部ツールから接続したい場合に使用します。
- **environment**: コンテナ起動時に設定される MySQL の環境変数。
  - `MYSQL_ROOT_PASSWORD`: MySQL の root パスワード（必須）。
  - `MYSQL_ROOT_HOST`: root の接続許可ホスト（`%` はどこからでも接続可）。
  - `MYSQL_DATABASE`: 初期作成されるデータベース名。
  - `MYSQL_USER` / `MYSQL_PASSWORD`: アプリ用のデータベースユーザーとパスワード。
  - `MYSQL_ALLOW_EMPTY_PASSWORD`: 空パスワードを許可するか（開発専用で注意）。
  - `MYSQL_EXTRA_OPTIONS`: 追加オプションを渡すためのプレースホルダ。
- **volumes**:
  - `sail-mysql:/var/lib/mysql`: データ永続化用ボリューム（ローカルに保持される）。
  - `./docker/mysql/create-testing-database.sh:/docker-entrypoint-initdb.d/10-create-testing-database.sh`: 初回起動時に実行される初期化スクリプトをマウントしています（テスト用 DB 作成など）。
- **networks**: `sail` ネットワーク参加。
- **healthcheck**: コンテナのヘルスチェック設定（起動後に接続可能かを確認）。
  - `test`: 実行コマンド（例: `mysqladmin ping -p${DB_PASSWORD}`）。
  - `retries`: 再試行回数。
  - `timeout`: 各チェックのタイムアウト。

---

**networks: sail**
- `driver: bridge`: ブリッジネットワークを使用。ホストと隔離されたコンテナ間通信を提供します。

---

**volumes: sail-mysql**
- `driver: local`: ホスト上にデータを永続化するローカルボリューム。コンテナ削除後もデータが残ります。

---

**注意点 / ベストプラクティス**
- 環境変数は `.env` で管理し、機密情報はリポジトリに含めないこと。
- `MYSQL_ALLOW_EMPTY_PASSWORD` のような設定は本番環境では無効にすること。
- `depends_on` は起動順のみ制御し、サービスが「受け付け可能」になったかは保証しないため、アプリ側で接続のリトライ実装を行ってください。
- ホスト側のポート競合に注意（既に 3306 や 80 が使われている場合、環境変数で別ポートへ変更してください）。

---

必要があれば、ドキュメントの追加修正（各環境変数の例やトラブルシュート手順）を追記します。変更してほしい箇所を教えてください。
