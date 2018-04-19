# sagdevops-infra-docker

Author: Fabien Sanglier

A sample project created to demomnstrate how to auto-provision complete SoftwareAG environments with Docker.
In this project, you can:
 - Selectively create standalone docker images of a specific SoftwareAG product
 - Selectively create managed docker images of a specific SoftwareAG product (meaning an image that could be auto-registred and managed by Command Central)
 - Leverage docker compose sample files to:
   - Provision a Command Central managed environment at runtime, leveraging bare-bone Command Central docker images (server, node, client) 
   and running "Setup" docker instance to perform the provisionning at runtime
   (which is really the same process of provisoning products on VMs as opposed to dockjer images)
   - Provision a non-managed environment using full docker images for each of the SoftwareAG product needed i nthe environment

## Pre-requisites:

1. Of course, Docker should be installed - Check official Docker doc https://docs.docker.com/install/ for details.

2. Then, for the DB instances needed by some of the products, this project currently relies on the following solution explained at:
https://github.com/lanimall/sagdevops-dbcreator-docker

  Follow the instructions in the [README.md](https://github.com/lanimall/sagdevops-dbcreator-docker/blob/master/README.md)
to create bare Docker images Oracle DBs for IS, BPM, MWS.

And if you commit these DB creation as Docker images, you should have:
 - YOUR_REGISTRY/softwareag_dbs/is-oracle:10.1
 - YOUR_REGISTRY/softwareag_dbs/mws-oracle:10.1
 - YOUR_REGISTRY/softwareag_dbs/bpms-oracle:10.1

  And the docker image "softwareag/dbcreator" created by this project will also be useful with the runtime setup...
allowing to dynamically set product DBs on-the-fly using environment variables...
Refer to "setup_is_db" service in [docker-compose-managed-runtimesetup.yml](./docker-compose-managed-runtimesetup.yml) for details.

3. All the provisioning templates require:
    1. Connecting to a central product repository to download the binaries needed by the products and fixes to install.
  
       You'll need to update the file [environments/sag-repos.properties](environments/sag-repos.properties)
    and specify the right URLs, descriptions, and connection usename/password for the product/fix repos you'll want to use.
  
       For the username/passqword, it's perfectly valid (and frankly expected) to not want to hardcode this in the file.
    So these values can be passed via env variables with variables CC_SAG_REPO_USR and CC_SAG_REPO_PWD
    And if set, their values will be used by the scripts instead of the values in the 
    [environments/sag-repos.properties](environments/sag-repos.properties) file.
    
       To set these variables, several options are possible based on the OS you're working with.
    For linux or mac, I find that the simplest is to add these 2 variables in my  ~/.bash_profile as follow:

        ```
        export CC_SAG_REPO_USR=my_user
        export CC_SAG_REPO_PWD=my_secret_password
        ```
    
       And then, make sure you don't forget to source that file to load the variable in your shell:
    
        ```
        source ~/.bash_profile
        ```
  
       Final note: By default, it is already set to use SoftwareAG Empower central repository, which is usually a good choice
    if your machine / environment has access to the internet.
  
    2. The product licenses
     
     You'll need to add your product license files in the ./license directory, in the right subfolder 
     (since all docker images are based on Centos 7, the license must be put in the ./license/lnxamd64/ directory)
     
     NOTE: The various command central provisoning templates (as written) expect specific license alias names...
     So if you want everything to work as-is without having to modify the templates environment propoerties, I recommend you 
     follow this naming convention for the license files you put in the ./license/lnxamd64/:
     - Terracotta: "terracotta-license.key"
     - Universal Messaging: "UniversalMessaging.xml"
     - Integration Server: "Integration_Server.xml"
     - Business Rules: "Business_Rules.xml"
     - Mashzone Next Gen: "MashZoneNextGen.xml"

4. Finally, Build the "builder" image to be used by the other components
 
```
  docker-compose -f docker-compose-build.yml build
```
  
This will create 2 images for internal use only. No need to push them to a registry etc...
 - softwareag/custombuilder:10.1
 - softwareag/setupnode:10.1
 
## Quick Start

Once the requirements are done, we're ready to build some docker images and full environments.
In the following quick start, we will be provisoning an IS "stateful" cluster environment comprised of:
 - 2 Integration Servers set in cluster
 - 1 Oracle Database for IS schemas (shared accross both IS)
 - 1 Terracotta Server to managed IS cluster state

To compare the difference between a full "native docker build" versus a dynamic provisoning, I've created 2 similar compose files.

### Full Native Docker Build

Simply run:

```
docker-compose -f docker-compose-fulldocker-is_stateful.yml up
```

NOTE before running: If you intent to use a docker private registry, malke sure to update the [.env](.env) file 
with the right REGISTRY and version TAG


### Managed Command Central managed provisioning

Simply run:

```
docker-compose -f docker-compose-runtimesetup-is_stateful.yml up
```

### Differences / Advantages between full "native docker build" versus a "managed provisoning"

You'll notice that the first time these scripts run, it will take *quite a long time* (in the 10s of minites) 
FOR BOTH to pull down all the binaries and install the products and fixes etc...

But the main difference between the 2 concepts are:
 - For the full "native docker build" run, actual docker images were created for each of the products, 
 and as such, on any subsequent builds, the environment will rebuild in just a few seconds!
 
 - Another advantage of the full "native docker build" version is that these built images can be pushed to a central repository,
 giving you essentially the ability to recreate this IS Stateful environment anywhere you wish 
 (anywhere you have access to your central repository that is)

To test these advantage, you have both started these environment, try to perform a cleanup (see "Cleaning Up" below)
and re-run the docker-compose command above.

You'll notice that for the case of "Full Native Docker Build", it will take just a few seconds to create all instances and start.
But for the "Managed Command Central dynamic provisioning", it will re-do all the same work...leading to the same long start-up time.

### Private registry for the Full "native docker build"

Speaking of docker push to a private registry, simply run:

```
docker-compose -f docker-compose-fulldocker-is_stateful.yml push
```

NOTE: As defined in the [.env](.env) file, the docker-compose file will create the docker image by default with the following registry prefix:
registry.docker.tests:5000

This of course may not be your registry URL...so feel free to change it in that [.env](.env) file.

And if you've already run thew build, and waited already many precious minutes that you'll never get back, you can simply tag the newly-created 
images with your registry url for this time being...

```
docker tag registry.docker.tests:5000/softwareag/is_stateful:10.1 MY.NEW.REGISTRY:5000/softwareag/is_stateful:10.1 
docker tag registry.docker.tests:5000/softwareag/tcserver:10.1 MY.NEW.REGISTRY:5000/softwareag/tcserver:10.1
```

### Testing results

When both docker-compose are done, you should have 2 IS running and accessible at following urls:
 
 - http://localhost:5555 (IS1)
 - http://localhost:5556 (IS2)
 - https://localhost:8091/cce (Command Central -- only applicable in the case of Command Central managed provisioning)
 
If you login into each of these IS instances, you'll notice that 
 - They are both clustered with Terracotta (go to Settings > Clustering)
 - They are both connected to the Oracle DB (go to Settings > JDBC Pools and click the "Tests" icons...)

### Cleaning Up

To clean up the created instances, simply run "docker-compose down"...

For full "native docker build", Simply run:

```
docker-compose -f docker-compose-fulldocker-is_stateful.yml down
```

For Managed Command Central dynamic provisioning:

```
docker-compose -f docker-compose-runtimesetup-is_stateful.yml down
```

NOTE: when you clean up, the docker images created by "docker-compose-fulldocker-is_stateful.yml" will still be loaded...
meaning that you can easily recreate the environment by re-runing:

```
docker-compose -f docker-compose-fulldocker-is_stateful.yml up -d
```

And this time, it will take just a few seconds to create all instances and start.

## Building Product-Specific Docker Images

It ius also possible to build product-specific Docker Images by navigating into one of the templates folders.

### Building Terracotta docker Image

Navigate to templates/tc-layer and run:

```
docker-compose -f docker-compose-build.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/tcserver:${TAG}
 - ${REGISTRY}softwareag/tcserver_managed:${TAG}

### Building Universdal Messaginga docker Image

Navigate to templates/um-layer and run:

```
docker-compose -f docker-compose-build.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/umserver:${TAG}
 - ${REGISTRY}softwareag/umserver_managed:${TAG}
 
### Building MWS docker Image

Navigate to templates/mws-layer and run:

```
docker-compose -f docker-compose-build.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/mws_simple:${TAG}
 - ${REGISTRY}softwareag/mws_simple_managed:${TAG}
 - ${REGISTRY}softwareag/mws_bpms:${TAG}
 - ${REGISTRY}softwareag/mws_bpms_managed:${TAG}
 
### Building Integration Server docker Image

Navigate to templates/is-layer and run one of the following:

#### IS Stateful
```
docker-compose -f docker-compose-build-stateful.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/is_stateful:${TAG}
 - ${REGISTRY}softwareag/is_stateful_managed:${TAG}
 
 
#### IS Stateless

```
docker-compose -f docker-compose-build-stateless.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/is_stateless:${TAG}
 - ${REGISTRY}softwareag/is_stateless_managed:${TAG}

#### IS Stateful Messaging

```
docker-compose -f docker-compose-build-stateful-messaging.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/is_stateful_messaging:${TAG}
 - ${REGISTRY}softwareag/is_stateful_messaging_managed:${TAG}
 
### Building BPMS docker Image

Navigate to templates/bpms-layer and run:

```
docker-compose -f docker-compose-build.yml build
```

At the end (10s of minutes to give a broad idea of duration), you should have 2 images created 
(where TAG and REGISTRY are defined in the .env file in the same folder)
 - ${REGISTRY}softwareag/bpms:${TAG}
 - ${REGISTRY}softwareag/bpms_managed:${TAG}
