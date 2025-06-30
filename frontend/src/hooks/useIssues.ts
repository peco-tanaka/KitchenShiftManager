import { useQuery, useMutation, useQueryClient } from 'react-query';
import api from '../utils/api';
import { Issue, CreateIssueData } from '../types';

export const useIssues = (filters?: {
  status?: string;
  priority?: string;
  issue_type?: string;
}) => {
  return useQuery(['issues', filters], async () => {
    const params = new URLSearchParams();
    if (filters?.status) params.append('status', filters.status);
    if (filters?.priority) params.append('priority', filters.priority);
    if (filters?.issue_type) params.append('issue_type', filters.issue_type);
    
    const response = await api.get(`/issues?${params.toString()}`);
    return response.data as Issue[];
  });
};

export const useIssue = (id: number) => {
  return useQuery(['issue', id], async () => {
    const response = await api.get(`/issues/${id}`);
    return response.data as Issue;
  });
};

export const useCreateIssue = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async (data: CreateIssueData) => {
      const response = await api.post('/issues', { issue: data });
      return response.data as Issue;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['issues']);
      },
    }
  );
};

export const useUpdateIssue = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async ({ id, data }: { id: number; data: Partial<CreateIssueData> }) => {
      const response = await api.put(`/issues/${id}`, { issue: data });
      return response.data as Issue;
    },
    {
      onSuccess: (data) => {
        queryClient.invalidateQueries(['issues']);
        queryClient.invalidateQueries(['issue', data.id]);
      },
    }
  );
};

export const useDeleteIssue = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async (id: number) => {
      await api.delete(`/issues/${id}`);
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['issues']);
      },
    }
  );
};