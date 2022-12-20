Building a dockerized environment with FSL, SPM, ANTS, Nipype, Nilearn ... installed and ready to go.

I already built the Docker image, you can pull it from Docker Hub by first installing Docker on your system (see https://docs.docker.com/get-docker/).

# Once Docker is set up, you can pull the docker image by copy and pasting the following command into a command prompt:
docker pull olafborghi/neuro

# You can then run the Docker image in a container by pasting the following command:
'''docker run -it -v "$(pwd):/data" -p 8888:8888 --name neuro olafborghi/neuro'''

# -v "$(pwd):/data" automatically mounts your current working directory into the docker environment, this is the only "point of contact" of the container
# with your local machine, so the data and notebooks you want to work with within the container should be stored in the working directory, 
# and all data files you create in the container will be stored here as well. So you should navigate to a folder of choice (i.e., the folder, where you 
# store your MRI data) before you launch the docker container (e.g., using "cd" before pasting the above command into Powershell on Windows).

# If you want to build your own docker image (i.e., with different packages installed in it, for example also with Freesurfer), you can adapt the "Dockerfile"
# and then build it 

# download the "Dockerfile", make the changes you would like to have, and in command prompt, go to dir with "Dockerfile" and paste the following command to buld it
docker build --tag neuro .

# running the docker image in a container (token: neuro)
docker run -p 8888:8888 -it --rm neuro

# mount the current folder (working directory in power shell, folder with your fMRI data and were the notebook will be stored) to /data folder in container
docker run --rm -it -v "$(pwd):/data" -p 8888:8888 --name neuro neuro
