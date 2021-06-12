# Imaging tools container

This container has interactive desktop access via web browser.

# How does it work?

- **xfce4** provides desktop interface.
- **VirtualGL** redirects graphics to client.
- **TurboVNC** server provides VNC access.
- **noVNC** makes VNC access via web.

# What's included?

- python (conda)
- napari
- Fiji - ImageJ
- Ilastik
- QuPath
- Jupyter notebook

# How to use it?

## Build docker image

```bash
docker build -t imaging-tools:v0.0.1 .
```

## Run docker container

```bash
docker run --rm -p 5901:5901 imaging-tools:v0.0.1
```

Now point your browser to http://YOUR-IP:5901 and input the password you saw on the terminal.

## Use as singularity image

After buliding the docker image. Convert it to a singularity image. The following command will produce an `imaging-tootls-v0.1.0.sif` file as output.

```
sudo singularity build imaging-tootls-v0.1.0.sif docker-daemon://imaging-tools:v0.0.1
```

## Run singularity image

```bash
singularity run /path/to/imaging-tootls-v0.1.0.sif
```

# Additional notes

A `.vnc` folder will be created under `$HOME` to store necessary files for VNC to work.

Clipbord works using the menu provided by noVNC. At the left side of the screen, click the clipboard icon and you can use that to copy and paste content to/from the running container. 
