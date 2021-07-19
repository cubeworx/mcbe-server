CubeWorx Minecraft Bedrock Edition Server Image
==============

This image is a self-contained Minecraft Bedrock Edition Server with support for add-ons. It is intended for use in the upcoming CubeWork ecosystem but is also being provided for use in the Minecraft community. The image can be used standalone or combined with [manymine](https://hub.docker.com/r/illiteratealliterator/manymine) to host multiple games on the same server.

## Quickstart

```
docker run -d -it -p 19132:19132/udp -e EULA=true cubeworx/mcbe-server
```

## Configuration

The image runs with default or recommended configurations but can be highly customized through environment variables. Changing any of the environment variables from their defaults will update the server.properties file as described here: https://minecraft.fandom.com/wiki/Server.properties#Bedrock_Edition_3


### Customized Default Configuration

|                               |                                                                         |
|-------------------------------|-------------------------------------------------------------------------|
| `LEVEL_NAME="Bedrock-Level"`  | Default level name of world. Customized to remove space in default name |
| `SERVER_NAME="CubeWorx-MCBE"` | Default server name that shows up in Friends tab under LAN Games        |


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
- `WHITE_LIST`

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

The image utilizes a volume at the `/mcbe/data` path for persistent storage. This path contains `addons`, `artifacts`, `backups`, `worlds` and other custom configurations files.

You can maunt this volume on the host via docker-compose:
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


### Seeds
Seeds are special codes that can generate worlds in Minecraft when the server is launched. They cover a variety of places and provide new opportunites to build and explore. A seed can only be specified when first launching the server and once a world has been created then adding, changing, or removing the seed has no impact.
To specify a seed then use the `LEVEL_SEED` environment variable. You can search online to find seeds to play or you can set `LEVEL_SEED=random` and one will be pulled from the seeds.txt file included in the image.


### Add-Ons

Add-ons are ways of enhancing game play by adding custom code and features to the game. Presently supported add-ons are `behavior_packs` and `resource_packs` and end in one of these extensions: `.addons`, `.mcpack`, or `.zip`
To add an add-on to a server take the following steps:

1. Launch a new server with a volume mounted to the host.
2. Copy the compressed add-on file into the `addons` folder of the data directory on the host.
3. Restart the container for the startup script to detect the addons and add them to their respective directories.


## Warnings!!!

- Changing the `LEVEL_NAME` value after a world has been created will result in an entire new world being created.
- Add-Ons are currently an experimental feature and not guaranteed to work.  

