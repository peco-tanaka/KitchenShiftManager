/*
  API接続用の設定
  API通信の共通処理を集約し、フロントエンドからのAPI呼び出しを簡潔かつ型安全に行うための基盤ファイル
 */

  const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_API_BASE || '/api';

export interface HealthResponse {
  status: string;
  service: string;
  version: string;
  environment: string;
  timestamp: string;
  database: {
    connected: boolean;
    adapter?: string;
    database?: string;
    error?: string;
  };
  uptime: {
    process_started: string;
    uptime_seconds: number;
  };
}

export interface ApiResponse {
  message: string;
  version: string;
  environment: string;
  timestamp: string;
}

class ApiClient {
  private baseURL: string;

  constructor(baseURL: string = API_BASE_URL) {
    this.baseURL = baseURL;
  }

  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;
    
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`);
    }

    return response.json();
  }

  // ヘルスチェック
  async health(): Promise<HealthResponse> {
    return this.request<HealthResponse>('/health');
  }

  // ルート情報取得
  async getApiInfo(): Promise<ApiResponse> {
    return this.request<ApiResponse>('/', {
      headers: {},
    });
  }
}

export const apiClient = new ApiClient();
