import type { FileEnriched } from '@/store';

type Props = {
  file?: FileEnriched;
  onClose: () => void;
};

const isImage = (type: string) => type.startsWith('image/');
const isVideo = (type: string) => type.startsWith('video/');
const isPdf = (type: string) => type === 'application/pdf';

export default function FilePreviewModal({ file, onClose }: Props) {
  if (!file) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 bg-black/70 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="relative max-w-5xl w-full max-h-full bg-transparent"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          className="absolute top-2 right-2 bg-white/80 rounded p-1 text-sm"
          onClick={onClose}
        >
          Close
        </button>

        <div className="w-full h-[80vh] flex items-center justify-center bg-black">
          {isImage(file.file.type) && (
            <img
              src={file.url}
              alt={file.file.name}
              className="max-w-full max-h-full object-contain"
            />
          )}
          {isVideo(file.file.type) && (
            <video src={file.url} controls className="max-w-full max-h-full" />
          )}
          {isPdf(file.file.type) && (
            <iframe
              src={file.url}
              title={file.file.name}
              className="w-full h-full"
            />
          )}

          {!isImage(file.file.type) &&
            !isVideo(file.file.type) &&
            !isPdf(file.file.type) && (
              <div className="text-white text-center">
                <div className="text-6xl">📄</div>
                <div className="mt-4 text-xl">{file.file.name}</div>
              </div>
            )}
        </div>
      </div>
    </div>
  );
}
