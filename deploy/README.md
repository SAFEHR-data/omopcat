docker build -f Dockerfile_base --platform=linux/amd64 --progress=plain -t calypso_base .
docker run -p 80:80 calypso:latest
# then go to 127.0.0.1:80
