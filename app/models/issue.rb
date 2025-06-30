class Issue < ApplicationRecord
  has_many :reviews, dependent: :destroy
  
  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :issue_type, presence: true
  
  enum status: { 
    open: 0, 
    in_progress: 1, 
    under_review: 2, 
    resolved: 3, 
    closed: 4 
  }
  
  enum priority: { 
    low: 0, 
    medium: 1, 
    high: 2, 
    critical: 3 
  }
  
  enum issue_type: { 
    development: 0, 
    bug: 1, 
    feature: 2, 
    improvement: 3,
    task: 4
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  
  def can_be_reviewed?
    in_progress? || under_review?
  end
end