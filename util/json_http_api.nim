import net, os, strutils, times
import std/json
import std/re
import tables

# yes, i did implement HTTP from scratch because Nim
# had no good http libraries that satisfied my
# requirements for this project

type HTTPMethod = enum
    GET = 0
    POST = 1
    OPTIONS = 2

proc string2httpmethod(data: string): HTTPMethod =
    if data == "GET":
        return HTTPMethod.GET
    elif data == "POST":
        return HTTPMethod.POST
    elif data == "OPTIONS":
        return HTTPMethod.OPTIONS

type HTTPRequest = object
    request_method: HTTPMethod
    path: string
    http_version: string
    headers: Table[string, string]
    body: string

type HTTPResponse = object
    status_code: int
    headers: Table[string, string]
    body: string

proc parseHTTPRequestHeaders(request_headers: string): HTTPRequest =
    let request_method: HTTPMethod = string2httpmethod(findAll(request_headers, re"[A-Z]+")[0])
    let path_string: string = findAll(request_headers, re"/\S*")[0]
    let http_version: string = findAll(request_headers, re"HTTP\/[\d\.]+")[0]
    let header_strings: seq[string] = request_headers.split('\n')
    var headers = initTable[string, string]()
    for header in header_strings:
        var pair = header.split(": ")
        if pair.len < 2:
            continue
        headers[strip(pair[0])] = strip(pair[1])
    return HTTPRequest(request_method: request_method, path: path_string, http_version: http_version, headers: headers)
    #var request_method: HTTPMethod = string2httpmethod(top[0])

proc handleHTTPRequest(client: Socket): HTTPRequest =
    var response: string = ""
    while true:
        var line: string = client.recvLine()
        if strip(line) == "":
            break
        response.add(line & '\n')
    var request: HTTPRequest = parseHTTPRequestHeaders(response)
    if "content-length" in  request.headers
        discard client.recv(request.body, request.headers["content-length"])
    return request


var socket = newSocket()
socket.bindAddr(Port(5252))
socket.listen()
var response: string = ""
echo "listening..."

var client: Socket
var address = ""
socket.acceptAddr(client, address)
echo "Connected to " & address
while true:
    var line: string = client.recvLine()
    echo "received line " & line
    if strip(line) == "":
        break
    response.add(line & '\n')
echo parseHTTPRequestHeaders(response)
socket.close()
client.close()




