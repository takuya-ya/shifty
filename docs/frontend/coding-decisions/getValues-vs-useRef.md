# `getValues` vs `useRef` の使い分け

## 対象コード

`frontend/src/features/auth/components/ForgotPasswordForm.tsx`

---

## 判断の背景

パスワード再設定フォームの成功画面に「送信したメールアドレス」を表示する際、当初は React Hook Form の `getValues('email')` を使っていた。

```tsx
// 修正前
<p>{getValues('email')}</p>
```

これを `useRef` に修正した。

```tsx
// 修正後
const submittedEmail = useRef<string>('');

const onSubmit = (data) => {
  submittedEmail.current = data.email; // 送信時に確定
  sendResetLink(data.email);
};

<p>{submittedEmail.current}</p>
```

---

## `getValues` を使わない理由

`getValues` は「フォームの現在値を取得する」APIであり、**送信後に `reset()` が呼ばれると空文字を返す**。

また、「送信確定時の値を表示する」という意図に対して、フォームの現在状態を参照する手段を使うことは目的と手段がずれている。

---

## `useRef` を使う理由

| 観点 | `getValues` | `useRef` |
|---|---|---|
| 値の意味 | フォームの現在値 | 送信時に確定したスナップショット |
| `reset()` 後 | 空になる可能性あり | 影響を受けない |
| 意図の明確さ | △ 目的とずれる | ○ スナップショットであることが明示される |

`useRef` に保存することで：

- 「送信確定時の値」というスナップショットであることがコードから読み取れる
- フォームの状態と完全に切り離されるため、`reset()` の影響を受けない
- コードを読んだ人が即座に意図を理解できる

---

## 適用パターン

「フォーム送信後の画面に、送信時の入力値を表示する」ケース全般に同じ判断を適用する。

```tsx
const submittedXxx = useRef<string>('');

const onSubmit = (data) => {
  submittedXxx.current = data.xxx; // ← 送信時に確定
  mutate(data);
};
```
