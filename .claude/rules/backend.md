---
paths:
  - "backend/**"
---

# Backend Rules (Laravel / PHP)

## 技術スタック

- **Framework**: Laravel 12 (PHP 8.2/8.5)
- **Database**: MySQL 8.4 (Docker Sail)
- **Caching/Queue**: Redis
- **Auth**: Laravel Sanctum (Cookie-based API 認証)
- **Code Quality**: PHP Strict Types, PSR-12 (Laravel Pint)
- **Testing**: PHPUnit (Unit / Feature Tests)

## アーキテクチャ指針（CSRパターン）

- **Controller**: 判断しない。リクエストを受取り、Serviceを呼び出し、Resourcesで返却するのみ。3行を超える処理は禁止。
- **Service**: 「業務の意味」を閉じ込める。
  - `QueryService`: 参照系（集計、フィルタリング）
  - `CommandService`: 操作系（作成、更新、削除）
  - `ConfirmService`: 状態遷移（確定処理）等
- **Repository**: 「どう取得・保存するか」のみを担当。Serviceからクエリビルダの詳細を隠蔽する。

## ディレクトリ・ファイル命名規則

- PSR-4 準拠。`ShiftService.php`, `ShiftRepository.php` (PascalCase)

## ベストプラクティス

- **バリデーションは FormRequest に集約**: Controller にバリデーションロジックを書かない。
- **認可は Policy に集約**: `$this->authorize()` または `Gate::authorize()` を Controller の冒頭で呼び出す。インライン if 文での認可禁止。
- **N+1 クエリ禁止**: リレーション取得時は必ず `with()` で Eager Loading する。
- **DB::transaction() の徹底**: 複数テーブルを更新する処理は必ずトランザクションで囲む。
- **API Resource を必ず経由**: モデルインスタンスや配列を直接 JSON レスポンスとして返さない。
- **Strict Types 宣言**: すべての PHP ファイルの先頭に `declare(strict_types=1);` を記述する。
- **生 SQL 禁止**: `DB::select()` 等で生クエリを使う場合はプレースホルダーバインドを必ず使用する。

## セキュリティ（バックエンド）

- **認可チェックの徹底**: 認証（ログイン済みか）と認可（そのリソースにアクセスできるか）は別物。両方を Controller で確認する。
- **レスポンスの情報漏洩防止**: エラーレスポンスに stack trace・DB エラー・内部パス等を含めない。
- **フロントエンドの入力値を信頼しない**: バックエンドで必ず再バリデーションする。

## アンチパターン

- **Controller内の肥大化**: ビジネスロジックを直接書かない。
- **Service内でのEloquent型依存**: `where`句などの詳細クエリをServiceに書かず、Repositoryに任せる。

## 認証フロー (Sanctum)

- **認証シーケンス**: ログイン前に `GET /sanctum/csrf-cookie` を呼び出し、次に `POST /api/login` を叩くフローを厳守。
- **認証状況判定**: ユーザー情報取得APIが成功するかどうかでログイン状態を判定。
