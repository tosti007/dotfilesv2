function open-get -d "Get the default application to open files with xdg-open"
    if test (count $argv) -ne 1
        echo "Wrong amount of arguments, should be 1."
        return 1
    end
    if not test -f $argv[1]
        echo "File '$argv[1]' does not exist"
	return 1
    end
    xdg-mime query default (xdg-mime query filetype $argv[1])
end

