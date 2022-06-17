# lockout

whitelist and password protected server mod

## Features

- Whitelist by playername
- Server password
- Server priv only

### Whitelist

Blocks any player not in the list of players (defined in `/lockout`)

> On first connect it checks if the player has `server` privs, if so it keeps them online, else it kicks them till it's properly configured

### Server Password

Shows a player on connect a formspec which asks for the server password (defined in `/lockout`), if the password was incorrect kicks them.

> If whitelist mode is enabled the server will only ask those who are on the whitelist.

### Server Priviledge Only

Blocks any player unless they have `server` privs.

> This ignores if the player is on the whitelist or not

## Setup

1. Get this mod
2. Enable this mod in the `world.mt` file (per world)
3. Go in game and issue `/lockout` to begin defining it's settings

> Additional settings are in `minetest.conf` after first run.
