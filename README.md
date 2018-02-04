# docker-handbrake

This is a Docker container for running [HandBrake](https://handbrake.fr/), a video encoder. The container features both a UI version of HandBrake, as well as a fully-automated version. In the automated version, you drop a file into a watch directory and the container will begin encoding it, putting the resulting file into the output directory.

This docker image is available [on Docker Hub](https://hub.docker.com/r/coppit/handbrake/).

## Usage

### Interactive Method

To use this container for a user interface to HandBrake:

`docker run --name=HandBrakeUI -e WIDTH=1280 -e HEIGHT=720 -p 3389:3389 -p 8080:8080 -v /path/to/movies/dir:/media:rw -v /path/to/config:/config:rw coppit/handbrake`

In this mode, the /media path in the container is shared with the host, so put movies that you want to convert there. When you run the UI, save the output movies into the same directory so that you can access them in the host.

There are two ways to use the interactive user interface. One is to connect to the UI in your web browser with the URL http://host:8080/#/client/c/HandBrake. The second is to connect with a remote desktop client using port 3389. There are RDP clients for multiple platforms:

* Microsoft Remote Desktop for Windows (built into the OS)
* [Microsoft Remote Desktop for OS X](https://itunes.apple.com/us/app/microsoft-remote-desktop/id715768417?mt=12)
* [rdesktop for Linux](http://www.rdesktop.org/)

The second method is to point your web browser to http://<your docker host>:8080/. This will launch a web browser-based user interface.

Of course, if you change the host ports, then when you connect you'll have to specify the server as `<host ip>:<host port>`. Feel free to drop the 3389 mapping if you don't plan to use RDP, or the 8080 mapping if you don't plan to use the web browser.  

### Non-Interactive Method

If you want to run the container without a UI:

`docker run --name=HandBrakeCLI --cap-add=SYS_NICE -v /path/to/watch/dir:/watch:ro -v /path/to/output/dir:/output:rw -v /path/to/config:/config:rw coppit/handbrake`

In this mode, drop the files into /path/to/watch/dir, and they will be encoded into /path/to/output/dir.

Adding the flag `--cap-add=SYS_NICE` allows the container to run HandBrake at a lower priority.

### Both Methods

You can also combine all of the flags into one big command, to support both the UI as well as the automated conversion.

`docker run --name=HandBrake -e WIDTH=1280 -e HEIGHT=720 -p 3389:3389 -p 8080:8080 --cap-add=SYS_NICE -v /path/to/watch/dir:/watch:ro -v /path/to/output/dir:/output:rw -v /path/to/movies/dir:/media:rw -v /path/to/config:/config:rw coppit/handbrake`

## Configuration

After your container is launched the first time, a file called "HandBrake.conf" will be created in your config directory. Edit that file to change the settings that control how changes are detected in the watch folder, and how HandBrake is run. See the config file for documentation about the settings.

You can also configure these settings by setting environment variables when running the container (-e flag). Note that the environment values supercede the config file values.

With the default configuration, files written to the watch directory will be renamed and copied to the output directory. It is recommended that you do **not** overlap your watch and output directories when creating the container.

The `USE_UI` setting controls whether the user interface features are enabled. Set this to "yes" to enable the UI, which uses approximately 266MB of RAM at idle, as opposed to 31MB of RAM. On my machine it uses .16% CPU instead of .04% CPU.

## Credits

This docker container was initially based on the [sparklyballs/handbrake container](https://github.com/sparklyballs/desktop-dockers).
