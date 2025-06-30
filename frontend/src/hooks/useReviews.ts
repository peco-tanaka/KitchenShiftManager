import { useMutation, useQueryClient } from 'react-query';
import api from '../utils/api';
import { Review, CreateReviewData } from '../types';

export const useCreateReview = (issueId: number) => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async (data: CreateReviewData) => {
      const response = await api.post(`/issues/${issueId}/reviews`, { review: data });
      return response.data as Review;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['issue', issueId]);
        queryClient.invalidateQueries(['issues']);
      },
    }
  );
};

export const useDeleteReview = (issueId: number) => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async (reviewId: number) => {
      await api.delete(`/issues/${issueId}/reviews/${reviewId}`);
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['issue', issueId]);
      },
    }
  );
};