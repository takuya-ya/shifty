---
paths:
  - "frontend/**"
---

# Frontend Rules (TypeScript / React)

## 技術スタック

- **Language**: TypeScript (strict mode ON)
- **Framework**: React 19 / Vite
- **Router**: React Router
- **State Management**:
  - **Server State**: TanStack Query (React Query)
  - **Global/UI State**: Zustand (必要に応じて)
  - **Form**: React Hook Form + Zod
- **Styling**: Tailwind CSS / shadcn/ui + Radix UI
- **Utilities**: date-fns (日付操作の標準), dnd-kit (ドラッグ&ドロップ操作)
- **API Client**: fetch API + 独自 wrapper (shared/api)
- **Testing**: Vitest + React Testing Library (Phase2以降)

## アーキテクチャ指針

- **Component**: Atomic Designをベースにしつつ、`shared/components/ui` に汎用パーツ、`features/` 内に機能特化したパーツを配置。
- **State Management**:
  - APIデータはすべて React Query で管理し、`staleTime` などを利用して最適化。
  - 複雑なフォームは React Hook Form + Zod で型安全にバリデーション。
- **Data Flow**: `UI -> Custom Hook -> API Client (fetch wrapper) -> Server`

## ディレクトリ・ファイル命名規則

- Component: `ShiftTable.tsx` (PascalCase) / ディレクトリは `shift-table/` (kebab-case)
- Hook: `useShifts.ts` (camelCase + use prefix)
- Utils: `formatDate.ts` (camelCase)

## ベストプラクティス

- **`any` 禁止**: Discriminated Union / Generics / `unknown` + 型ガードで対応する。
- **Non-null assertion (`!`) 禁止**: 型が nullable の場合は Optional chaining や条件分岐で安全に扱う。
- **Props は interface で明示的に定義**: `React.FC<Props>` ではなく関数の引数に型を付ける形を優先。
- **Custom Hook でロジックを分離**: コンポーネントに直接 API 呼び出しや複雑なロジックを書かない。`use~` hook に切り出す。
- **React Query の一貫した queryKey 設計**: `['shifts', { period, storeId }]` のようにオブジェクト形式で構造化する。
- **エラー状態・ローディング状態を必ず処理**: `isPending` / `isError` を無視して表示ロジックを書かない。
- **アクセシビリティ (a11y)**: ボタンには `aria-label`、フォームには `htmlFor` と `id` の対応、キーボード操作を意識する。
- **早期最適化禁止**: `useMemo` / `useCallback` / `memo` は計測・明確な必要性なしに使わない。

## セキュリティ（フロントエンド）

- **`dangerouslySetInnerHTML` 禁止**: React での XSS を防ぐため使用しない。

## アンチパターン

- **useEffectの濫用**: データフェッチは React Query、イベントハンドラで済む処理に `useEffect` は使わない。
- **anyの禁止**: TypeScript では可能な限り型を定義する。
