# Image Station

This container has interactive desktop access via web browser for image visualization.

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
- OMERO.insight

# How to use it?


## Run docker container

```bash
docker run --rm -it -e NOVNC_PORT=5901 -p 5901:5901 image-station:latest
```

Now point your browser to http://YOUR-IP:5901 and input the password you saw on the terminal.

## Run singularity image

```bash
singularity run  /path/to/image-station.sif
```

Now follow `Browse address` shown.

📦 The already built image is avaiabale at `/nfs/cellgeni/singularity/images/image-station-202303.sif`

```bash
singularity run  /path/to/image-station.sif
```

## Options

### custom port
By default a random free port will be used for noVNC. If you want to use a custom port set the environment vairable `NOVNC_PORT`.
For example:

```bash
docker run --rm -it -p 6080:6080 -e NOVNC_PORT=6080 image-station:latest

```

```bash
SINGULARITY_ENV_NOVN_PORT singularity run /path/to/image-station.sif
```

### custom password
A random password is generated using the user name and 4 numbers. If you want to use a custom password set the environment variabel `NOVNC_PASSWORD`
For example:
```bash
docker run --rm -it -p 5901:5901  -e NOVNC_PASSWORD=P4$$w0Rd image-station:latest

```

```bash
SINGULARITY_ENV_NOVNC_PASSWORD='P4$$w0Rd' singularity run /path/to/image-station.sif
```

# Example on the farm

Launch container as a job with 4CPU and 32 GB RAM on the long queue. 
Replace team999 with your LSF group.
```bash
export PATH="/software/singularity-v3.9.0/bin:${PATH}"
bsub -q long \
  -G team999 \
  -n4 \
  -M32000 \
  -R"select[mem>32000] rusage[mem=32000] span[hosts=1]"  \
  -Is \
  singularity run -B /nfs,/lustre \
  /nfs/cellgeni/singularity/images/image-station-202303.sif
```

# Example on the farm with GPU

Launch container as a job with 4CPU, 50 GB RAM with 1 GPU and 8 GB GPU RAM
and 32 GB RAM on the long queue. 
Replace team999 with your LSF group.
```bash
export PATH="/software/singularity-v3.9.0/bin:${PATH}"
bsub -q gpu-basement \
  -G team999 \
  -n4 \
  -M50000 \
  -R"select[mem>50000] rusage[mem=50000] span[hosts=1]"  \
  -gpu "mode=shared:j_exclusive=no:gmem=8000:num=1"  \
  -Is \
  singularity run --nv -B /nfs,/lustre \
  /nfs/cellgeni/singularity/images/image-station-202303.sif
```


# Build the image

## Build docker image

```bash
docker build -t image-station:latest .
```

## Build singularity image

After buliding the docker image. Convert it to a singularity image. The following command will produce an `image-station.sif` file as output.

```
singularity build image-station.sif docker-daemon://image-station:latest
```

# Additional notes

- A `$HOME/.vnc` folder will be created to store necessary files for VNC to work.

- Clipbord works using the menu provided by noVNC. At the left side of the screen, click the clipboard icon and you can use that to copy and paste content to/from the running container.

- Desktop menu for Jupyter Notebook won't work for docker as root user because jupyter requires the option `--allow-root` in that case. Use it from terminal like so: `jupyter notebook --allow-root --notebook-dir=/`
