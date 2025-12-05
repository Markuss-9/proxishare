import { useMediaStore } from '@/store';

export default function ModeToggle() {
  const { mode, setMode } = useMediaStore();

  return (
    <div className="flex flex-col gap-2">
      <label className="text-sm font-medium text-gray-700 dark:text-gray-300">
        Upload Type
      </label>
      <div className="inline-flex rounded-lg bg-gray-200 dark:bg-slate-700 p-1">
        <button
          className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
            mode === 'media'
              ? 'bg-white dark:bg-slate-800 text-gray-900 dark:text-white shadow'
              : 'text-gray-600 dark:text-gray-400'
          }`}
          onClick={() => setMode('media')}
        >
          Media
        </button>
        <button
          className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
            mode === 'files'
              ? 'bg-white dark:bg-slate-800 text-gray-900 dark:text-white shadow'
              : 'text-gray-600 dark:text-gray-400'
          }`}
          onClick={() => setMode('files')}
        >
          All Files
        </button>
      </div>
    </div>
  );
}
