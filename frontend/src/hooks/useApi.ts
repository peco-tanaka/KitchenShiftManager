import { useQuery } from '@tanstack/react-query';
import { apiClient, HealthResponse, ApiResponse } from '../services/api';

// ヘルスチェック用カスタムフック
export const useHealthCheck = () => {
  return useQuery<HealthResponse, Error>({
    queryKey: ['health'],
    queryFn: () => apiClient.health(),
    refetchInterval: 30000, // 30秒ごとに再取得
    retry: 3,
    staleTime: 10000, // 10秒間はキャッシュを使用
  });
};

// API情報取得用カスタムフック
export const useApiInfo = () => {
  return useQuery<ApiResponse, Error>({
    queryKey: ['apiInfo'],
    queryFn: () => apiClient.getApiInfo(),
    staleTime: 300000, // 5分間はキャッシュを使用
    retry: 2,
  });
};

// API接続状態を確認するカスタムフック
export const useApiStatus = () => {
  const healthQuery = useHealthCheck();
  const apiInfoQuery = useApiInfo();

  return {
    isConnected: healthQuery.isSuccess && apiInfoQuery.isSuccess,
    isLoading: healthQuery.isLoading || apiInfoQuery.isLoading,
    error: healthQuery.error || apiInfoQuery.error,
    healthData: healthQuery.data,
    apiData: apiInfoQuery.data,
    refetch: () => {
      healthQuery.refetch();
      apiInfoQuery.refetch();
    },
  };
};
