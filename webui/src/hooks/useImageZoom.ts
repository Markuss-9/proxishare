import { useState, useCallback, useEffect } from 'react';

export function useImageZoom() {
  const [zoom, setZoom] = useState(1);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const [dragStart, setDragStart] = useState<{ x: number; y: number } | null>(
    null
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

  const reset = useCallback(() => {
    setZoom(1);
    setPosition({ x: 0, y: 0 });
    setDragStart(null);
  }, []);

  const attachWheelListener = useCallback(() => {
    document.addEventListener('wheel', handleWheel, { passive: false });
    return () => document.removeEventListener('wheel', handleWheel);
  }, [handleWheel]);

  return {
    zoom,
    position,
    dragStart,
    handleMouseDown,
    reset,
    attachWheelListener,
  };
}
