# frozen_string_literal: true

class TimeCardPolicy < ApplicationPolicy

  # 全ての権限は`manager`のみが持ち、`employee`は打刻のみ可能とする

  def index?
    user&.manager?
  end

  def show?
    user&.manager?
  end

  # 作成権限: 管理者と従業員（打刻機能のみ）
  def create?
    user.present? # 認証済みユーザーなら打刻可能
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
  class Scope < Scope
    def resolve
      if user&.manager?
        # 管理者は全ての打刻データにアクセス可能
        scope.all
      else
        # employeeは一切の打刻データにアクセス不可（閲覧機能なし）
        scope.none
      end
    end
  end

  private

  # 本人の打刻データかチェック（将来の拡張のため残す）
  def owner?
    record.respond_to?(:user) && record.user == user
  end
end
