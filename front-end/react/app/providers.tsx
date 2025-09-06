'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { useAuthStore } from '../lib/stores/authStore';

export default function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient());
  const checkAuthStatus = useAuthStore((state) => state.checkAuthStatus);

  useEffect(() => {
    // 컴포넌트가 마운트될 때 인증 상태 확인
    checkAuthStatus();
  }, [checkAuthStatus]);

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}