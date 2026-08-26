# How `/etc/hosts` Works

`/etc/hosts` is a plain text file that provides **static, local name-to-IP mappings** —
the simplest possible form of DNS resolution, checked *before* the system goes out to
an actual DNS server.

## Format

One mapping per line:

IP_ADDRESS   HOSTNAME1  HOSTNAME2  ...

Multiple names (aliases) can point to the same IP on one line.

## How Resolution Uses It

When a program (or your shell) needs to resolve a name like `server` to an IP, the OS
consults `/etc/nsswitch.conf`, which typically says "check `files` (i.e. `/etc/hosts`)
before `dns`."

- If a match exists in `/etc/hosts`, that's used immediately — no network DNS lookup happens at all.
- If there's no match, it falls through to whatever DNS servers are configured.

## Special Case — the `127.0.1.1` Line

Most Debian/Ubuntu systems ship a self-referencing entry like:

127.0.1.1   jumpbox

`127.0.1.1` (note: not `127.0.0.1`) is a loopback address the system maps to *its own*
hostname, so local tools that resolve "my own hostname" get a stable local answer
instead of depending on a real network IP. This is exactly the line the `sed` command
in doc3 edits — updating it so each machine's own hostname/FQDN resolves correctly to
itself.

## In This Tutorial's Context

Doc3 builds a `hosts` file listing every cluster machine (`server`, `node-0`, `n
plus their real IPs and FQDNs), then appends it to `/etc/hosts` on the jumpbox **and**
on every cluster machine.

After that, any machine can resolve `server`, `node-0`, `node-1` (or
`server.kubernetes.local`, etc.) to the correct real IP address purely from this local
file — without needing any actual DNS infrastructure. That's why later steps can just
do `ssh root@server` or `curl https://server.kubernetes.local:6443` and have it
correctly everywhere.