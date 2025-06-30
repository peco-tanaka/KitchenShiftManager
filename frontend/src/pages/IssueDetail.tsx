import React, { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useIssue } from '../hooks/useIssues';
import { useCreateReview } from '../hooks/useReviews';
import { CreateReviewData, Review } from '../types';

const IssueDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const issueId = parseInt(id!);
  
  const { data: issue, isLoading, error } = useIssue(issueId);
  const createReview = useCreateReview(issueId);
  
  const [showReviewForm, setShowReviewForm] = useState(false);
  const [reviewForm, setReviewForm] = useState<CreateReviewData>({
    comment: '',
    status: 'pending',
    reviewer_name: '',
  });

  const handleSubmitReview = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createReview.mutateAsync(reviewForm);
      setShowReviewForm(false);
      setReviewForm({
        comment: '',
        status: 'pending',
        reviewer_name: '',
      });
    } catch (error) {
      console.error('Failed to create review:', error);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'open': return 'bg-red-100 text-red-800';
      case 'in_progress': return 'bg-yellow-100 text-yellow-800';
      case 'under_review': return 'bg-blue-100 text-blue-800';
      case 'resolved': return 'bg-green-100 text-green-800';
      case 'closed': return 'bg-gray-100 text-gray-800';
      case 'approved': return 'bg-green-100 text-green-800';
      case 'rejected': return 'bg-red-100 text-red-800';
      case 'needs_changes': return 'bg-yellow-100 text-yellow-800';
      case 'pending': return 'bg-blue-100 text-blue-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-indigo-500"></div>
      </div>
    );
  }

  if (error || !issue) {
    return (
      <div className="bg-red-50 border border-red-300 text-red-700 px-4 py-3 rounded">
        Error loading issue. Please try again later.
      </div>
    );
  }

  return (
    <div className="px-4 sm:px-6 lg:px-8">
      <div className="mb-6">
        <Link to="/" className="text-indigo-600 hover:text-indigo-900">
          ← Back to Issues
        </Link>
      </div>

      {/* Issue Header */}
      <div className="bg-white shadow overflow-hidden sm:rounded-lg">
        <div className="px-4 py-5 sm:px-6">
          <h3 className="text-lg leading-6 font-medium text-gray-900">
            {issue.title}
          </h3>
          <p className="mt-1 max-w-2xl text-sm text-gray-500">
            Issue #{issue.id}
          </p>
        </div>
        <div className="border-t border-gray-200 px-4 py-5 sm:px-6">
          <dl className="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
            <div>
              <dt className="text-sm font-medium text-gray-500">Status</dt>
              <dd className="mt-1">
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(issue.status)}`}>
                  {issue.status.replace('_', ' ')}
                </span>
              </dd>
            </div>
            <div>
              <dt className="text-sm font-medium text-gray-500">Priority</dt>
              <dd className="mt-1 text-sm text-gray-900">{issue.priority}</dd>
            </div>
            <div>
              <dt className="text-sm font-medium text-gray-500">Type</dt>
              <dd className="mt-1 text-sm text-gray-900">{issue.issue_type}</dd>
            </div>
            <div>
              <dt className="text-sm font-medium text-gray-500">Created</dt>
              <dd className="mt-1 text-sm text-gray-900">
                {new Date(issue.created_at).toLocaleDateString()}
              </dd>
            </div>
            {issue.assigned_to && (
              <div>
                <dt className="text-sm font-medium text-gray-500">Assigned to</dt>
                <dd className="mt-1 text-sm text-gray-900">{issue.assigned_to}</dd>
              </div>
            )}
            {issue.reporter && (
              <div>
                <dt className="text-sm font-medium text-gray-500">Reporter</dt>
                <dd className="mt-1 text-sm text-gray-900">{issue.reporter}</dd>
              </div>
            )}
            <div className="sm:col-span-2">
              <dt className="text-sm font-medium text-gray-500">Description</dt>
              <dd className="mt-1 text-sm text-gray-900 whitespace-pre-wrap">
                {issue.description}
              </dd>
            </div>
            {issue.acceptance_criteria && (
              <div className="sm:col-span-2">
                <dt className="text-sm font-medium text-gray-500">Acceptance Criteria</dt>
                <dd className="mt-1 text-sm text-gray-900 whitespace-pre-wrap">
                  {issue.acceptance_criteria}
                </dd>
              </div>
            )}
          </dl>
        </div>
      </div>

      {/* Reviews Section */}
      <div className="mt-8">
        <div className="bg-white shadow sm:rounded-lg">
          <div className="px-4 py-5 sm:px-6 flex justify-between items-center">
            <div>
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Reviews ({issue.reviews?.length || 0})
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                Review feedback and comments for this issue.
              </p>
            </div>
            {issue.can_be_reviewed && (
              <button
                onClick={() => setShowReviewForm(!showReviewForm)}
                className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                Add Review
              </button>
            )}
          </div>

          {/* Review Form */}
          {showReviewForm && (
            <div className="border-t border-gray-200 px-4 py-5 sm:px-6">
              <form onSubmit={handleSubmitReview} className="space-y-4">
                <div>
                  <label htmlFor="reviewer_name" className="block text-sm font-medium text-gray-700">
                    Reviewer Name
                  </label>
                  <input
                    type="text"
                    id="reviewer_name"
                    required
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    value={reviewForm.reviewer_name}
                    onChange={(e) => setReviewForm({ ...reviewForm, reviewer_name: e.target.value })}
                  />
                </div>
                
                <div>
                  <label htmlFor="status" className="block text-sm font-medium text-gray-700">
                    Review Status
                  </label>
                  <select
                    id="status"
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    value={reviewForm.status}
                    onChange={(e) => setReviewForm({ ...reviewForm, status: e.target.value as Review['status'] })}
                  >
                    <option value="pending">Pending</option>
                    <option value="approved">Approved</option>
                    <option value="rejected">Rejected</option>
                    <option value="needs_changes">Needs Changes</option>
                  </select>
                </div>
                
                <div>
                  <label htmlFor="comment" className="block text-sm font-medium text-gray-700">
                    Comment
                  </label>
                  <textarea
                    id="comment"
                    rows={4}
                    required
                    className="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                    value={reviewForm.comment}
                    onChange={(e) => setReviewForm({ ...reviewForm, comment: e.target.value })}
                  />
                </div>
                
                <div className="flex justify-end space-x-3">
                  <button
                    type="button"
                    onClick={() => setShowReviewForm(false)}
                    className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={createReview.isLoading}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
                  >
                    {createReview.isLoading ? 'Submitting...' : 'Submit Review'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Reviews List */}
          <div className="border-t border-gray-200">
            {issue.reviews && issue.reviews.length > 0 ? (
              <div className="divide-y divide-gray-200">
                {issue.reviews.map((review) => (
                  <div key={review.id} className="px-4 py-5 sm:px-6">
                    <div className="flex items-start space-x-3">
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center space-x-2">
                          <p className="text-sm font-medium text-gray-900">
                            {review.reviewer_name}
                          </p>
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(review.status)}`}>
                            {review.status.replace('_', ' ')}
                          </span>
                          <span className="text-sm text-gray-500">
                            {new Date(review.created_at).toLocaleDateString()}
                          </span>
                        </div>
                        <div className="mt-2">
                          <p className="text-sm text-gray-700 whitespace-pre-wrap">
                            {review.comment}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="px-4 py-5 sm:px-6 text-center text-gray-500">
                No reviews yet.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default IssueDetail;