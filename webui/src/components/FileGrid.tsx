import type { FileEnriched, FileId } from '@/store';
import FileItem from './FileItem';

type Props = {
  files: FileEnriched[];
  selectionMode?: boolean;
  selectedIndices?: Set<FileId>;
  onOpen?: (idx: FileId) => void;
  onRemove?: (idx: FileId) => void;
  onSelect?: (idx: FileId) => void;
};

export default function FileGrid({
  files,
  selectionMode,
  selectedIndices,
  onOpen,
  onRemove,
  onSelect,
}: Props) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 sm:gap-4">
      {files.map((f) => (
        <FileItem
          key={`${f.file.name}-${f.file.size}-${f.id}`}
          file={f.file}
          url={f.url}
          selected={selectedIndices?.has(f.id)}
          selectionMode={selectionMode}
          onOpen={() => onOpen?.(f.id)}
          onSelect={selectionMode ? () => onSelect?.(f.id) : undefined}
          onRemove={
            !selectionMode
              ? () => {
                  onRemove?.(f.id);
                }
              : undefined
          }
        />
      ))}
    </div>
  );
}
