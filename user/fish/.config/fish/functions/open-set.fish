function open-set -d "Set the default application to open files with xdg-open"
    if test (count $argv) -ne 2
        echo "Wrong amount of arguments, should be 2."
        return 1
    end
    if not test -f $argv[2]
        echo "File '$argv[2]' does not exist"
	return 1
    end
    set -l desktop (fd -e desktop "$argv[1]" /usr/share/applications ~/.local/share/applications)
    if test -z "$desktop"
        echo "Could not find desktop entry '$argv[1]'"
        return 1
    end
    set -l desktop (basename $desktop)
    xdg-mime default $desktop (xdg-mime query filetype $argv[2])
end

