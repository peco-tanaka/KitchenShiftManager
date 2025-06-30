import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useHealthCheck, useApiInfo } from './hooks/useApi';

// QueryClientを作成
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5分
      gcTime: 10 * 60 * 1000, // 10分
    },
  },
});

// ダッシュボードコンポーネント
function Dashboard() {
  const { data: healthData, isLoading: healthLoading, error: healthError } = useHealthCheck();
  const { data: apiData, isLoading: apiLoading, error: apiError } = useApiInfo();

  return (
    <div className="min-h-screen bg-gray-100 py-8">
      <div className="max-w-4xl mx-auto px-4">
        <header className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            飲食店勤怠管理システム
          </h1>
          <p className="text-gray-600">Kitchen Shift Manager - Development Environment</p>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* API情報カード */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">API情報</h2>
            {apiLoading ? (
              <div className="text-gray-500">読み込み中...</div>
            ) : apiError ? (
              <div className="text-red-500">
                エラー: {apiError.message}
              </div>
            ) : apiData ? (
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-600">サービス:</span>
                  <span className="font-medium">{apiData.message}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">バージョン:</span>
                  <span className="font-medium">{apiData.version}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">環境:</span>
                  <span className="font-medium">{apiData.environment}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">タイムスタンプ:</span>
                  <span className="font-medium text-sm">
                    {new Date(apiData.timestamp).toLocaleString('ja-JP')}
                  </span>
                </div>
              </div>
            ) : null}
          </div>

          {/* ヘルスチェックカード */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">システム状態</h2>
            {healthLoading ? (
              <div className="text-gray-500">読み込み中...</div>
            ) : healthError ? (
              <div className="text-red-500">
                エラー: {healthError.message}
              </div>
            ) : healthData ? (
              <div className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-gray-600">ステータス:</span>
                  <span className={`px-2 py-1 rounded text-sm font-medium ${
                    healthData.status === 'healthy' 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {healthData.status === 'healthy' ? '正常' : '異常'}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-gray-600">データベース:</span>
                  <span className={`px-2 py-1 rounded text-sm font-medium ${
                    healthData.database.connected 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {healthData.database.connected ? '接続中' : '切断'}
                  </span>
                </div>
                {healthData.database.connected && (
                  <>
                    <div className="flex justify-between">
                      <span className="text-gray-600">DB種類:</span>
                      <span className="font-medium">{healthData.database.adapter}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">DB名:</span>
                      <span className="font-medium">{healthData.database.database}</span>
                    </div>
                  </>
                )}
                <div className="flex justify-between">
                  <span className="text-gray-600">稼働時間:</span>
                  <span className="font-medium">
                    {Math.round(healthData.uptime.uptime_seconds)}秒
                  </span>
                </div>
              </div>
            ) : null}
          </div>
        </div>

        <div className="mt-8 text-center">
          <p className="text-gray-500 text-sm">
            React {import.meta.env.REACT_VERSION || '18'} + TypeScript + Vite + Rails API
          </p>
        </div>
      </div>
    </div>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Dashboard />
    </QueryClientProvider>
  );
}

export default App;
