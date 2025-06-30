export interface Issue {
  id: number;
  title: string;
  description: string;
  status: 'open' | 'in_progress' | 'under_review' | 'resolved' | 'closed';
  priority: 'low' | 'medium' | 'high' | 'critical';
  issue_type: 'development' | 'bug' | 'feature' | 'improvement' | 'task';
  assigned_to?: string;
  reporter?: string;
  due_date?: string;
  acceptance_criteria?: string;
  metadata?: Record<string, any>;
  created_at: string;
  updated_at: string;
  can_be_reviewed: boolean;
  reviews_count: number;
  reviews?: Review[];
}

export interface Review {
  id: number;
  comment: string;
  status: 'approved' | 'rejected' | 'needs_changes' | 'pending';
  reviewer_name: string;
  rating?: number;
  feedback_data?: Record<string, any>;
  created_at: string;
  issue_id: number;
}

export interface CreateIssueData {
  title: string;
  description: string;
  priority: Issue['priority'];
  issue_type: Issue['issue_type'];
  assigned_to?: string;
  reporter?: string;
  due_date?: string;
  acceptance_criteria?: string;
  metadata?: Record<string, any>;
}

export interface CreateReviewData {
  comment: string;
  status: Review['status'];
  reviewer_name: string;
  rating?: number;
  feedback_data?: Record<string, any>;
}