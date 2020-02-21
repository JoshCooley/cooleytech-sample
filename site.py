#!/usr/bin/env python
"""
Creates and starts an HTTP server, responding to GET requests with a page
comprised of the current GIT commit hash and the README.md rendered as HTML.
"""

import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from subprocess import run
from typing import List
from markdown import markdown


def shell_out(command: List[str]) -> str:
    "Runs command and returns stdout"
    return run(
        command, capture_output=True, check=True, encoding='utf-8'
    ).stdout.strip()


PORT = os.getenv("PORT") or 8080
GIT_URL = shell_out(["git", "config", "--get", "remote.origin.url"])
GIT_REPO = shell_out(["basename", GIT_URL, ".git"])
GIT_SHA = shell_out(["git", "rev-parse", "HEAD"])
README = markdown(open('README.md').read())

HTML = """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{}</title>
  </head>
  <body>
    <p>GIT SHA: {}</p>
    <p>
      README.md: </n>
      {}
    </p>
  </body>
</html>
""".format(GIT_REPO, GIT_SHA, README)


class MyHandler(BaseHTTPRequestHandler):
    "Only handles GET requests"
    def do_GET(self):  # pylint: disable=invalid-name
        "Return a 200 response with HTML as the body"
        self.send_response(200)
        self.end_headers()
        self.wfile.write(HTML.encode())


def run_server(server_class=HTTPServer, handler_class=MyHandler):
    "Starts HTTP server and runs forever"
    server_address = ('', PORT)
    httpd = server_class(server_address, handler_class)
    print(f'Staring server on port {PORT}')
    httpd.serve_forever()


run_server()
