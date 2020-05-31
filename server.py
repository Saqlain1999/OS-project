import socket
import sys
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('localhost', 1234))
s.listen(5)
while True:
    (conn, address) = s.accept()
    text_file = sys.argv[1]+""
    with open(text_file, 'rb+') as fa:
        while True:
            data = fa.read()
            conn.send(data)
            if not data:
                break
        fa.close()
    s.close()    
    break
s.close()