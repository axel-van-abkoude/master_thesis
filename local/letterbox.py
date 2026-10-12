from socket import socket, AF_UNIX, SOCK_STREAM
from os import unlink
PATH = '/tmp/mtd_letterbox'

# unlink(PATH)
server = socket(AF_UNIX)
server.bind(PATH)
server.listen(1)
print('Listening on UDS:', {PATH})
client_conn, client_addr = server.accept()
try:
    print('Connected: ', str(client_conn).split(", ")[0][-4:])
    while True:
        data = client_conn.recv(1024)
        if not data: break
        print('DATA:\n', data.decode(),"\n---" )
        #resp = 'This is a response'
        #connection.sendall(response.encode())
finally:
    connection.close()
    unlink(PATH)
