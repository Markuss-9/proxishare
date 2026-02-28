import { useRef } from 'react';
import { Upload, FolderOpen } from 'lucide-react';
import JSZip from 'jszip';

interface FileUploaderProps {
  onAddFiles: (files: File[]) => void;
}

export function FileUploader({ onAddFiles }: FileUploaderProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const folderInputRef = useRef<HTMLInputElement>(null);

  const handleSelectFolder = async (folderFiles: File[]) => {
    const zip = new JSZip();

    const folderName = folderFiles[0].webkitRelativePath.split('/')[0];
    folderFiles.forEach((file) => {
      const path = file.webkitRelativePath || file.name;
      zip.file(path, file);
    });

    const blob = await zip.generateAsync({ type: 'blob' });
    const zipFile = new File([blob], `${folderName}.zip`, {
      type: 'application/zip',
    });
    onAddFiles([zipFile]);
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.currentTarget;
    const fileList = e.target.files;
    if (!fileList || !fileList.length) return;

    const newFiles = Array.from(fileList);
    onAddFiles(newFiles);
    input.value = '';
  };

  const handleFolderSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const input = e.currentTarget;
    const fileList = e.target.files;
    if (!fileList || !fileList.length) return;

    const newFiles = Array.from(fileList);
    await handleSelectFolder(newFiles);
    input.value = '';
  };

  return (
    <div className="flex flex-col gap-3">
      <label htmlFor="file-input" className="sr-only">
        Choose Files
      </label>
      <input
        ref={fileInputRef}
        id="file-input"
        type="file"
        multiple
        onChange={handleFileSelect}
        className="sr-only"
      />

      <label htmlFor="folder-input" className="sr-only">
        Choose Folder
      </label>
      <input
        ref={folderInputRef}
        id="folder-input"
        type="file"
        {...{ webkitdirectory: '', directory: '' }}
        onChange={handleFolderSelect}
        className="sr-only"
      />

      <div className="flex flex-col sm:flex-row gap-2">
        <button
          type="button"
          onClick={() => fileInputRef.current?.click()}
          className="flex-1 sm:flex-none px-4 py-2 rounded bg-indigo-600 text-white hover:bg-indigo-700 transition-colors flex items-center justify-center gap-2"
        >
          <Upload size={18} />
          Choose Files
        </button>
        <button
          type="button"
          onClick={() => folderInputRef.current?.click()}
          className="flex-1 sm:flex-none px-4 py-2 rounded border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-slate-800 transition-colors flex items-center justify-center gap-2"
        >
          <FolderOpen size={18} />
          Choose Folder
        </button>
      </div>
    </div>
  );
}
