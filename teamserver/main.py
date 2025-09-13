from speck import *
from Crypto.Util.number import bytes_to_long as b2l, long_to_bytes as l2b
import os

SOCKET_KEYS = [0xdeadbeef13371337, 0xdeadbeef33013301]


import socket
import time

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 7777  # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print(f"Connected by {addr}")
        while True:
            dlength = conn.recv(2)
            if len(dlength) < 2:
                print("Nothing received, waiting...")
                time.sleep(1)
                continue
            length = (dlength[0] << 8) | dlength[1]
            print("parsed length", length)
            if length == 0:
                continue
            iv = b2l(conn.recv(8))
            encrypted_data = conn.recv(length)
            cipher = speck_ctr(SOCKET_KEYS, iv)
            pt = []
            for ct,k in zip(encrypted_data, cipher):
                pt.append(ct ^ k)
            print("Received data:", pt)

            msg = b'Hello!'
            packet = [len(msg)>>8,len(msg)&255]
            iv_bytes = os.urandom(8)
            packet += list(iv_bytes)
            iv = b2l(iv_bytes)
            cipher = speck_ctr(SOCKET_KEYS, iv)
            packet += [i^j for i,j in zip(msg, cipher)]
            conn.send(bytes(packet))


def main():
    pass


if __name__ == '__main__':
    main()





