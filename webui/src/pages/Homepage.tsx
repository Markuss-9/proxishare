import { useState, useEffect, useCallback } from 'react';
import { useMediaStore, type FileId } from '@/store';
import FilePreviewModal from '@/components/FilePreviewModal';
import ControlPanel from '@/components/ControlPanel';
import FileSection from '@/components/FileSection';
import { Sun, Moon, Upload, Wifi, WifiOff, Loader2 } from 'lucide-react';
import { useTheme } from '@/hooks/useTheme';
import { useServerStatus } from '@/hooks/useServerStatus';

function ConnectionIndicator() {
  const { status, checkConnection } = useServerStatus();

  return (
    <button
      onClick={checkConnection}
      className="flex items-center gap-1.5 px-2 py-1 rounded text-xs font-medium transition-colors"
      title={status === 'disconnected' ? 'Click to retry' : undefined}
    >
      {status === 'checking' && (
        <Loader2 className="w-3 h-3 animate-spin text-gray-400" />
      )}
      {status === 'connected' && (
        <>
          <Wifi className="w-3 h-3 text-green-500" />
          <span className="text-green-600 dark:text-green-400">Connected</span>
        </>
      )}
      {status === 'disconnected' && (
        <>
          <WifiOff className="w-3 h-3 text-red-500" />
          <span className="text-red-600 dark:text-red-400">Offline</span>
        </>
      )}
    </button>
  );
}

export default function Homepage() {
  const { files, addFiles, removeFiles } = useMediaStore();
  const [previewIndex, setPreviewIndex] = useState<FileId | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const { isDark, toggleTheme: toggleDarkMode } = useTheme();

  useEffect(() => {
    return () => {
      files.forEach((f) => URL.revokeObjectURL(f.url));
    };
  }, [files]);

  const handleAddFiles = useCallback(
    (newFiles: File[]) => {
      addFiles(newFiles);
    },
    [addFiles]
  );

  const handleRemoveFiles = useCallback(
    (ids: FileId[]) => {
      removeFiles(ids);
    },
    [removeFiles]
  );

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  }, []);

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setIsDragging(false);

      const items = e.dataTransfer.items;
      const droppedFiles: File[] = [];

      if (items) {
        for (let i = 0; i < items.length; i++) {
          const item = items[i];
          if (item.kind === 'file') {
            const file = item.getAsFile();
            if (file) droppedFiles.push(file);
          }
        }
      }

      if (droppedFiles.length > 0) {
        handleAddFiles(droppedFiles);
      }
    },
    [handleAddFiles]
  );

  const previewFile = files?.find((f) => f.id === previewIndex);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-slate-950 p-4 transition-colors">
      <div className="w-full max-w-6xl">
        <div className="bg-white dark:bg-slate-900 rounded-lg shadow-lg overflow-hidden border border-gray-200 dark:border-slate-700">
          <div className="px-6 py-4 border-b border-gray-200 dark:border-slate-700 flex items-center justify-between">
            <div className="flex items-center gap-4">
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
                Local Media Share
              </h1>
              <ConnectionIndicator />
            </div>
            <button
              onClick={toggleDarkMode}
              className="p-2 rounded-lg bg-gray-100 dark:bg-slate-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-slate-700 transition-colors"
              aria-label="Toggle dark mode"
            >
              {isDark ? <Sun size={20} /> : <Moon size={20} />}
            </button>
          </div>

          <div
            className="p-4 md:p-6 flex flex-col md:flex-row gap-6 md:gap-8 relative"
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
          >
            {isDragging && (
              <div className="absolute inset-0 bg-indigo-500/10 dark:bg-indigo-500/20 border-2 border-dashed border-indigo-500 rounded-lg z-10 flex items-center justify-center">
                <div className="bg-white dark:bg-slate-800 px-6 py-4 rounded-lg shadow-lg flex items-center gap-3">
                  <Upload className="w-8 h-8 text-indigo-600" />
                  <span className="text-lg font-medium text-gray-900 dark:text-white">
                    Drop files here
                  </span>
                </div>
              </div>
            )}
            <ControlPanel onAddFiles={handleAddFiles} />
            <FileSection
              files={files}
              onRemoveFiles={handleRemoveFiles}
              onPreview={(idx) => setPreviewIndex(idx)}
            />
          </div>
        </div>
      </div>

      <FilePreviewModal
        file={previewFile}
        onClose={() => setPreviewIndex(null)}
      />
    </div>
  );
}
