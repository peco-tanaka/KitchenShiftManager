class Api::ReviewsController < ApplicationController
  before_action :set_issue
  before_action :set_review, only: [:destroy]
  
  def index
    @reviews = @issue.reviews.recent
    render json: @reviews.map { |review| serialize_review(review) }
  end
  
  def create
    @review = @issue.reviews.build(review_params)
    
    if @review.save
      render json: serialize_review(@review), status: :created
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    @review.destroy
    head :no_content
  end
  
  private
  
  def set_issue
    @issue = Issue.find(params[:issue_id])
  end
  
  def set_review
    @review = @issue.reviews.find(params[:id])
  end
  
  def review_params
    params.require(:review).permit(
      :comment, :status, :reviewer_name, :rating,
      feedback_data: {}
    )
  end
  
  def serialize_review(review)
    {
      id: review.id,
      comment: review.comment,
      status: review.status,
      reviewer_name: review.reviewer_name,
      rating: review.rating,
      feedback_data: review.feedback_data,
      created_at: review.created_at,
      issue_id: review.issue_id
    }
  end
end