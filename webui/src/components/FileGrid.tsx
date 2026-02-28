import type { FileEnriched, FileId } from '@/store';
import FileItem from './FileItem';

type Props = {
  files: FileEnriched[];
  selectionMode?: boolean;
  selectedIndices?: Set<FileId>;
  onStartSelect?: (idx: FileId) => void;
  onMoveSelect?: (idx: FileId) => void;
  onOpen?: (idx: FileId) => void;
  onRemove?: (idx: FileId) => void;
};

export default function FileGrid({
  files,
  selectionMode,
  selectedIndices,
  onStartSelect,
  onMoveSelect,
  onOpen,
  onRemove,
}: Props) {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-3 sm:gap-4">
      {files.map((f) => (
        <FileItem
          key={`${f.file.name}-${f.file.size}-${f.id}`}
          file={f.file}
          url={f.url}
          selected={selectedIndices?.has(f.id)}
          selectionMode={selectionMode}
          onStartSelect={() => onStartSelect?.(f.id)}
          onMoveSelect={() => onMoveSelect?.(f.id)}
          onOpen={() => onOpen?.(f.id)}
          onRemove={
            !selectionMode
              ? () => {
                  URL.revokeObjectURL(f.url);
                  onRemove?.(f.id);
                }
              : undefined
          }
        />
      ))}
    </div>
  );
}
