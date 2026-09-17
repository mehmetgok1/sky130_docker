# Sky130 Docker Image

The `src` folder contains the Dockerfile, entrypoint, and wallpaper used to
build the image. Customize those files there if you want to make changes to
the Docker image.

Build the image from the source directory with:

```bash
docker build -t desobey/beta_vlsi:latest src
```

Otherwise, use the published Docker Hub image:

```bash
docker pull desobey/beta_vlsi:latest
docker run -d --rm \
  -p 5901:5901 \
  -p 6080:6080 \
  --shm-size=2g \
  -v "$(pwd)/work:/home/beta_vlsi/work" \
  --name vlsi_test \
  desobey/beta_vlsi:latest
```
> **Important:** To make your changes permanent, replace `$(pwd)/work` in the
> `-v` option with the host directory where you want to store your work.

Open `http://localhost:6080` in a browser to use the desktop through noVNC.
**Recommended:** Use TigerVNC and connect to `localhost:5901`.