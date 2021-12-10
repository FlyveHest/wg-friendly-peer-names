# Wireguard friendly peer names
A small shellscript that makes it possible to give peers a friendlier and more readable name in the `wg` list

# Usage
Download the `wgg.sh` script, place it somewhere in your path and remember to make it executable (`chmod +x wgg.sh`)

Create the file `/etc/wireguard/peers` and add peers to it, using the following format
```
PEER-PUBLIC-KEY:FRIENDLY PEER NAME
```
example
```
0123456789abcdef0123456789abcdef0123456789a=:A friendly peer name
```
Then just use `wgg.sh` (you can rename it to wgg, or make an alias for easier usage), and then all peers with a friendly will have it listed, like the following.

```
peer: 0123456789abcdef0123456789abcdef0123456789a=
  friendly name: A friendly peer name
  endpoint: 127.0.0.1:12345
  allowed ips: 127.0.0.2/32
  latest handshake: 2 hours, 4 minutes, 15 seconds ago
  transfer: 84.60 MiB received, 94.05 MiB sent
```

# Adding unknown peers to peers file
If you run `wgg.sh -u`, all unknown peers will be added to `/etc/wireguard/peers`.

You will be prompted to enter a friendly name for each new peer found.

# Compatibility note
The script was made using bash v4.4.20 and have not been tested on any other shells.

## Alpine Linux note
Alpine needs `util-linux` and `ncurses` for this script to run. (Thanks @JPlanche)

