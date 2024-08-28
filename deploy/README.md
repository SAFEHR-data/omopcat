# Deploy

## Build the package

From the package root directory, run from `R`:

```r
pkgbuild::build(path = ".", dest_path = "deploy")
```

## Create `renv.lock.prod`

From the package root directory, run from `R`:

```r
renv::snapshot(project = ".", lockfile = "./deploy/renv.lock.prod", type = "explicit")
```

## Build Docker images

In the `deploy/` directory, run:

```shell
# Assuming R version 4.4.1
docker build -f Dockerfile.base --platform=linux/amd64 -t calypso_base:4.4.1 .
docker build -f Dockerfile --platform=linux/amd64 -t calypso:latest .
```

The `calypso_base` image acts as a cached image with most of the necessary dependencies installed,
to speed up the build process of the `calypso` image. The base image is not intended to be run and
is only expected to be rebuilt in case of major dependency changes.

Note that the `calypso` image also includes a `renv::restore()` step, so any dependencies not present
in the base image will still be installed.

## Run with `docker compose`

Define the environment variables in `.env`, using `.env.sample` as a template.
Then run:

```shell
docker compose up --build
```

to launch the app.
