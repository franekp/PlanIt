# PlanIt

### Getting started:
 * install latest docker from official package for debian:
   https://docs.docker.com/engine/installation/linux/debian/
 * install docker-compose globally on root user:
   `sudo pip install docker-compose`
 * clone this repository and cd to it

### Starting "dev server"
 * `sudo ./dev.sh` will compile frontend files, launch dev server and watch files for changes
 * watched files: python/django in src/web, sass and elm in src/frontend
 * CTRL+C twice to stop

### Starting "demo mode" with load balancing between 3 web server containers
 * `sudo ./build_demo.sh` will build the containers - any change requires this to be re-executed
 * `sudo ./run_demo.sh` will run the services
 * CTRL+C to stop

### Using the app
 * go to localhost:8000 to see web application
 * go to localhost:8000/api/ to play with REST api
