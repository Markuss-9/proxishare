import { cn, isImage, isVideo, isPdf, formatFileSize } from '@/lib/utils';
import React, { useState, useEffect, useCallback } from 'react';
import { AlertTriangle, X, Check, FileText, File, Trash2 } from 'lucide-react';

type Props = {
  file: File;
  url: string;
  selected?: boolean;
  selectionMode?: boolean;
  onOpen?: () => void;
  onSelect?: () => void;
  onRemove?: () => void;
};

export default React.memo(function FileItem({
  file,
  url,
  selected,
  selectionMode,
  onOpen,
  onSelect,
  onRemove,
}: Props) {
  const ext = file.name.split('.').pop()?.toUpperCase() ?? 'FILE';
  const [isError, setError] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [showRemoveConfirm, setShowRemoveConfirm] = useState(false);

  useEffect(() => {
    setError(false);
  }, [url]);

  const handleRemove = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      if (showRemoveConfirm) {
        onRemove?.();
        setShowRemoveConfirm(false);
      } else {
        setShowRemoveConfirm(true);
        setTimeout(() => setShowRemoveConfirm(false), 3000);
      }
    },
    [onRemove, showRemoveConfirm]
  );

  useEffect(() => {
    if (showRemoveConfirm) {
      const timer = setTimeout(() => setShowRemoveConfirm(false), 3000);
      return () => clearTimeout(timer);
    }
  }, [showRemoveConfirm]);

  const handleClick = useCallback(() => {
    if (selectionMode && onSelect) {
      onSelect();
    } else if (!selectionMode && onOpen) {
      onOpen();
    }
  }, [selectionMode, onSelect, onOpen]);

  const getFileIcon = () => {
    if (isPdf(file.type)) {
      return <FileText className="w-10 h-10 text-red-500" />;
    }
    return <File className="w-10 h-10 text-gray-400" />;
  };

  return (
    <div
      className={cn(
        'group relative rounded-xl overflow-hidden border bg-white dark:bg-slate-900 transition-all duration-200 cursor-pointer select-none touch-none',
        'hover:shadow-lg hover:-translate-y-0.5',
        selected &&
          'ring-2 ring-indigo-500 ring-offset-2 dark:ring-offset-slate-900'
      )}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={handleClick}
    >
      <div className="relative w-full aspect-4/3 bg-gray-100 dark:bg-slate-800 flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-linear-to-t from-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-200" />

        {url && (isImage(file.type) || isVideo(file.type)) && !isError && (
          <>
            {isImage(file.type) ? (
              <img
                src={url}
                alt={file.name}
                loading="lazy"
                className="w-full h-full object-cover transition-transform duration-200 group-hover:scale-105"
                onError={(e) => {
                  e.currentTarget.style.display = 'none';
                  setError(true);
                }}
              />
            ) : (
              <video
                src={url}
                className="w-full h-full object-cover transition-transform duration-200 group-hover:scale-105"
                onError={(e) => {
                  e.currentTarget.style.display = 'none';
                  setError(true);
                }}
              />
            )}
          </>
        )}

        {isError && (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-red-500 bg-red-50 dark:bg-red-900/20">
            <AlertTriangle className="w-8 h-8" />
            <span className="text-xs mt-2 text-center px-2 font-medium">
              Failed to load
            </span>
          </div>
        )}

        {url && isPdf(file.type) && !isError && (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-red-50 dark:bg-red-900/10">
            <FileText className="w-12 h-12 text-red-500 mb-2" />
            <span className="text-xs font-medium text-red-600 dark:text-red-400">
              PDF
            </span>
          </div>
        )}

        {!url && (
          <div className="text-gray-400 flex flex-col items-center gap-2">
            <div className="w-8 h-8 border-2 border-gray-300 border-t-gray-500 rounded-full animate-spin" />
            <span className="text-xs">Loading...</span>
          </div>
        )}

        {!isImage(file.type) &&
          !isVideo(file.type) &&
          !isPdf(file.type) &&
          url && (
            <div className="absolute inset-0 flex flex-col items-center justify-center bg-white dark:bg-slate-800">
              {getFileIcon()}
              <span className="text-xs mt-2 font-medium text-gray-600 dark:text-gray-300">
                {ext}
              </span>
            </div>
          )}

        {selectionMode && (
          <div
            className={cn(
              'absolute top-2 left-2 w-6 h-6 rounded-md border-2 flex items-center justify-center transition-all duration-200',
              selected
                ? 'bg-indigo-500 border-indigo-500'
                : 'bg-white/90 dark:bg-slate-800/90 border-gray-300 dark:border-gray-600',
              isHovered && !selected && 'border-indigo-400'
            )}
          >
            {selected && <Check className="w-4 h-4 text-white" />}
          </div>
        )}

        {onRemove && !selectionMode && (
          <button
            onClick={handleRemove}
            aria-label={`Remove ${file.name}`}
            className={cn(
              'absolute top-2 right-2 p-1.5 rounded-lg transition-all duration-200 z-10',
              showRemoveConfirm
                ? 'bg-red-500 text-white animate-pulse'
                : 'bg-white/90 dark:bg-slate-800/90 text-gray-600 hover:bg-red-500 hover:text-white opacity-0 group-hover:opacity-100'
            )}
          >
            {showRemoveConfirm ? (
              <Trash2 className="w-4 h-4" />
            ) : (
              <X className="w-4 h-4" />
            )}
          </button>
        )}
      </div>

      <div className="p-3 text-sm text-left w-full bg-white dark:bg-slate-900">
        <div
          className="truncate font-medium text-gray-900 dark:text-gray-100"
          title={file.name}
        >
          {file.name}
        </div>
        <div className="text-xs text-gray-500 dark:text-gray-400 mt-1 flex items-center gap-1.5">
          <span>{formatFileSize(file.size)}</span>
          <span className="w-1 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
          <span>{ext}</span>
        </div>
      </div>
    </div>
  );
});
