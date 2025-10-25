仕様書（v0.9）英語学習指導のための専用学習プラットフォーム

最終更新: 2025-10-24（JST）
作成者: ChatGPT（ドラフト）

⸻

1. プロダクト概要
	•	目的: 教師が生徒の課題提出状況を一元管理し、課題ステータスや指導メモを一覧で確認・更新できる学習プラットフォーム。
	•	対象ユーザー: 英語学習を指導する教師 / 学習者（生徒）
	•	提供価値:
	•	教師: 提出状況の俯瞰、添削効率化、指導履歴の可視化
	•	生徒: 何を・いつまでに・どこまで進んだかが明確、フィードバックの蓄積
	•	KPI（例）:
	•	週次の提出率（提出済み/期限対象）
	•	AI添削→教師レビュー完了までの中位所要時間
	•	1生徒あたりの教師メモ記録数/月
	•	期日超過率の低減

⸻

2. 役割と権限
	•	User.role: student(0), teacher(1)
	•	権限マトリクス（要約）

機能	student	teacher
自分の課題閲覧/提出	◯	—
自分のフィードバック閲覧	◯	—
学習メモ（自己メモ）作成	◯	—
生徒一覧/課題一覧の閲覧	—	◯
提出の状態更新（AI/教師）	—	◯
指導メモ（教師向け）作成/編集	—	◯



※ 管理者（admin）は当面なし。必要になればロール追加。

⸻

3. ユースケース & ユーザーストーリー
	•	UC1（教師）: 生徒一覧で「今週の課題」の提出状況を一目で確認 → ステータス別にフィルタ → 未提出へリマインド送信。
	•	UC2（教師）: 提出一覧から AI添削済みをピックアップ → 教師レビュー → フィードバック確定 → 生徒に通知。
	•	UC3（生徒）: ダッシュボードで「今週の課題」を確認 → 提出（テキスト/音声/URL 等） → ステータスが submitted に。
	•	UC4（教師）: 生徒詳細で過去課題のフィードバック/指導メモを時系列で参照 → 次回の指導ポイントをメモ。

⸻

4. 画面一覧（ERB + Tailwind）
	1.	ログイン/登録: Devise（Email/Password）+ Google OAuth（omniauth）
	2.	教師ダッシュボード
	•	KPIカード（提出率、期限超過数、レビュー待ち件数）
	•	フィルタ: 週/クラス/ステータス/課題タイプ
	3.	生徒一覧（教師）
	•	カラム: 生徒名、最新課題、現在ステータス、未読フィードバック有無、最終更新
	4.	提出一覧（教師）
	•	カラム: 生徒、課題、提出日時、ステータス、AIスコア（任意）、レビュー担当、操作（レビュー）
	5.	提出詳細
	•	提出内容（テキスト/音声/ファイル/URL）
	•	ステータス変更、AI結果、教師フィードバック（リッチテキスト）
	•	指導メモ（教師専用、タイムライン）
	6.	課題管理（教師）
	•	課題作成/編集（タイトル、説明、タイプ、公開/非公開、締切）
	7.	生徒ダッシュボード
	•	今週の課題、締切、提出フォーム、フィードバック履歴

⸻

5. 業務フロー / 状態遷移
	•	Submission.status（enum）
	•	not_submitted(0) → submitted(1) → ai_checking(2) → ai_checked(3) → teacher_reviewed(4) → returned(5)
	•	遷移規則（例）
	•	生徒提出で not_submitted→submitted
	•	バックグラウンドAIで submitted→ai_checking→ai_checked
	•	教師レビュー完了で ai_checked→teacher_reviewed
	•	フィードバック公開で teacher_reviewed→returned（生徒が閲覧）
	•	期日超過: active=true の課題で締切 > 現在時刻、未提出をリストアップ

⸻

6. データモデル（ER 概要）

User (id, name, email, role:int, ... devise columns)
Task (id, title, description, task_type:int, active:boolean, due_on:date)
Submission (id, user_id, task_id, status:int, content:text, content_url:string, submitted_at:datetime)
Feedback (id, submission_id, ai_score:int, ai_summary:text, teacher_comment:text, published_at:datetime)
Memo (id, user_id, submission_id:nullable, body:text, visibility:int[teacher_only=0, student_self=1])
Attachment (id, attachable_type, attachable_id, file:string)
Notification (id, user_id, kind:int, payload:jsonb, read_at:datetime)

	•	関連
	•	User has_many :submissions, :memos
	•	Task has_many :submissions
	•	Submission belongs_to :user, :task; has_one :feedback; has_many :attachments, as: :attachable
	•	Feedback belongs_to :submission
	•	Memo belongs_to :user; optional :submission

⸻

7. テーブル定義（抜粋 / Rails想定）
	•	users: name:string, email:string(unique), role:integer(default:0), devise columns, provider:string, uid:string
	•	tasks: title:string, description:text, task_type:integer(default:0), active:boolean(default:true), due_on:date
	•	submissions: user:ref, task:ref, status:int(default:0), content:text, content_url:string, submitted_at:datetime, ai_score:int, ai_summary:text
	•	feedbacks: submission:ref, teacher_comment:text, published_at:datetime
	•	memos: user:ref, submission:ref(null), body:text, visibility:int(default:0)
	•	attachments: attachable:polymorphic, file:string
	•	notifications: user:ref, kind:int, payload:jsonb, read_at:datetime

⸻

8. バリデーション/ビジネスルール
	•	User: email 必須・一意
	•	Task: title 必須, task_type ∈ {diary=0, shadowing=1}
	•	Submission: user & task 必須, status は定義済み enum のみ、content か content_url のいずれか必須
	•	Memo: body 必須、visibility ∈ {teacher_only, student_self}

⸻

9. 認証/認可
	•	Devise: Database Authenticatable, Recoverable, Rememberable, Trackable（任意）
	•	OmniAuth Google: provider=google_oauth2、ドメイン制限（任意）
	•	認可: Pundit または CanCanCan（どちらか）
	•	ポリシー例: Submission は担当教師のみ更新可、学生は自分の提出のみ閲覧/作成可

⸻

10. ルーティング（概略）

root to: "dashboards#show"    # ロールで分岐表示
resources :tasks do
  resources :submissions, only: [:index]
end
resources :submissions, only: [:show, :create, :update] do
  resource :feedback, only: [:show, :create, :update]
  resources :attachments, only: [:create, :destroy]
end
resources :students, only: [:index, :show]   # teacher専用
resources :memos, only: [:create, :update, :destroy]
resources :notifications, only: [:index, :update]
namespace :api do
  resources :submissions, only: [:index]
end


⸻

11. API 仕様（抜粋 / JSON）
	•	GET /api/submissions?status=ai_checked&task_id=
	•	200: [{ id, user: {id,name}, task: {id,title}, status, ai_score, updated_at }]
	•	PATCH /submissions/:id
	•	Request: { status: "teacher_reviewed" }
	•	200: { id, status }
	•	POST /submissions（生徒提出）
	•	{ task_id, content | content_url } → 201: { id, status:"submitted" }

⸻

12. 通知仕様
	•	種別（kind）: deadline_reminder, feedback_published, status_changed
	•	配送チャネル: アプリ内通知（必須）、メール（任意）
	•	トリガ
	•	期限前日 18:00 に deadline_reminder
	•	フィードバック公開時に feedback_published

⸻

13. バックグラウンド処理
	•	ActiveJob + Sidekiq（または Async/Que）
	•	AI添削ジョブ: submitted→ai_checking→ai_checked
	•	締切リマインドジョブ

⸻

14. UI/UX 指針（Tailwind）
	•	主要ページはレスポンシブ（モバイル→タブレット→デスクトップ）
	•	採番バッジでステータス色分け（not_submitted=灰, submitted=青, ai_checked=紫, teacher_reviewed=緑, returned=黄）
	•	一覧は固定ヘッダ/カラムソート/クイックフィルタ
	•	キーボード操作（j/k ナビゲーション任意）

⸻

15. アクセシビリティ/i18n
	•	i18n: ja 既定、en 追加可能
	•	a11y: ランドマーク/ラベル/コントラスト AA 以上、フォームのエラー関連付け

⸻

16. 非機能要件
	•	可用性: 平日 9:00-22:00 想定（将来 24/7）
	•	性能: 教師一覧ページ < 1.5s（P95、1000件表示はサーバページネーション）
	•	セキュリティ: CSRF, XSS, SSRF, 強制ブラウズ対策、添付ファイルの MIME 検証
	•	監査ログ: 重要操作（ステータス変更/公開）を audits に記録

⸻

17. ログ/監視
	•	アプリログ: JSON 構造化（request_id, user_id, action, duration）
	•	エラー監視: Sentry など
	•	指標: 提出率、AI待ち件数、教師レビュー待ち件数

⸻

18. 環境/デプロイ
	•	Docker: web（Rails 8, ERB, Tailwind）, db（PostgreSQL）
	•	ENV（例）
	•	DATABASE_URL, RAILS_MASTER_KEY, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET
	•	起動例: docker compose up -d

⸻

19. テスト方針
	•	RSpec（model/request/system）、FactoryBot、Faker
	•	状態遷移テスト（Submission）
	•	ポリシーテスト（教師/生徒）
	•	System: 主要フロー（提出→AI→レビュー→公開）

⸻

20. リスクと制約
	•	AI添削の外部API依存（レイテンシ/費用）
	•	音声/大容量添付のストレージ戦略（S3 など）
	•	学習データ保護（個人情報/著作権）

⸻

21. 受け入れ基準（MVP）
	1.	教師がダッシュボードで生徒の「今週の課題」提出状況を一覧で確認できる
	2.	生徒が課題を提出でき、状態が submitted になる
	3.	AI添削ジョブが状態を ai_checked に更新できる（ダミーでも可）
	4.	教師がレビューして teacher_reviewed、公開で returned
	5.	指導メモが提出詳細に紐づけて登録/一覧できる

⸻

付録 A: enum 設計（Rails）

class User < ApplicationRecord
  enum :role, { student: 0, teacher: 1 }
end
class Task < ApplicationRecord
  enum :task_type, { diary: 0, shadowing: 1 }
end
class Submission < ApplicationRecord
  enum :status, {
    not_submitted: 0,
    submitted: 1,
    ai_checking: 2,
    ai_checked: 3,
    teacher_reviewed: 4,
    returned: 5
  }
end

付録 B: 画面コンポーネント（例）
	•	ステータスピル: <span class="px-2 py-1 rounded-full text-xs bg-indigo-100 text-indigo-800">AI済</span>
	•	テーブル: sticky header + zebra rows + sort icons

付録 C: ポリシー例（Pundit）

class SubmissionPolicy < ApplicationPolicy
  def show?
    user.teacher? || record.user_id == user.id
  end
  def update?
    user.teacher?
  end
  def create?
    user.student?
  end
end


⸻

本仕様は MVP のドラフトです。要件の追加/変更に応じて随時更新してください。