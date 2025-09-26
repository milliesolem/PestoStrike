

let PREFIXES = ["i", "*", "!", "x"]

type LogLevel = enum
    INFO = 0
    SUCCESS = 1
    WARNING = 2
    ERROR = 3

type Logger = object
    debug: bool

proc newLogger(debug: bool = false): Logger = Logger(debug: debug)

proc log(self: Logger, message: string, level: LogLevel) = 
    echo "[ ", PREFIXES[level.int], " ] ", message

export Logger, log, LogLevel, newLogger