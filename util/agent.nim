
import Job
import std/json
import uuid

type OS = enum
    WINDOWS = 0
    UBUNTU = 1
    DEBIAN = 2
    LINUX_OTHER = 3

type Agent = object
    agent_id: string
    os: string
    machine_name: string
    user: string
    home_directory: string
    is_admin: bool
    # this is a special job that defines the communications between the agent
    # and the teamserver
    comjob: Job

proc newAgent(os: string, machine_name: string, user: string, home_directory: string, is_admin: bool): Agent =
    let agent_id: string = uuid4()
    return Agent(agent_id: agent_id, os: os, machine_name: machine_name, home_directory: home_directory, user: user, is_admin: is_admin)

proc getId(self: Agent):string = self.agent_id
proc getOS(self: Agent):string = self.os
proc getMachineName(self: Agent):string = self.machine_name
proc getUser(self: Agent):string = self.user
proc getHomeDirectory(self: Agent): string = self.home_directory
proc isAdmin(self: Agent):bool = self.is_admin
proc getComJob(self: Agent):Job = self.comjob

proc asJson(self: Agent): string =
    return $(%*{
        "agent_id": self.agent_id,
        "os": self.os,
        "user": self.user,
        "home_directory": self.home_directory,
        "is_admin": self.is_admin,
        "comjob": self.comjob.getId()
    })

export OS, Agent, newAgent, asJson, getId, getOS, getMachineName, getHomeDirectory, getUser, isAdmin, getComJob



