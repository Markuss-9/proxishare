import { useEffect, useState } from 'react';
import { useMediaStore, type FileId } from '@/store';
import FilePreviewModal from '@/components/FilePreviewModal';
import ControlPanel from '@/components/ControlPanel';
import FileSection from '@/components/FileSection';
import { Moon, Sun } from 'lucide-react';
import { partition } from '@/lib/utils';
import { nanoid } from 'nanoid';

export default function Homepage() {
  const { files, setFiles } = useMediaStore();
  const [previewIndex, setPreviewIndex] = useState<FileId | null>(null);
  const [isDark, setIsDark] = useState(() => {
    if (typeof window === 'undefined') return false;
    return (
      localStorage.getItem('theme') === 'dark' ||
      (!localStorage.getItem('theme') &&
        window.matchMedia('(prefers-color-scheme: dark)').matches)
    );
  });

  const toggleDarkMode = () => {
    setIsDark((prev) => {
      const newValue = !prev;
      if (newValue) {
        document.documentElement.classList.add('dark');
        localStorage.setItem('theme', 'dark');
      } else {
        document.documentElement.classList.remove('dark');
        localStorage.setItem('theme', 'light');
      }
      return newValue;
    });
  };

  // Apply dark mode on mount
  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, []);

  const handleAddFiles = (newFiles: File[]) => {
    const existing = files ?? [];
    const next = [...existing];
    newFiles.forEach((f) => {
      if (
        !existing.some((e) => e.file.name === f.name && e.file.size === f.size)
      )
        next.push({
          file: f,
          url: URL.createObjectURL(f),
          id: nanoid(),
        });
    });
    setFiles(next);
  };

  const handleRemoveFiles = (ids: FileId[]) => {
    if (!files) return;
    const [filesToRemove, newFiles] = partition(files, (f) =>
      ids.includes(f.id)
    );
    filesToRemove.forEach((f) => {
      URL.revokeObjectURL(f.url);
    });
    setFiles(newFiles);
  };

  const previewFile = files?.find((f) => f.id === previewIndex);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-slate-950 p-4 transition-colors">
      <div className="w-full max-w-6xl">
        <div className="bg-white dark:bg-slate-900 rounded-lg shadow-lg overflow-hidden border border-gray-200 dark:border-slate-700">
          <div className="px-6 py-4 border-b border-gray-200 dark:border-slate-700 flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              Local Media Share
            </h1>
            <button
              onClick={toggleDarkMode}
              className="p-2 rounded-lg bg-gray-100 dark:bg-slate-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-slate-700 transition-colors"
              aria-label="Toggle dark mode"
            >
              {isDark ? <Sun size={20} /> : <Moon size={20} />}
            </button>
          </div>

          <div className="p-6 flex flex-col lg:flex-row gap-8">
            <ControlPanel onAddFiles={handleAddFiles} />
            <FileSection
              files={files}
              onRemoveFiles={handleRemoveFiles}
              onPreview={(idx) => setPreviewIndex(idx)}
            />
          </div>
        </div>
      </div>

      <FilePreviewModal
        file={previewFile}
        onClose={() => setPreviewIndex(null)}
      />
    </div>
  );
}
