import { useRef, useState } from 'react';
import { useMediaStore } from '@/store';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { LocalServer } from '@/client';
import ModeToggle from './ModeToggle';
import JSZip from 'jszip';

interface ControlPanelProps {
  onAddFiles: (files: File[]) => void;
}

export default function ControlPanel({ onAddFiles }: ControlPanelProps) {
  const { files, setFiles, mode, uploading, setUploading } = useMediaStore();
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<Error>();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleSelectFolder = async (folderFiles: File[]) => {
    const zip = new JSZip();

    const folderName = folderFiles[0].webkitRelativePath.split('/')[0];
    folderFiles.forEach((file) => {
      // Preserve folder structure if available
      const path = file.webkitRelativePath || file.name;
      zip.file(path, file);
    });

    const blob = await zip.generateAsync({ type: 'blob' });
    const zipFile = new File([blob], `${folderName}.zip`, {
      type: 'application/zip',
    });
    onAddFiles([zipFile]);
  };

  const handleSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.currentTarget;
    const fileList = e.target.files;
    if (!fileList || !fileList.length) return;

    const newFiles = Array.from(fileList);

    if (mode === 'folder') {
      await handleSelectFolder(newFiles);
      input.value = '';
      return;
    }

    onAddFiles(newFiles);
    input.value = '';
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
        <ModeToggle />

        <label htmlFor="file-input" className="sr-only">
          Choose Files
        </label>
        <input
          ref={fileInputRef}
          id="file-input"
          type="file"
          multiple
          {...((mode === 'folder'
            ? { webkitdirectory: '', directory: '' }
            : {}) as any)}
          accept={mode === 'media' ? 'image/*,video/*' : undefined}
          onChange={handleSelect}
          className="sr-only"
        />

        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          className="px-4 py-2 rounded bg-indigo-600 text-white hover:bg-indigo-700"
        >
          Choose Files
        </button>
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
