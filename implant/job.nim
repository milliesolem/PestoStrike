

type JobType = enum
    COFF = 0
    SHELL_CMD = 1
    SHELL_SCRIPT = 2
    PYTHON_SCRIPT = 3

type Job = object
    id: int
    job_type: JobType
    first_exec_time: int # timestamp of first execution
    repeat: bool
    interval: int
    data: array[uint8]


