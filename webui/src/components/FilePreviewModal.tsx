import { useEffect, useState, useCallback } from 'react';
import type { FileEnriched } from '@/store';
import { isImage, isVideo, isPdf } from '@/lib/utils';
import { AlertTriangle, X } from 'lucide-react';

type Props = {
  file?: FileEnriched;
  onClose: () => void;
};

export default function FilePreviewModal({ file, onClose }: Props) {
  const [isError, setError] = useState(false);
  const [zoom, setZoom] = useState(1);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [dragStart, setDragStart] = useState<{ x: number; y: number } | null>(
    null
  );

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    },
    [onClose]
  );

  const handleWheel = useCallback((e: WheelEvent) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? -0.1 : 0.1;
    setZoom((prev) => Math.min(Math.max(prev + delta, 0.25), 4));
  }, []);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    setDragStart({ x: e.clientX, y: e.clientY });
  }, []);

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (dragStart) {
        const zoomNormalized = Math.max(1, zoom);
        const deltaX = (e.clientX - dragStart.x) / zoomNormalized;
        const deltaY = (e.clientY - dragStart.y) / zoomNormalized;
        setPosition((prev) => ({
          x: prev.x + deltaX,
          y: prev.y + deltaY,
        }));
        setDragStart({ x: e.clientX, y: e.clientY });
      }
    },
    [dragStart, zoom]
  );

  const handleMouseUp = useCallback(() => {
    setDragStart(null);
  }, []);

  useEffect(() => {
    if (dragStart) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    }
    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragStart, handleMouseMove, handleMouseUp]);

  useEffect(() => {
    setError(false);
    setZoom(1);
    setPosition({ x: 0, y: 0 });
  }, [file]);

  useEffect(() => {
    if (file) {
      document.body.style.overflow = 'hidden';
      window.addEventListener('keydown', handleKeyDown);
      document.addEventListener('wheel', handleWheel, { passive: false });
    }
    return () => {
      document.body.style.overflow = '';
      window.removeEventListener('keydown', handleKeyDown);
      document.removeEventListener('wheel', handleWheel);
    };
  }, [file, handleKeyDown, handleWheel]);

  if (!file) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 bg-black flex"
      onClick={onClose}
    >
      <button
        className="absolute top-4 right-4 z-50 bg-black/50 hover:bg-black/70 text-white rounded-full p-2 transition-colors backdrop-blur-sm"
        onClick={onClose}
        aria-label="Close preview"
      >
        <X className="w-6 h-6" />
      </button>

      <div
        className="flex-1 flex items-center justify-center p-4 select-none"
        onClick={(e) => e.stopPropagation()}
        onMouseDown={handleMouseDown}
        style={{
          cursor: dragStart ? 'grabbing' : 'grab',
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
