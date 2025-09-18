

import net, os, strutils, times
import db_connector/db_sqlite
import std/json
import ../util/agent, ../util/job


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

proc register_agent(agent: Agent) =
    AGENT_TABLE[agent.agent_id] = agent
    db.exec(sql"INSERT INTO agents (id, os, machine_name, user, home_directory, is_admin) VALUES (?,?,?,?,?,?)",
    agent.agent_id, agent.machine_name, agent.user, agent.home_directory, agent.is_admin.int
    )

proc register_job(job: Job) =
    JOB_TABLE[job.job_id] = job
    db.exec(sql"INSERT INTO agents (id, type, first_exec_time, exec_time, repeat, is_admin) VALUES (?,?,?,?,?,?)",
    agent.agent_id, agent.machine_name, agent.user, agent.home_directory, agent.is_admin.int
    )




