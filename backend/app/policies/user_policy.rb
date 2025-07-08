# frozen_string_literal: true

class UserPolicy < ApplicationPolicy

  # 全ての権限は`manager`のみが持ち、`employee`は打刻のみ可能とする

  def index?
    user&.manager?
  end

  def show?
    user&.manager?
  end

  def create?
    user&.manager?
  end

  def new?
    create?
  end

  def update?
    user&.manager?
  end

  def edit?
    update?
  end

  def destroy?
    user&.manager?
  end

  # Scopeクラス: 権限に基づくデータフィルタリング
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.manager?
        # 管理者は全てのユーザーにアクセス可能
        scope.all
      else
        # employeeは一切のユーザーデータにアクセス不可
        scope.none
      end
    end
  end

  private

  # 本人確認メソッド（現在は使用しないが、将来の拡張のため残す）
  def owner?
    record == user
  end
end
