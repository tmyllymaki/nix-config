# Copy file to clipboard (images, videos, etc.)
# Usage: clip <file>

function clip
    if test (count $argv) -eq 0
        echo "Usage: clip <file>"
        return 1
    end

    if not test -f $argv[1]
        echo "Error: File '$argv[1]' not found"
        return 1
    end

    set -l filepath (realpath $argv[1])
    set -l ext (string lower (path extension $argv[1]))

    switch $ext
        case .jpg .jpeg
            osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as JPEG picture)"
        case .png
            osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as PNG picture)"
        case .gif
            osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as GIF picture)"
        case .tiff .tif
            osascript -e "set the clipboard to (read (POSIX file \"$filepath\") as TIFF picture)"
        case '*'
            osascript -e "set the clipboard to POSIX file \"$filepath\""
    end

    and echo "Copied '$argv[1]' to clipboard"
    or begin
        echo "Error: Could not copy file to clipboard"
        return 1
    end
end
