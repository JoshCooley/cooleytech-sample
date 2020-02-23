#!/usr/bin/env python
"""
Creates and starts an HTTP server, responding to GET requests with a page
comprised of the current GIT commit hash and the README.md rendered as HTML.
"""

import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from subprocess import run
from textwrap import TextWrapper
from markdown import markdown


def shell_out(*command: str) -> str:
    "Runs command and returns stdout"
    return run(
        command, capture_output=True, check=True, encoding='utf-8'
    ).stdout.strip()


PORT = int(os.getenv("PORT") or 8080)
GIT_URL = shell_out("git", "config", "--get", "remote.origin.url")
GIT_REPO = shell_out("basename", GIT_URL, ".git")
GIT_SHA = shell_out("git", "rev-parse", "HEAD")
README = TextWrapper(markdown(open('README.md').read(), tab_length=2),
                     initial_indent="******")

HTML = """<!doctype html>
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


if __name__ == "__main__":
    run_server()
