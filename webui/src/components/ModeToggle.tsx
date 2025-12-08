import { cn } from '@/lib/utils';
import { useMediaStore, type ModeOptions } from '@/store';

export default function ModeToggle() {
  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
        Upload Type
      </label>
      <div className="inline-flex rounded-lg bg-gray-200 dark:bg-slate-700 p-1">
        <ModeOption id="media" label="Media" />
        <ModeOption id="all" label="All Files" />
        <ModeOption id="folder" label="Folder" />
      </div>
    </div>
  );
}

function ModeOption({ id, label }: { id: ModeOptions; label: string }) {
  const { mode, setMode } = useMediaStore();
  return (
    <button
      className={cn(
        `px-4 py-2 rounded-md text-sm font-medium transition-all`,
        mode === id
          ? 'bg-white dark:bg-slate-800 text-gray-900 dark:text-white shadow'
          : 'text-gray-600 dark:text-gray-400'
      )}
      onClick={() => setMode(id)}
    >
      {label}
    </button>
  );
}
