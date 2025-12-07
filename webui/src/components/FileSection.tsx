import { useState } from 'react';
import { Button } from '@/components/ui/button';
import FileGrid from './FileGrid';
import type { FileEnriched, FileId } from '@/store';

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

  const toggleSelectIndex = (idx: FileId) => {
    setSelectedIndices((prev) => {
      const s = new Set(prev);
      if (s.has(idx)) s.delete(idx);
      else s.add(idx);
      return s;
    });
  };

  const removeSelected = () => {
    if (!files || files.length === 0) return;
    onRemoveFiles(Array.from(selectedIndices));
    setSelectedIndices(new Set());
    setSelectionMode(false);
  };

  const toggleSelectionMode = () => {
    setSelectionMode((s) => {
      if (s) setSelectedIndices(new Set());
      return !s;
    });
  };

  if (!files || files.length === 0) {
    return (
      <div className="w-full lg:w-2/3 flex items-center justify-center min-h-96 text-gray-400 dark:text-gray-500">
        No files selected
      </div>
    );
  }

  return (
    <div className="w-full lg:w-2/3 flex flex-col gap-4">
      <div className="flex items-center justify-between gap-3">
        <p className="text-sm font-medium text-gray-700 dark:text-gray-300">
          {files.length} file(s)
        </p>
        <div className="flex items-center gap-2">
          <Button
            variant={selectionMode ? 'default' : 'outline'}
            size="sm"
            onClick={toggleSelectionMode}
          >
            {selectionMode ? 'Exit' : 'Select'}
          </Button>
          {selectionMode && selectedIndices.size > 0 && (
            <Button variant="destructive" size="sm" onClick={removeSelected}>
              Delete ({selectedIndices.size})
            </Button>
          )}
        </div>
      </div>

      <FileGrid
        files={files}
        selectionMode={selectionMode}
        selectedIndices={selectedIndices}
        onToggleSelect={toggleSelectIndex}
        onOpen={onPreview}
        onRemove={(idx) => onRemoveFiles([idx])}
      />
    </div>
  );
}
