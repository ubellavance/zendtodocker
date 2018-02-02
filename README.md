# zendtodocker
Repo of the ZendTo demo automated docker container build files

As of now, the container only prepares a basic Centos 7 container to receive the ZendTo installation.  Once final, what one would have to do to build a Docker image (and eventually run a Docker container based on this image) is to clone the repo (or get the Dockerfile), set the variables to values that make sense for the target environment, then do a `docker build` on it.

Once done, commands must be executed to create local users in the ZendTo DB, following the documentation located at http://zend.to/authentication.php#Local.
