import { useMemo } from 'react';
import { useMediaStore } from '@/store';
import { Progress } from '@/components/ui/progress';

export function UploadProgress() {
  const { files, uploading } = useMediaStore();

  const totalProgress = useMemo(() => {
    if (!files || files.length === 0) return 0;
    const total = files.reduce((sum, f) => sum + (f.progress ?? 0), 0);
    return Math.round(total / files.length);
  }, [files]);

  if (!uploading || !files || files.length === 0) return null;

  return (
    <div className="flex flex-col gap-3">
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

      <div className="flex items-center gap-2">
        <span className="text-xs text-gray-500">Total:</span>
        <Progress value={totalProgress} className="flex-1 h-2" />
        <span className="text-xs text-gray-500">{totalProgress}%</span>
      </div>

      <div
        className="h-2 transition-opacity duration-500"
        style={{ opacity: uploading ? 1 : 0 }}
      >
        <Progress
          value={totalProgress}
          className="w-full h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden [&>div]:transition-all [&>div]:duration-600 [&>div]:ease-out"
        />
      </div>
    </div>
  );
}
