Run
`ssh -i ~/.ssh/kthw admin@47.131.127.144`
`ssh -i ~/.ssh/kthw admin@47.131.32.247`
`ssh -i ~/.ssh/kthw admin@13.215.53.29`
`ssh -i ~/.ssh/kthw admin@18.139.25.51`
- `-i`: stand for identity file


`sudo -i vs su - root`

Something something UBUNTU

Here's the single fixed command, broken down:

`ssh -n admin@${IP} "sudo cp /home/admin/.ssh/authorized_keys /root/.ssh/authorized_keys && sudo chmod 600 /root/.ssh/authorized_keys"`

Step 1 — get in as admin.
ssh admin@${IP} "..." logs into the target machine as the admin user (which still works fine — it was never restricted) and runs the quoted command remotely, then disconnects. Whatever's inside the quotes runs on the remote machine, not on the jumpbox.

Step 2 — sudo cp /home/admin/.ssh/authorized_keys /root/.ssh/authorized_keys
This is the actual fix. Recall the problem: root's authorized_keys file currently contains Debian's stock forced-command entry — something like:
command="echo 'Please login as the user \"admin\"...';sleep 10" ssh-rsa AAAA...
When SSH sees a command= prefix on a key, it ignores whatever you actually asked to run and executes that forced command instead — hence the message and disconnect, no matter what you do.

admin's own authorized_keys has no such restriction — it's just the plain public key, cleanly authorized. So cping that file over root's authorized_keys completely replaces the restrictive entry with the clean one. After this, when you SSH in as root, there's no forced command intercepting you anymore — it behaves like a normal key-based login.

sudo is needed because admin doesn't normally have write access to /root/.ssh/ — only root does. sudo temporarily elevates the command to run as root.

Step 3 — sudo chmod 600 /root/.ssh/authorized_keys
SSH is strict about file permissions on anything under .ssh/ — if authorized_keys is readable/writable by group or others, sshd will refuse to trust it at all (silently, as an anti-tampering measure). 600 = read/write for the owner (root) only, no access for anyone else. This isn't fixing the forced-command problem directly — it's just making sure the newly copied file has safe permissions, since a fresh cp can sometimes inherit different permission bits than the original.

Net effect: once both run, root's authorized_keys is now byte-for-byte the same trusted, unrestricted key entry that admin already had — so ssh root@${IP} behaves normally from then on.

`ssh -n`
- `-n` redirect its standard input from `/dev/null` instead of terminal (Means I won't ssh into a terminal, instead it just runs the command from dev/null)

