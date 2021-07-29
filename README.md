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

# How to use it?

## Build docker image

```bash
docker build -t image-station:v0.0.1 .
```

## Run docker container

```bash
docker run --rm -it -p 5901:5901 image-station:v0.0.1
```

Now point your browser to http://YOUR-IP:5901 and input the password you saw on the terminal.

## Build singularity image

After buliding the docker image. Convert it to a singularity image. The following command will produce an `image-station-v0.1.0.sif` file as output.

```
sudo singularity build image-station-v0.0.1.sif docker-daemon://image-station:v0.0.1
```

## Run singularity image

```bash
singularity run /path/to/image-station-v0.1.0.sif
```

📦 The already built image is avaiabale at `/nfs/cellgeni/singularity/images/image-station-v0.0.1.sif`

## Options

#### port
Default noVNC port used it 5901. If you want to use a custom port set the environment vairable `NOVNC_PORT`.
For example:

```bash
docker run --rm -it -p 6080:6080 -e NOVNC_PORT=6080 image-station:v0.0.1

```

```bash
SINGULARITY_ENV_NOVN_PORT=6080 singularity run /path/to/image-station-v0.0.1.sif
```

#### password
A random password is generated using the user name and 4 numbers. If you want to use a custom password set the environment variabel `NOVNC_PASSWORD`
For example:
```bash
docker run --rm -it -p 5901:5901 -e NOVNC_PASSWORD=P4$$w0Rd image-station:v0.0.1

```

```bash
SINGULARITY_ENV_NOVNC_PASSWORD=P4$$w0Rd singularity run /path/to/image-station-v0.0.1.sif
```

# Additional notes

- A `$HOME/.vnc` folder will be created to store necessary files for VNC to work.

- Clipbord works using the menu provided by noVNC. At the left side of the screen, click the clipboard icon and you can use that to copy and paste content to/from the running container.

- When launching napari for the first time, it will take a while to open while it downloads cellpose data to `$HOME/.cellpose`

- Desktop menu for Jupyter Notebook won't work for docker as root user because jupyter requires the option `--allow-root` in that case. Use it from terminal like so: `jupyter notebook --allow-root --notebook-dir=/`

# Example on the farm

Launch container as a job with 4CPU and 50 GB RAM
```bash
export PATH="/software/singularity-v3.6.4/bin:${PATH}"
bsub -q basement \
  -G team999 \
  -n4 \
  -M50000 \
  -R"select[mem>50000] rusage[mem=50000] span[hosts=1]"  \
  -Is \
  singularity run -B /nfs,/lustre -B /nfs/cellgeni/image-station/:$HOME/Desktop \
  /nfs/cellgeni/singularity/images/image-station-v0.0.1.sif
```

# Example on the farm with GPU

Launch container as a job with 4CPU, 50 GB RAM with 1 GPU and 8 GB GPU RAM
```bash
export PATH="/software/singularity-v3.6.4/bin:${PATH}"
bsub -q gpu-basement \
  -G team999 \
  -n4 \
  -M50000 \
  -R"select[mem>50000] rusage[mem=50000] span[hosts=1]"  \
  -gpu "mode=shared:j_exclusive=no:gmem=8000:num=1"  \
  -Is \
  singularity run --nv -B /nfs,/lustre -B /nfs/cellgeni/image-station/:$HOME/Desktop \
  /nfs/cellgeni/singularity/images/image-station-v0.0.1.sif
```

