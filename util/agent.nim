
type OS = enum
    WINDOWS = 0
    UBUNTU = 1
    DEBIAN = 2
    LINUX_OTHER

type Agent = object
    agent_id: string
    os: string
    machine_name: string
    user: string
    home_directory: string
    isadmin: bool




