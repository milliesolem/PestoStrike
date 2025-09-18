

"""
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

"""

class Job:
    def __init__(self, job_id, job_type, first_exec_time, repeat, active, interval, report_back, report_back_port):
        pass
    
    def serialize(self):
        pass


