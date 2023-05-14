[![Build](https://img.shields.io/github/workflow/status/cubeworx/mcbe-server/build-push-docker)](https://github.com/cubeworx/mcbe-server/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/cubeworx/mcbe-server.svg)](https://hub.docker.com/r/cubeworx/mcbe-server)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/cubeworx/mcbe-server?sort=semver)](https://hub.docker.com/r/cubeworx/mcbe-server)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/cubeworx/mcbe-server/latest)](https://hub.docker.com/r/cubeworx/mcbe-server)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/cubeworx/mcbe-server/blob/master/LICENSE)
[![Twitter](https://img.shields.io/twitter/follow/cubeworx?label=Follow&style=social)](https://twitter.com/intent/follow?screen_name=cubeworx)

CubeWorx Minecraft Bedrock Edition Server Image
==============

This image is a self-contained Minecraft Bedrock Edition Server with support for add-ons. It is intended for use in the upcoming CubeWorx ecosystem but is also being provided for use in the Minecraft community. The image can be used standalone or combined with [manymine](https://hub.docker.com/r/illiteratealliterator/manymine) to host multiple games on the same server.

## Quickstart

```
docker run -d -it -p 19132:19132/udp -e EULA=true cubeworx/mcbe-server
```

## Configuration

The image runs with default or recommended configurations but can be customized through environment variables. Changing any of the environment variables from their defaults will update the server.properties file as described here: https://minecraft.fandom.com/wiki/Server.properties#Bedrock_Edition_3


### Customized Default Configuration

|                               |                                                                           |
|-------------------------------|---------------------------------------------------------------------------|
| `ALLOWLIST_ENABLE="false"`    | Specify if connected players must be listed in ALLOWLIST_USERS variable   |
| `ALLOWLIST_LOOKUP="true"`     | Specify if player usernames get verified from online api or written as is |
| `ALLOWLIST_MODE="static"`     | Specify if allowlist file gets overwritten every time container starts    |
| `LEVEL_NAME="Bedrock-Level"`  | Default level name of world. Customized to remove space in default name   |
| `PERMISSIONS_LOOKUP="true"`   | Specify if player xuids get verified from online api or written as is     |
| `PERMISSIONS_MODE="static"`   | Specify if permissions file gets overwritten every time container starts  |
| `SERVER_NAME="CubeWorx-MCBE"` | Default server name that shows up under LAN Games in the Friends tab      |

### Basic Server Properties Environment Variables

The following environment variables are basic ones that you might want to change to customize the game play to your liking. 

- `ALLOW_CHEATS`
- `DIFFICULTY`
- `GAME_MODE`
- `LEVEL_NAME`
- `LEVEL_SEED`
- `LEVEL_TYPE`
- `ONLINE_MODE`
- `SERVER_NAME`
- `SERVER_PORT`

### Advanced Server Properties Environment Variables

The following environment variables are more advanced ones that you might want to change to optimize the management or performance of your server.

- `COMPRESSION_THRESHOLD`
- `CONTENT_LOG_FILE_ENABLED`
- `CORRECT_PLAYER_MOVEMENT`
- `DEFAULT_PLAYER_PERMISSION_LEVEL`
- `FORCE_GAMEMODE`
- `MAX_PLAYERS`
- `MAX_THREADS`
- `PLAYER_IDLE_TIMEOUT`
- `PLAYER_MOVEMENT_DISTANCE_THRESHOLD`
- `PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS`
- `PLAYER_MOVEMENT_SCORE_THRESHOLD`
- `SERVER_AUTHORITATIVE_BLOCK_BREAKING`
- `SERVER_AUTHORITATIVE_MOVEMENT`
- `SERVER_PORTV6`
- `TEXTUREPACK_REQUIRED`
- `TICK_DISTANCE`
- `VIEW_DISTANCE`


## Volumes

The image utilizes a volume at the `/mcbe/data` path for persistent storage. This path contains `addons`, `artifacts`, `backups`, `worlds` folders and custom configuration files.

You can mount this volume on the host via docker-compose:
```
version: '3.8'
volumes:
  mcbe-data:
    driver: local
services:
  mcbe-server:
    volumes:
    - mcbe-data:/mcbe/data
```
or via the command line:

```
docker run -d -it -p 19132:19132/udp -v $(pwd):/mcbe/data -e EULA=true cubeworx/mcbe-server
```
```
docker volume create mcbe-data
docker run -d -it -p 19132:19132/udp -v mcbe-data:/mcbe/data -e EULA=true cubeworx/mcbe-server
```

## Online Mode

If your server will not be exposed to the internet and players will only be connecting from tablets, consoles, etc. on the local network then you may want to set `ONLINE_MODE=false` so that players connecting to your server won't have to authticate. This is especially useful if you have younger children playing on tablets that don't have their own Microsoft accounts.


## Allowlist

The allowlist is the list of player usernames that are allowed to connect to your server when `ALLOWLIST_ENABLE="true"` which should be set if your server is going to be publicly accessible. By default the allowlist file gets overwritten whenever the container starts/restarts to ensure that the usernames match what is in the config.
Setting `ALLOWLIST_MODE="dynamic"` will allow allowlist changes made in the game from supported clients to be retained upon start/restart of the container. Since usernames are case-sensitive, they are verified against an xbox live API to make sure there aren't any mistakes. This lookup can be disabled by setting `ALLOWLIST_LOOKUP="false"`.
The allowlist file is generated from the names included in the `ALLOWLIST_USERS`, `OPERATORS`, `MEMBERS`, & `VISITORS`. It is not necessary to enter a username in more than one environment variable. The following example will result in five names being added to the allowlist.

```
-e ALLOWLIST_USERS=player1,player2,player3 -e OPERATORS=operator1 -e MEMBERS=member1
```

## Permissions

Permissions variables can be a list of usernames or XUIDs since the values are verified against an xbox live API when the container first starts. This lookup can be disabled by setting `PERMISSIONS_LOOKUP="false"` but then will require exact XUIDs to be entered for each user.
By default the permissions file gets overwritten whenever the container starts/restarts to ensure that the username permissions match what is in the config. Setting `PERMISSIONS_MODE="dynamic"` will allow permission changes made in the game from supported clients to be retained upon start/restart of the container.
If `ALLOWLIST_ENABLE="true"` then players in the `OPERATORS`, `MEMBERS`, or `VISITORS` will automatically be added to the server allowlist.

```
-e OPERATORS=operator1,8675309124 -e MEMBERS=member1,1234567890,member2 -e VISITORS=visitor1
```


## Seeds

Seeds are special codes that can generate worlds in Minecraft when the server is launched. They cover a variety of places and provide new opportunites to build and explore. A seed can only be specified when first launching the server and once a world has been created then adding, changing, or removing the seed has no impact.
To specify a seed then use the `LEVEL_SEED` environment variable. You can search online to find seeds to play or you can set `LEVEL_SEED=random` and one will be pulled from the seeds.txt file included in the image.


## Add-Ons

Add-ons are ways of enhancing game play by adding custom code and features to the game. Presently supported add-ons are `behavior_packs` and `resource_packs` and end in one of these extensions: `.mcaddon`, `.mcpack`, or `.zip`. For best results don't use add-ons that have spaces or special characters in the file name.
To add an add-on to a server take the following steps:

1. Launch a new server with a volume mounted to the host.
2. Copy the compressed add-on file into the `addons` folder of the data directory on the host.
3. Restart the container for the startup script to detect the addons and add them to their respective directories.

A list of add-ons that have been tested with the mcbe-server image can be found in [Addons.md](Addons.md). If you test an add-on, please consider adding it to the list.

## Warnings!!!

- Changing the `LEVEL_NAME` value after a world has been created will result in an entire new world being created.
- Add-Ons are currently an **experimental** feature and not guaranteed to work.

## Thanks

This image was initially inspired by [itzg/docker-minecraft-bedrock-server](https://github.com/itzg/docker-minecraft-bedrock-server)! He has several Minecraft related repositories so be sure to check them out!