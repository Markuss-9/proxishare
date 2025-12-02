import { cn } from '@/lib/utils';
import React, { useMemo } from 'react';

type Props = {
  file: File;
  url: string;
  selected?: boolean;
  onRemove?: () => void;
};

const isImage = (type: string) => type.startsWith('image/');
const isVideo = (type: string) => type.startsWith('video/');
const isPdf = (type: string) => type === 'application/pdf';

export default React.memo(function FileItem({
  file,
  url,
  selected,
  onRemove,
}: Props) {
  const ext = file.name.split('.').pop()?.toUpperCase() ?? 'FILE';

  const MediaMemoized = useMemo(() => {
    if (!url) return null;
    if (isImage(file.type)) {
      return (
        <img src={url} alt={file.name} className="w-full h-full object-cover" />
      );
    } else if (isVideo(file.type)) {
      return <video src={url} className="w-full h-full object-cover" />;
    } else {
      return null;
    }
  }, [file.type, file.name, url]);

  return (
    <div
      className={cn([
        'relative cursor-pointer rounded overflow-hidden border bg-white dark:bg-slate-900 hover:shadow-lg transition-shadow duration-150',
        selected && 'ring-2 ring-indigo-400',
      ])}
    >
      <div className="w-36 h-28 bg-gray-100 flex items-center justify-center">
        {MediaMemoized}
        {url && isPdf(file.type) && (
          <div className="w-full h-full flex items-center justify-center text-xs text-gray-600">
            PDF
          </div>
        )}

        {!url && <div className="text-gray-400">Loading…</div>}

        {!isImage(file.type) &&
          !isVideo(file.type) &&
          !isPdf(file.type) &&
          url && (
            <div className="absolute inset-0 flex flex-col items-center justify-center text-sm text-gray-600 bg-white/60">
              <div className="text-2xl">📄</div>
              <div className="text-xs mt-1">{ext}</div>
            </div>
          )}
      </div>

      <div className="p-2 text-xs text-left w-36">
        <div className="truncate font-medium">{file.name}</div>
        <div className="text-[11px] text-gray-400">
          {Math.round(file.size / 1024)} KB
        </div>
      </div>

      {onRemove && (
        <button
          onClick={(e) => {
            e.stopPropagation();
            onRemove();
          }}
          aria-label={`Remove ${file.name}`}
          className="absolute top-1 right-1 text-xs px-1 py-0.5 bg-white/80 rounded text-red-600 hover:bg-red-50"
        >
          ✕
        </button>
      )}

      {selected && (
        <div className="absolute top-1 left-1 w-5 h-5 rounded-full bg-indigo-600 text-white text-[11px] flex items-center justify-center">
          ✓
        </div>
      )}
    </div>
  );
});
