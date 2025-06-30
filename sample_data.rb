# Sample data that would be seeded to demonstrate the issue review functionality

sample_issues = [
  {
    id: 1,
    title: "開発基盤セットアップ",
    description: "Git リポジトリ初期化、Docker-Compose（dev & prod）、VS Code 推奨設定などの開発環境を構築し、Rails API + Vite React のローカル開発環境を整備する。",
    status: "resolved",
    priority: "high",
    issue_type: "development",
    assigned_to: "Developer",
    reporter: "Project Manager",
    acceptance_criteria: "docker compose up で Rails API ＋ Vite React がローカル起動し、「Hello」画面が確認できる状態を実現する。",
    metadata: {
      "phase" => 1,
      "estimated_hours" => 8
    },
    created_at: "2025-06-27",
    can_be_reviewed: false,
    reviews_count: 2
  },
  {
    id: 2,
    title: "認証・ロール制御",
    description: "Devise（社員番号＋PW）実装、Session-Cookie 認証、Pundit で employee と manager の権限制御を実装する。",
    status: "in_progress",
    priority: "high", 
    issue_type: "feature",
    assigned_to: "Developer",
    reporter: "Project Manager",
    acceptance_criteria: "manager だけ /admin/* へアクセス可能、employee は打刻 API のみ利用可能な認証・認可システムを構築する。",
    metadata: {
      "phase" => 2,
      "estimated_hours" => 12
    },
    created_at: "2025-06-27",
    can_be_reviewed: true,
    reviews_count: 1
  },
  {
    id: 3,
    title: "打刻 & 勤怠集計",
    description: "punches API（IN / OUT / BREAK）、15 分切り捨てロジック、月次集計エンドポイント、打刻画面 (React) を実装する。",
    status: "open",
    priority: "medium",
    issue_type: "feature",
    assigned_to: "Developer", 
    reporter: "Project Manager",
    acceptance_criteria: "出退勤ボタン → API → DB 保存 ➜ /api/attendance?month= が昼・夜・深夜別実働分を返すシステムを構築する。",
    metadata: {
      "phase" => 3,
      "estimated_hours" => 16
    },
    created_at: "2025-06-27",
    can_be_reviewed: false,
    reviews_count: 0
  }
]

sample_reviews = [
  {
    id: 1,
    issue_id: 1,
    comment: "開発環境のセットアップが完了しました。Docker環境で正常にRails APIとReactフロントエンドが起動することを確認。CORS設定も適切に動作しています。",
    status: "approved",
    reviewer_name: "Tech Lead",
    rating: 5,
    created_at: "2025-06-27"
  },
  {
    id: 2,
    issue_id: 1,
    comment: "セットアップ手順が明確で、READMEの内容も充実しています。本番用のDockerfileについても最適化が適切に行われています。",
    status: "approved",
    reviewer_name: "Senior Developer", 
    rating: 4,
    created_at: "2025-06-27"
  },
  {
    id: 3,
    issue_id: 2,
    comment: "認証機能の基本実装は完了していますが、ロール制御の部分でいくつかの改善点があります。Punditポリシーの実装をもう少し詳細に行う必要があります。",
    status: "needs_changes",
    reviewer_name: "Security Reviewer",
    rating: 3,
    created_at: "2025-06-27"
  }
]

puts "📊 Sample Data Summary"
puts "=" * 40
puts "Issues: #{sample_issues.length}"
puts "Reviews: #{sample_reviews.length}"
puts "\n📋 Issues:"
sample_issues.each do |issue|
  puts "• #{issue[:title]} (#{issue[:status]}) - #{issue[:reviews_count]} reviews"
end

puts "\n💬 Reviews:"
sample_reviews.each do |review|
  issue_title = sample_issues.find { |i| i[:id] == review[:issue_id] }[:title]
  puts "• #{review[:reviewer_name]}: #{review[:status]} for '#{issue_title}'"
end

puts "\n✅ Sample data structure validated!"