import { useState, useEffect, useCallback } from 'react';
import { LocalServer } from '@/client';

export type ConnectionStatus = 'checking' | 'connected' | 'disconnected';

export function useServerStatus() {
  const [status, setStatus] = useState<ConnectionStatus>('checking');

  const checkConnection = useCallback(async () => {
    setStatus('checking');
    try {
      await LocalServer.get('/health', { timeout: 3000 });
      setStatus('connected');
    } catch {
      setStatus('disconnected');
    }
  }, []);

  useEffect(() => {
    checkConnection();
  }, [checkConnection]);

  return { status, checkConnection };
}
