import { useRef, useState, useMemo } from 'react';
import { useMediaStore } from '@/store';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { LocalServer } from '@/client';
import ModeToggle from './ModeToggle';
import JSZip from 'jszip';

interface ControlPanelProps {
  onAddFiles: (files: File[]) => void;
}

interface FolderInputProps {
  webkitdirectory?: string;
  directory?: string;
}

export default function ControlPanel({ onAddFiles }: ControlPanelProps) {
  const {
    files,
    clearFiles,
    mode,
    uploading,
    setUploading,
    updateFileProgress,
  } = useMediaStore();
  const [error, setError] = useState<Error>();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const totalProgress = useMemo(() => {
    if (!files || files.length === 0) return 0;
    const total = files.reduce((sum, f) => sum + (f.progress ?? 0), 0);
    return Math.round(total / files.length);
  }, [files]);

  const handleSelectFolder = async (folderFiles: File[]) => {
    const zip = new JSZip();

    const folderName = folderFiles[0].webkitRelativePath.split('/')[0];
    folderFiles.forEach((file) => {
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
    setError(undefined);

    files.forEach((f) => updateFileProgress(f.id, 0));

    const endpoint = mode === 'media' ? '/upload/media' : '/upload/files';

    try {
      for (const fileEnriched of files) {
        const formData = new FormData();
        formData.append('files', fileEnriched.file);

        await LocalServer.post(endpoint, formData, {
          onUploadProgress: (ev) => {
            if (ev.total) {
              const prog = Math.round((ev.loaded * 100) / ev.total);
              updateFileProgress(fileEnriched.id, prog);
            }
          },
        });
        updateFileProgress(fileEnriched.id, 100);
      }
    } catch (err) {
      setError(err as Error);
    } finally {
      setTimeout(() => setUploading(false), 1000);
      setTimeout(() => {
        files.forEach((f) => updateFileProgress(f.id, 0));
      }, 1500);
    }
  };

  return (
    <div className="w-full md:w-1/3 flex flex-col gap-4">
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
          {...(mode === 'folder'
            ? { webkitdirectory: '', directory: '' }
            : ({} as FolderInputProps))}
          accept={mode === 'media' ? 'image/*,video/*' : undefined}
          onChange={handleSelect}
          className="sr-only"
        />

        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          className="w-full sm:w-auto px-4 py-2 rounded bg-indigo-600 text-white hover:bg-indigo-700 transition-colors"
        >
          Choose Files
        </button>
      </div>

      <div className="flex flex-col gap-3">
        {uploading && files && files.length > 0 && (
          <div className="flex flex-col gap-2">
            {files.map((f) => (
              <div key={f.id} className="flex items-center gap-2">
                <div className="flex-1 min-w-0">
                  <div className="text-xs truncate text-gray-700 dark:text-gray-300">
                    {f.file.name}
                  </div>
                  <Progress value={f.progress ?? 0} className="h-1.5 mt-1" />
                </div>
                <span className="text-xs text-gray-500 shrink-0">
                  {f.progress ?? 0}%
                </span>
              </div>
            ))}
          </div>
        )}
        {uploading && files && files.length > 0 && (
          <div className="flex items-center gap-2">
            <span className="text-xs text-gray-500">Total:</span>
            <Progress value={totalProgress} className="flex-1 h-2" />
            <span className="text-xs text-gray-500">{totalProgress}%</span>
          </div>
        )}
        <div
          className="h-2 transition-opacity duration-500"
          style={{ opacity: uploading ? 1 : 0 }}
        >
          <Progress
            value={totalProgress}
            className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden [&>div]:transition-all [&>div]:duration-600 [&>div]:ease-out"
          />
        </div>
        <div className="flex flex-col sm:flex-row gap-2">
          <Button
            onClick={handleShare}
            disabled={!files || files.length === 0 || uploading}
            className="w-full sm:w-auto sm:flex-1 transition-all duration-200"
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
            onClick={() => clearFiles()}
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
