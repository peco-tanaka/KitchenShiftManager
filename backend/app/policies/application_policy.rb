# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
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
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.manager?
        scope.all
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  private

  # 管理者権限チェック
  def manager?
    user&.manager?
  end

  # 従業員権限チェック
  def employee?
    user&.employee?
  end

  # 本人確認（レコードがユーザーに関連する場合）
  def owner?
    return false unless user && record

    record.respond_to?(:user) && record.user == user
  end
end
