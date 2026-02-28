import { useState } from 'react';
import { useMediaStore } from '@/store';
import { LocalServer } from '@/client';
import { FileUploader } from './FileUploader';
import { UploadProgress } from './UploadProgress';
import { ActionButtons } from './ActionButtons';
import { ErrorAlert } from './ErrorAlert';

interface ControlPanelProps {
  onAddFiles: (files: File[]) => void;
}

export default function ControlPanel({ onAddFiles }: ControlPanelProps) {
  const { files, clearFiles, uploading, setUploading, updateFileProgress } =
    useMediaStore();
  const [error, setError] = useState<Error>();

  const handleShare = async () => {
    if (!files || files.length === 0) return;
    setUploading(true);
    setError(undefined);

    files.forEach((f) => updateFileProgress(f.id, 0));

    try {
      for (const fileEnriched of files) {
        const formData = new FormData();
        formData.append('files', fileEnriched.file);

        await LocalServer.post('/upload', formData, {
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
      <FileUploader onAddFiles={onAddFiles} />

      <div className="flex flex-col gap-3">
        <UploadProgress />
        <ActionButtons
          onShare={handleShare}
          onClear={() => clearFiles()}
          uploading={uploading}
          disabled={!files || files.length === 0 || uploading}
        />
      </div>

      <ErrorAlert error={error} />
    </div>
  );
}
