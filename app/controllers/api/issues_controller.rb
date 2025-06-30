class Api::IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :update, :destroy]
  
  def index
    @issues = Issue.includes(:reviews).recent
    
    # Apply filters
    @issues = @issues.by_status(params[:status]) if params[:status].present?
    @issues = @issues.by_priority(params[:priority]) if params[:priority].present?
    @issues = @issues.where(issue_type: params[:issue_type]) if params[:issue_type].present?
    
    render json: @issues.map { |issue| serialize_issue(issue) }
  end
  
  def show
    render json: serialize_issue(@issue, include_reviews: true)
  end
  
  def create
    @issue = Issue.new(issue_params)
    
    if @issue.save
      render json: serialize_issue(@issue), status: :created
    else
      render json: { errors: @issue.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    if @issue.update(issue_params)
      render json: serialize_issue(@issue)
    else
      render json: { errors: @issue.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @issue.destroy
    head :no_content
  end
  
  private
  
  def set_issue
    @issue = Issue.find(params[:id])
  end
  
  def issue_params
    params.require(:issue).permit(
      :title, :description, :status, :priority, :issue_type,
      :assigned_to, :reporter, :due_date, :acceptance_criteria,
      metadata: {}
    )
  end
  
  def serialize_issue(issue, include_reviews: false)
    data = {
      id: issue.id,
      title: issue.title,
      description: issue.description,
      status: issue.status,
      priority: issue.priority,
      issue_type: issue.issue_type,
      assigned_to: issue.assigned_to,
      reporter: issue.reporter,
      due_date: issue.due_date,
      acceptance_criteria: issue.acceptance_criteria,
      metadata: issue.metadata,
      created_at: issue.created_at,
      updated_at: issue.updated_at,
      can_be_reviewed: issue.can_be_reviewed?,
      reviews_count: issue.reviews.count
    }
    
    if include_reviews
      data[:reviews] = issue.reviews.recent.map { |review| serialize_review(review) }
    end
    
    data
  end
  
  def serialize_review(review)
    {
      id: review.id,
      comment: review.comment,
      status: review.status,
      reviewer_name: review.reviewer_name,
      rating: review.rating,
      feedback_data: review.feedback_data,
      created_at: review.created_at
    }
  end
end