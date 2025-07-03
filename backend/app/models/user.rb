class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # 飲食店勤怠管理システムでは registerable, recoverable は無効化
  devise :database_authenticatable, :rememberable, :validatable

  # ロール定義（enum）
  enum role: { employee: 0, manager: 1 }

  # バリデーション
  validates :employee_number, presence: true, uniqueness: true,
            format: { with: /\A\d{4}\z/, message: '社員番号は4桁の数字で入力してください' }
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :hourly_wage, presence: true, numericality: { greater_than: 0 }
  validates :hired_on, presence: true

  # パスワードは4桁の数字のみ
  validates :password, format: { with: /\A\d{4}\z/, message: 'パスワードは4桁の数字で入力してください' },
            if: :password_required?

  # Association（将来の機能拡張用）
  # has_many :punches, dependent: :destroy
  # has_many :user_allowances, dependent: :destroy
  # has_many :allowances, through: :user_allowances

  # Deviseの認証キーを employee_number に変更（簡潔版）
  def self.find_for_database_authentication(warden_conditions)
    find_by(employee_number: warden_conditions[:employee_number])
  end

  # emailフィールドが不要なのでバリデーションを無効化
  def email_required?
    false
  end

  def email_changed?
    false
  end

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
