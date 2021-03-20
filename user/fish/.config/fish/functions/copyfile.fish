function copyfile -d "Copy the content of a file to the clipboard"
    if test -z $argv[1]
        echo "Missing argument"
        return 1
    end
    if not test -f $argv[1]
        echo "File '$argv[1]' does not exist"
        return 1
    end
    cat $argv[1] | xclip -selection clipboard -i
end

