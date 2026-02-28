import { useState, useCallback, useRef, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import FileGrid from './FileGrid';
import type { FileEnriched, FileId } from '@/store';
import { Check, Trash2, X, Upload } from 'lucide-react';

interface FileSectionProps {
  files: FileEnriched[] | null;
  onRemoveFiles: (ids: FileId[]) => void;
  onPreview: (idx: FileId) => void;
}

export default function FileSection({
  files,
  onRemoveFiles,
  onPreview,
}: FileSectionProps) {
  const [selectionMode, setSelectionMode] = useState(false);
  const [selectedIndices, setSelectedIndices] = useState<Set<FileId>>(
    new Set()
  );
  const [isDragging, setIsDragging] = useState(false);
  const isSelectingRef = useRef(false);
  const lastSelectedRef = useRef<FileId | null>(null);

  useEffect(() => {
    if (!isDragging) {
      isSelectingRef.current = false;
      lastSelectedRef.current = null;
    }
  }, [isDragging]);

  const toggleSelectIndex = useCallback((idx: FileId) => {
    setSelectedIndices((prev) => {
      const s = new Set(prev);
      if (s.has(idx)) s.delete(idx);
      else s.add(idx);
      return s;
    });
  }, []);

  const handleStartSelect = useCallback(
    (idx: FileId) => {
      if (!selectionMode) return;
      isSelectingRef.current = true;
      setIsDragging(true);
      lastSelectedRef.current = idx;
      toggleSelectIndex(idx);
    },
    [selectionMode, toggleSelectIndex]
  );

  const handleMoveSelect = useCallback(
    (idx: FileId) => {
      if (!isSelectingRef.current || !selectionMode) return;
      if (idx === lastSelectedRef.current) return;

      lastSelectedRef.current = idx;
      toggleSelectIndex(idx);
    },
    [selectionMode, toggleSelectIndex]
  );

  const handleEndSelect = useCallback(() => {
    isSelectingRef.current = false;
    setIsDragging(false);
    lastSelectedRef.current = null;
  }, []);

  useEffect(() => {
    if (isDragging) {
      window.addEventListener('pointerup', handleEndSelect);
      window.addEventListener('pointercancel', handleEndSelect);
    }
    return () => {
      window.removeEventListener('pointerup', handleEndSelect);
      window.removeEventListener('pointercancel', handleEndSelect);
    };
  }, [isDragging, handleEndSelect]);

  const removeSelected = useCallback(() => {
    if (!files || files.length === 0) return;
    onRemoveFiles(Array.from(selectedIndices));
    setSelectedIndices(new Set());
    setSelectionMode(false);
  }, [files, selectedIndices, onRemoveFiles]);

  const toggleSelectionMode = useCallback(() => {
    setSelectionMode((s) => {
      if (s) setSelectedIndices(new Set());
      return !s;
    });
  }, []);

  const selectAll = useCallback(() => {
    if (!files) return;
    setSelectedIndices(new Set(files.map((f) => f.id)));
  }, [files]);

  if (!files || files.length === 0) {
    return (
      <div className="w-full md:w-2/3 flex items-center justify-center min-h-[200px] sm:min-h-96 text-gray-400 dark:text-gray-500">
        <div className="text-center">
          <Upload className="w-12 h-12 mx-auto mb-4 opacity-50" />
          <p className="text-lg font-medium">No files selected</p>
          <p className="text-sm mt-1 opacity-75">
            Drop files here to get started
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full md:w-2/3 flex flex-col gap-4">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          {selectionMode ? (
            <>
              <Button
                variant="outline"
                size="sm"
                onClick={selectAll}
                className="gap-1.5"
              >
                <Check className="w-4 h-4" />
                All
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={toggleSelectionMode}
                className="gap-1.5"
              >
                <X className="w-4 h-4" />
                Cancel
              </Button>
            </>
          ) : (
            <>
              <p className="text-sm font-medium text-gray-700 dark:text-gray-300">
                {files.length} file{files.length !== 1 ? 's' : ''}
              </p>
              <Button
                variant="outline"
                size="sm"
                onClick={toggleSelectionMode}
                className="gap-1.5"
              >
                <Check className="w-4 h-4" />
                Select
              </Button>
            </>
          )}
        </div>
        {selectionMode && selectedIndices.size > 0 && (
          <Button
            variant="destructive"
            size="sm"
            onClick={removeSelected}
            className="gap-1.5"
          >
            <Trash2 className="w-4 h-4" />
            Delete ({selectedIndices.size})
          </Button>
        )}
      </div>

      <FileGrid
        files={files}
        selectionMode={selectionMode}
        selectedIndices={selectedIndices}
        onStartSelect={handleStartSelect}
        onMoveSelect={handleMoveSelect}
        onOpen={onPreview}
        onRemove={(idx) => onRemoveFiles([idx])}
      />
    </div>
  );
}
