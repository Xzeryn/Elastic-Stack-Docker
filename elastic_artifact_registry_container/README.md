To create Elastic Artifact Registry container:

Edit the Dockerfile and set the `ELASTIC_VERSION` to the version you desire and save the file.

Run:
`docker build -t elastic-artifact-registry:<elastic_version_number> .`

Example: to build the artifact registry for Elastic version 8.13.4 you would run
`docker build -t elastic-artifact-registry:8.13.4 .`