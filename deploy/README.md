# Deploy

## Build the package

From the package root directory, run from `R`:

```r
pkgbuild::build(path = ".", dest_path = "deploy")
```

This will create a `calypso_*.tar.gz` file in the `deploy/` directory with a built version of the
package, which  will be used to install the package in the Docker container. The reasoning here
is that we have a **production** version of the package that is separate from the **development**
version. The production version would ideally be pinned to a release version, e.g. `0.1.0` and only
be updated when a new release is made, e.g. `0.1.1` or `0.2.0`. This should allow us to continue
developing the app without affecting the version that is running in production.

## Create `renv.lock.prod`

From the package root directory, run from `R`:

```r
renv::snapshot(project = ".", lockfile = "./deploy/renv.lock.prod", type = "explicit")
```

This `renv.lock.prod` file will be a subset of the `renv.lock` that is in the package root. The
latter also includes development dependencies, which are not necessary to run the app in production.

## Build Docker images and run the app

To launch the test version of the app, run:

```shell
docker compose -f docker-compose.test.yml up -d --build
```

This will run a **test** version of the production app using the synthetic data in
[`data/test_data`](../data/test_data/).

To launch the production version of the up, run:

```shell
docker compose up -d --build
```

Note that this will require to populate the [`data/prod_data`](../data/prod_data/) directory with
the necessary `parquet` files (see [`data/test_data`](../data/test_data/ for an example).

This will build the container and install the necessary dependencies to run the app.
The `-d` flag runs the `docker compose` command in "detached" mode, meaning the app will be run
in the background and you can safely quit your terminal session.

By default, the app will be hosted at `https://localhost:3838`.

Running the app on the GAE will make it available at `http://uclvlddpragae05:3838` within the UCLH
network.
