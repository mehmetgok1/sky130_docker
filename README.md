# Sky130 Docker Image

The `src` folder contains the Dockerfile, entrypoint, and wallpaper used to
build the image. Customize those files there if you want to make changes to
the Docker image.

Build the image from the source directory with:

```bash
docker build -t sky130-docker:latest src
```

Otherwise, use the published Docker Hub image:

```bash
docker pull <dockerhub-username>/sky130-docker:latest
docker run -d \
  -p 5901:5901 \
  -p 6080:6080 \
  --shm-size=2g \
  -v "$(pwd)/work:/home/beta_vlsi/work" \
  --name vlsi_test \
  <dockerhub-username>/sky130-docker:latest
```

Open `http://localhost:6080` in a browser to use the desktop through noVNC.