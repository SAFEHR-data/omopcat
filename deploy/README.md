# Deploy

## Build the package

From the package root directory, run from `R`:

```r
pkgbuild::build(path = ".", dest_path = "deploy")
```

This will create a `omopcat_*.tar.gz` file in the `deploy/` directory with a built version of the
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

## Populate the `data/prod_data` directory

Running the production version of the app requires to populate the
[`data/prod_data`](../data/prod_data/) directory with
the necessary `parquet` files (see [`data/test_data`](../data/test_data/) for an example).

We provide the [`scripts/create_prod_data.R`](../scripts/create_prod_data.R)
script to facilitate this. This script will be run automatically when building the Docker image if
the mounted data directory is found to be empty.

A few environment variables are required to run this script:

* `DB_NAME`: the name of the database to connect to
* `HOST`: the host of the database
* `PORT`: the port on which to connect to the database
* `DB_USERNAME`: the username to connect to the database
* `DB_PASSWORD`: the password to connect to the database
* `DB_CDM_SCHEMA`: the schema of the CDM database, note that this needs to have both read and write
    permissions for the user to be able to use the
    [`CDMConnector`](https://darwin-eu.github.io/CDMConnector/index.html) package

These should be defined in a local `.env` file (not git-tracked) in the `deploy/` directory.
See the `.env.sample` file for a template.

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

This will build the container and install the necessary dependencies to run the app.
The `-d` flag runs the `docker compose` command in "detached" mode, meaning the app will be run
in the background and you can safely quit your terminal session.

By default, the app will be hosted at `https://localhost:3838`.

Running the app on GAE05 will make it available at `http://uclvlddpragae05:3838` within the UCLH
network.
