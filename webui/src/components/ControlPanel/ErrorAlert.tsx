interface ErrorAlertProps {
  error: Error | undefined;
}

export function ErrorAlert({ error }: ErrorAlertProps) {
  if (!error) return null;

  return (
    <div className="text-sm text-red-700 dark:text-red-300 bg-red-100 dark:bg-red-900/40 p-3 rounded border-l-4 border-red-600 dark:border-red-500 animate-in slide-in-from-top-2 zoom-in-95 duration-400">
      {error.message}
    </div>
  );
}
