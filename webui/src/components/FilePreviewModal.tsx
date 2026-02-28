import { useEffect, useState, useCallback } from 'react';
import type { FileEnriched } from '@/store';
import { isImage, isVideo, isPdf } from '@/lib/utils';
import { useImageZoom } from '@/hooks/useImageZoom';
import { AlertTriangle, X } from 'lucide-react';

type Props = {
  file?: FileEnriched;
  onClose: () => void;
};

export default function FilePreviewModal({ file, onClose }: Props) {
  const [isError, setError] = useState(false);
  const {
    zoom,
    position,
    dragStart,
    handleMouseDown,
    reset,
    attachWheelListener,
  } = useImageZoom();

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    },
    [onClose]
  );

  useEffect(() => {
    setError(false);
    reset();
  }, [file, reset]);

  useEffect(() => {
    let cleanupWheel: (() => void) | undefined;
    if (file) {
      document.body.style.overflow = 'hidden';
      window.addEventListener('keydown', handleKeyDown);
      if (isImage(file.file.type)) {
        cleanupWheel = attachWheelListener();
      }
    }
    return () => {
      document.body.style.overflow = '';
      window.removeEventListener('keydown', handleKeyDown);
      cleanupWheel?.();
    };
  }, [file, handleKeyDown, attachWheelListener]);

  if (!file) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 bg-black flex"
      onClick={onClose}
    >
      <button
        className="absolute top-4 right-4 z-50 bg-black/50 hover:bg-black/70 text-white rounded-full p-2 transition-colors backdrop-blur-sm cursor-pointer"
        onClick={onClose}
        aria-label="Close preview"
      >
        <X className="w-6 h-6" />
      </button>

      <div
        className="flex-1 flex items-center justify-center p-4 select-none"
        onClick={(e) => e.stopPropagation()}
        onMouseDown={isImage(file.file.type) ? handleMouseDown : undefined}
        style={{
          cursor:
            isImage(file.file.type) && !isError
              ? dragStart
                ? 'grabbing'
                : 'grab'
              : 'default',
          userSelect: 'none',
        }}
      >
        {isError && (
          <div className="flex flex-col items-center justify-center text-red-500">
            <AlertTriangle className="w-16 h-16" />
            <div className="mt-4 text-xl">Failed to load</div>
          </div>
        )}
        {isImage(file.file.type) && !isError && (
          <img
            src={file.url}
            alt={file.file.name}
            className="max-w-full max-h-full object-contain select-none"
            style={{
              transform: `translate(${position.x}px, ${position.y}px) scale(${zoom})`,
            }}
            onError={() => setError(true)}
          />
        )}
        {isVideo(file.file.type) && !isError && (
          <video
            src={file.url}
            controls
            className="max-w-full max-h-full select-none"
            onError={() => setError(true)}
          />
        )}
        {isPdf(file.file.type) && !isError && (
          <iframe
            src={file.url}
            title={file.file.name}
            className="w-full h-full max-w-6xl rounded-lg shadow-2xl select-none"
          />
        )}

        {!isError &&
          !isImage(file.file.type) &&
          !isVideo(file.file.type) &&
          !isPdf(file.file.type) && (
            <div className="text-white text-center">
              <div className="text-6xl">📄</div>
              <div className="mt-4 text-xl">{file.file.name}</div>
            </div>
          )}
      </div>
    </div>
  );
}
