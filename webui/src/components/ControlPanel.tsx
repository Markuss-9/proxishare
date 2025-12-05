import { useRef, useState } from 'react';
import { useMediaStore } from '@/store';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { LocalServer } from '@/client';
import ModeToggle from './ModeToggle';

interface ControlPanelProps {
  onAddFiles: (files: File[]) => void;
}

export default function ControlPanel({ onAddFiles }: ControlPanelProps) {
  const { files, setFiles, mode, uploading, setUploading } = useMediaStore();
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<Error>();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const fileList = e.target.files;
    if (!fileList) return;
    const newFiles = Array.from(fileList);
    onAddFiles(newFiles);
    e.currentTarget.value = '';
  };

  const handleShare = async () => {
    if (!files || files.length === 0) return;
    setUploading(true);
    const formData = new FormData();
    files.forEach((f) => formData.append('files', f.file));

    try {
      const endpoint = mode === 'media' ? '/upload/media' : '/upload/files';
      await LocalServer.post(endpoint, formData, {
        onUploadProgress: (ev) => {
          if (!ev.total) return;
          setProgress(Math.round((ev.loaded * 100) / ev.total));
        },
      });

      setProgress(100);
    } catch (error) {
      setError(error as Error);
    } finally {
      setTimeout(() => setUploading(false), 1000);
      setTimeout(() => setProgress(0), 1500);
    }
  };

  return (
    <div className="w-full lg:w-1/3 flex flex-col gap-4">
      <div className="flex flex-col gap-3">
        <label htmlFor="file-input" className="sr-only">
          Select file
        </label>
        <ModeToggle />

        <input
          ref={fileInputRef}
          id="file-input"
          type="file"
          multiple
          accept={mode === 'media' ? 'image/*,video/*' : undefined}
          onChange={handleSelect}
          className="block w-full text-sm text-gray-500 dark:text-gray-400
            file:mr-4 file:py-2 file:px-4
            file:rounded file:border-0
            file:text-sm file:font-semibold
            file:bg-indigo-50 file:text-indigo-700
            dark:file:bg-indigo-900 dark:file:text-indigo-200
            hover:file:bg-indigo-100 dark:hover:file:bg-indigo-800
            cursor-pointer"
        />
      </div>

      <div className="flex flex-col gap-3">
        <div
          className="h-2 transition-opacity duration-500"
          style={{ opacity: uploading ? 1 : 0 }}
        >
          <Progress
            value={progress}
            className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden [&>div]:transition-all [&>div]:duration-600 [&>div]:ease-out"
          />
        </div>
        <div className="flex gap-2">
          <Button
            onClick={handleShare}
            disabled={!files || files.length === 0 || uploading}
            className="flex-1 transition-all duration-200"
          >
            {uploading ? (
              <span className="flex items-center gap-2">
                <span className="animate-spin">⏳</span>
                Uploading...
              </span>
            ) : (
              'Share'
            )}
          </Button>
          <Button
            variant="outline"
            onClick={() => setFiles([])}
            disabled={!files || files.length === 0 || uploading}
            className="transition-all duration-200"
          >
            Clear
          </Button>
        </div>
      </div>

      {error && (
        <div className="text-sm text-red-700 dark:text-red-300 bg-red-100 dark:bg-red-900/40 p-3 rounded border-l-4 border-red-600 dark:border-red-500 animate-in slide-in-from-top-2 zoom-in-95 duration-400">
          {error.message}
        </div>
      )}
    </div>
  );
}
