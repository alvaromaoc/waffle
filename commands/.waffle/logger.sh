usage() {
    echo "Usage: waffle log [-l|--level (INFO|WARNING|ERROR)]"
}

while true; do
    case "$1" in
        -l|--level) level=$2; shift 2; break;;
        *)          usage; exit 1;;
    esac
done

case $level in
    "INFO")     /usr/local/bin/.waffle/json.sh "timestamp" "$(date +"%Y-%m-%dT%H:%M:%S")" "level" "INFO" "message" "$@";;
    "ERROR")    /usr/local/bin/.waffle/json.sh "timestamp" "$(date +"%Y-%m-%dT%H:%M:%S")" "level" "ERROR" "message" "$@";;
    "WARNING")  /usr/local/bin/.waffle/json.sh "timestamp" "$(date +"%Y-%m-%dT%H:%M:%S")" "level" "WARNING" "message" "$@";;
    *)          usage; exit 1;;
esac