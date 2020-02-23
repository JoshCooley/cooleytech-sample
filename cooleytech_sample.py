#!/usr/bin/env python
"""
Creates and starts an HTTP server, responding to GET requests with a page
comprised of the current GIT commit hash and the README.md rendered as HTML.
"""

import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from bs4 import BeautifulSoup
from dulwich.repo import Repo
from markdown import markdown


def shell_out(*command: str) -> str:
    "Runs command and returns stdout"
    return run(
        command, capture_output=True, check=True, encoding='utf-8'
    ).stdout.strip()


PORT = int(os.getenv("PORT") or 8080)
PROJECT_NAME = os.getenv("PROJECT_NAME") or os.path.basename(os.getcwd())
GIT_SHA = Repo('.').head().decode()
README = markdown(open('README.md').read())
HTML = BeautifulSoup(
    """<!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>{}</title>
          </head>
          <body>
            <p>GIT SHA: {}</p>
            <div>
              <p>README.md:</p>
              {}
            </div>
          </body>
        </html>
    """.format(PROJECT_NAME, GIT_SHA, README),
    features="html.parser"
).prettify()


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


if __name__ == "__main__":
    run_server()
