class Review < ApplicationRecord
  belongs_to :issue
  
  validates :comment, presence: true
  validates :status, presence: true
  validates :reviewer_name, presence: true
  
  enum status: { 
    approved: 0, 
    rejected: 1, 
    needs_changes: 2, 
    pending: 3 
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  
  after_create :update_issue_status
  
  private
  
  def update_issue_status
    case status
    when 'approved'
      issue.update(status: 'resolved') if issue.under_review?
    when 'rejected'
      issue.update(status: 'open')
    when 'needs_changes'
      issue.update(status: 'in_progress')
    end
  end
end