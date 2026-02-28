import { Button } from '@/components/ui/button';

interface ActionButtonsProps {
  onShare: () => void;
  onClear: () => void;
  uploading: boolean;
  disabled: boolean;
}

export function ActionButtons({
  onShare,
  onClear,
  uploading,
  disabled,
}: ActionButtonsProps) {
  return (
    <div className="flex flex-col sm:flex-row gap-2">
      <Button
        onClick={onShare}
        disabled={disabled}
        className="w-full sm:w-auto sm:flex-1 transition-all duration-200"
      >
        {uploading ? (
          <span className="flex items-center gap-2">
            <span className="animate-spin">⏳</span>
            Uploading...
          </span>
        ) : (
          'Share'
        )}
      </Button>
      <Button
        variant="outline"
        onClick={onClear}
        disabled={disabled}
        className="transition-all duration-200"
      >
        Clear
      </Button>
    </div>
  );
}
