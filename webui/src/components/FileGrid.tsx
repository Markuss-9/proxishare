import type { FileEnriched, FileId } from '@/store';
import FileItem from './FileItem';

type Props = {
  files: FileEnriched[];
  selectionMode?: boolean;
  selectedIndices?: Set<FileId>;
  onToggleSelect?: (idx: FileId) => void;
  onOpen?: (idx: FileId) => void;
  onRemove?: (idx: FileId) => void;
};

export default function FileGrid({
  files,
  selectionMode,
  selectedIndices,
  onToggleSelect,
  onOpen,
  onRemove,
}: Props) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
      {files.map((f) => (
        <div key={`${f.file.name}-${f.file.size}-${f.id}`}>
          <div
            onClick={() => {
              if (selectionMode && onToggleSelect) onToggleSelect(f.id);
              else if (onOpen) onOpen(f.id);
            }}
          >
            <FileItem
              file={f.file}
              url={f.url}
              selected={selectedIndices?.has(f.id)}
              onRemove={() => {
                URL.revokeObjectURL(f.url);
                onRemove?.(f.id);
              }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}
