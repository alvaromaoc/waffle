json_object=""

while [ $# -ge 2 ]; do
    if [ -z "$json_object" ]; then
        json_object="\"$1\": \"$2\""
    else
        json_object="$json_object, \"$1\": \"$2\""
    fi
    shift 2
done

echo "{$json_object}"