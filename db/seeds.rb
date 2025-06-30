# Create sample issues based on the project phases

# Issue #1 - Development Foundation Setup (as per the project requirements)
issue1 = Issue.create!(
  title: "開発基盤セットアップ",
  description: "Git リポジトリ初期化、Docker-Compose（dev & prod）、VS Code 推奨設定などの開発環境を構築し、Rails API + Vite React のローカル開発環境を整備する。",
  status: "resolved",
  priority: "high",
  issue_type: "development",
  assigned_to: "Developer",
  reporter: "Project Manager",
  acceptance_criteria: "docker compose up で Rails API ＋ Vite React がローカル起動し、「Hello」画面が確認できる状態を実現する。",
  metadata: {
    "phase": 1,
    "estimated_hours": 8
  }
)

# Issue #2 - Authentication & Role Control
issue2 = Issue.create!(
  title: "認証・ロール制御",
  description: "Devise（社員番号＋PW）実装、Session-Cookie 認証、Pundit で employee と manager の権限制御を実装する。",
  status: "in_progress", 
  priority: "high",
  issue_type: "feature",
  assigned_to: "Developer",
  reporter: "Project Manager",
  acceptance_criteria: "manager だけ /admin/* へアクセス可能、employee は打刻 API のみ利用可能な認証・認可システムを構築する。",
  metadata: {
    "phase": 2,
    "estimated_hours": 12
  }
)

# Issue #3 - Time Tracking & Attendance
issue3 = Issue.create!(
  title: "打刻 & 勤怠集計",
  description: "punches API（IN / OUT / BREAK）、15 分切り捨てロジック、月次集計エンドポイント、打刻画面 (React) を実装する。",
  status: "open",
  priority: "medium",
  issue_type: "feature", 
  assigned_to: "Developer",
  reporter: "Project Manager",
  acceptance_criteria: "出退勤ボタン → API → DB 保存 ➜ /api/attendance?month= が昼・夜・深夜別実働分を返すシステムを構築する。",
  metadata: {
    "phase": 3,
    "estimated_hours": 16
  }
)

# Sample reviews for the completed issue
Review.create!(
  issue: issue1,
  comment: "開発環境のセットアップが完了しました。Docker環境で正常にRails APIとReactフロントエンドが起動することを確認。CORS設定も適切に動作しています。",
  status: "approved",
  reviewer_name: "Tech Lead",
  rating: 5
)

Review.create!(
  issue: issue1,
  comment: "セットアップ手順が明確で、READMEの内容も充実しています。本番用のDockerfileについても最適化が適切に行われています。",
  status: "approved", 
  reviewer_name: "Senior Developer",
  rating: 4
)

# Review for in-progress issue
Review.create!(
  issue: issue2,
  comment: "認証機能の基本実装は完了していますが、ロール制御の部分でいくつかの改善点があります。Punditポリシーの実装をもう少し詳細に行う必要があります。",
  status: "needs_changes",
  reviewer_name: "Security Reviewer",
  rating: 3
)

puts "Created #{Issue.count} issues and #{Review.count} reviews"