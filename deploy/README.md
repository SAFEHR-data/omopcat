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

## Build Docker images and run the app

In the `deploy/` directory, run:

```shell
docker compose up -d --build
```

This will build the container and install the necessary dependencies to run the app.
The `-d` flag runs the `docker compose` command in "detached" mode, meaning the app will be run
in the background and you can safely quit your terminal session.

By default, the app will be hosted at `https://localhost:3838`.

