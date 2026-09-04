difference between / and #

They look similar but mean completely different things — one's a filesystem path, one's a prompt character.

/ — the filesystem root

This is an actual directory, the top of the entire Linux filesystem tree. Everything — /usr, /etc, /home, /root, /var — hangs off of it. When you cd /, you're navigating there like any other folder.

# — the shell prompt symbol

This isn't part of the filesystem at all. It's just a character your shell prints to indicate the privilege level of the current session:

# → you're root (UID 0), superuser
$ → you're a regular, unprivileged user

So in your prompt:

root@server:~#
root = username
@server = hostname
~ = current working directory (home dir, shorthand for /root since you're root)
# = "you have root privileges"

If you were logged in as a normal user named shiyu, the same location might show up as:

shiyu@server:~$

Same shell, same commands available — the $ vs # is just a visual cue (by convention, not enforced by anything) so you don't forget you're running as root, where mistakes are more dangerous.

Quick way to keep them straight: / is somewhere you can cd to. # is never somewhere you can go — it just tells you who you are when you're wherever you are.