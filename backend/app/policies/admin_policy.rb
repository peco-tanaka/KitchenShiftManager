# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy

  # 全ての権限は`manager`のみが持つ

  # 管理画面全体へのアクセス権限: 管理者のみ
  def access?
    user&.manager?
  end

  def index?
    user&.manager?
  end

  def show?
    user&.manager?
  end

  def create?
    user&.manager?
  end

  def update?
    user&.manager?
  end

  def destroy?
    user&.manager?
  end

  # 従業員管理権限
  def manage_employees?
    user&.manager?
  end

  # 勤怠データ管理権限
  def manage_attendance?
    user&.manager?
  end

  # レポート生成権限
  def generate_reports?
    user&.manager?
  end

  # Excel出力権限
  def export_excel?
    user&.manager?
  end

  # システム設定権限
  def system_settings?
    user&.manager?
  end

  # Scopeクラス: 権限に基づくデータフィルタリング
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.manager?
        scope.all
      else
        scope.none
      end
    end
  end
end
