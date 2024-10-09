PURPLE='\033[38;5;218m'
SKY='\033[38;5;116m'
MAUVE='\033[38;5;146m'
NC='\033[0m'

info() {
    echo -e "${MAUVE}[$(date +'%H:%M:%S')] [INFO] $1${NC}"
}

success() {
    echo -e "${SKY}[$(date +'%H:%M:%S')] [SUCCESS] $1${NC}"
}

error() {
    echo -e "${PURPLE}[$(date +'%H:%M:%S')] [ERROR] $1${NC}" >&2
}