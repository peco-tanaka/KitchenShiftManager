# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # 一覧表示権限
  def index?
    user&.manager?
  end

  # 詳細表示権限
  def show?
    user&.manager?
  end

  # 作成権限
  def create?
    user&.manager?
  end

  # 作成フォーム権限
  def new?
    create?
  end

  # 更新権限
  def update?
    user&.manager?
  end

  # 編集フォーム権限
  def edit?
    update?
  end

  # 削除権限
  def destroy?
    user&.manager?
  end

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
