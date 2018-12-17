RD-Connect CAS / LDAP / UMI containers
==================================

* `generateImages.sh` script automates the RD-Connect CAS images generation using `docker-compose build`.
* When `docker-compose up` is used to run the whole system, the initialization with a set of random passwords and self-signed certificates is done on first run.
* If you do not like `docker-compose`, `startInstances.sh` allows creating instances based on all the main images, and starting them. `stopInstances.sh` stops those instances.

Instructions
----------------------------------

1. Download the code

	```bash
	git clone https://github.com/inab/rd-connect_cas-dockerfiles.git
	```
2. Enter the directory

  	```bash
  	cd rd-connect_cas-dockerfiles
  	```
3. Create the images
  
  	```bash
  	./generateImages.sh
  	```
4. (OPTIONAL) If they do not exist, create the data volumes

	```bash
	./initDataVolumes.sh [volumes prefix]
	```

5. (OPTIONAL) If it is needed, populate the data volumes from the initial setup in the images

	```bash
	./populateDataVolumes.sh [volumes prefix]
	```

6. (OPTIONAL) If it is needed, remove previous instances based on previous images

	```bash
	./removeInstances.sh [volumes prefix]
	```

7. (OPTIONAL) Create instances based on newly built images

	```bash
	./createInstances.sh [volumes prefix]
	```

8. Start the instances, using either of these methods:
	a. Using `startInstances.sh` script (it will tell you the random credentials generated for the initial setup).
	  
		```bash
		./startInstances [volumes prefix]
		```

	b. Run the whole workflow with `docker-compose`
		
		```bash
		docker-compose up
		```