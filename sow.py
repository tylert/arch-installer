#!/usr/bin/env python

# https://docs.python.org/3.5/library/http.server.html
# https://docs.python.org/2.7/library/simplehttpserver.html

from __future__ import print_function
import sys

if sys.version_info[:1] == 3:
    import http.server
    import socketserver
else:
    import SimpleHTTPServer
    import SocketServer


PORT = 8000

Handler = SimpleHTTPServer.SimpleHTTPRequestHandler

httpd = SocketServer.TCPServer(('', PORT), Handler)

print('Serving at port {0}'.format(PORT))
httpd.serve_forever()
