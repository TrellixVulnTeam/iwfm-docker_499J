## What is this for?

Running IWFM is a challenge. Normally, the process requires a number of steps to get your own
machine ready to run the executables, and run the steps by hand. This repository contains
everything that is needed to run it, and you don't even need to check this repository out:
the build image is published to [Docker Hub](https://hub.docker.com/r/ashesfall/iwfm-base).

The fact that the model is now a self-contained image means that it can be run on any public
cloud as well, so it isn't even necessary for you to tie up your own machine to do it.


## Running the Integrated Water Flow Model

Running IWFM is now a single step (after downloading docker, which is free for most users).
You'll first want to identify the model data archive you want to use. This can be found on
the California Water Department website, and as of this writing the latest data is available
at https://data.cnra.ca.gov/dataset/31f3ddf8-752a-4b04-99e0-2a9f9139817a/resource/bc00cfa5-86ac-4e95-acda-6df1f3d85a73/download/c2vsimfg_version1.01.zip

All you have to do is supply this location to the simulator image, and it will complete the
process.

```
docker run -p 8080:80 -e IWFM_MODEL=https://data.cnra.ca.gov/dataset/31f3ddf8-752a-4b04-99e0-2a9f9139817a/resource/bc00cfa5-86ac-4e95-acda-6df1f3d85a73/download/c2vsimfg_version1.01.zip -it ashesfall/iwfm-base
```

The -p option here is what allows you to access the results of the simulation. By binding the
container's built in web server to port 8080 of your own machine you can simply bring up the
site http://localhost:8080 in your browser to keep an eye on any output it generates.
These pages are updated in real time, so you can monitor the entire process using just a browser.

## Cloud Deployment

First, you'll need to download Terraform, if you have not already. It is free, and available on
Windows, Linux, and Mac (Intel/ARM).

[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

On machines running windows 10, you will need to add Terraform to the system path environment variable to access 
it from command prompt or powershell. To do this, right click on the start menu and click on system. Then, on the right side of the window, click on Advanced System Settings. Then, click on the Environment Variables button in the System Properties
dialog box. Under System variables, scroll down and select Path and click new. Paste in the path to the Terraform 
executable and click Ok.

At this time, Terraform configurations have only been developed for AWS.

## Deploying to AWS

The following steps outline the process for deploying to AWS:
1. Download or clone this repository.

   From Git Bash, this can be accomplished by:
   
   ```bash
   git clone https://github.com/ashesfall/iwfm-docker.git
   ```

2. Navigate to the desired terraform deployment configuration within the terraform directory.

   Currently, there are several predefined deployment configurations using Terraform and AWS. Each is located in the 
   terraform directory of this repository.
   * **iwfm-aws** - run C2VSimFG and perform budget analytics
   * **pest-aws** - run PEST++ with C2VSimFG for parameter estimation, sensitivity analysis, or uncertainty analysis
   * **parallel-aws** - run generic container workloads in parallel


3. Create a terraform.tfvars file with deployment parameters in the configuration directory

4. Initialize and apply terraform deployment

5. When complete, detach resources from terraform to preserve and destroy deployment

### Deployment

From the command line, navigate to the directory containing the terraform.tfvars file.

Run the following commands:

```
terraform init
terraform apply
```

This will prompt you to agree with the proposed changes. After typing "yes" and pressing enter, it
will get to work deploying everything. This takes some time, but you can take a look at it in the
AWS console by visiting the "Elastic Container Service".

### Deploying C2VSimFG in AWS

Navigate to the "terraform/iwfm-aws" directory of this repository and create the terraform.tfvars.
Inside this file, you'll include all the parameters for your deployment. You can name the `resource_bucket` and
`analytics_bucket` anything you want, as long as they don't exist already. Your `analytics_bucket` is where the final results
will live so that they can be analyzed using QuickSight or another postprocessing tool. Any region is acceptable, but it 
must match your QuickSight region if you want to create dashboards.


The content of the terraform.tfvars should look similar to this:
```
prefix="iwfm"
iwfm_model="<path-to-model>/c2vsimfg_version1.01.zip"
tag="1403"
resource_bucket="iwfm-bucket-987342582"
analytics_bucket="iwfm-analytics-3523598"
analytics_title="analysis_1"
region="us-east-2"
aws_access_key="your_access_key"
aws_secret_key="your_secret_key"
```

If you are doing multiple deployments, you can distinguish between them using `prefix`, but otherwise
just leave it as "iwfm". Make sure the iwfm_model is the one you intend to run. us-east-2 is Ohio,
but any region the support AWS ECS will work for the deployment. The tag indicates which version of
iwfm to run. It can be:
* latest, 
* 1273, or 
* 1403

if you are using the public image (you can build your own image with build.sh and specify it using the variable 'image').

The `resource_bucket` needs to be globally unique, but it can be any string. Same with the `analytics_bucket`. 
When doing multiple analyses, you can use the `analytics_title` to distinguish them. This is
necessary to do if you are going to detach the analysis from the running system (as described in the
cleanup section below) - otherwise, there will be an error during the deployment since it will not
let you write over your last analysis.

Now, you are ready to deploy. You can initialize terraform (which will download the AWS provider),
and then apply the deployment. See the Deployment Section above.

To access your deployment, select the `prefix`-cluster in the "Elastic Container Service" dashboard.
Then select the `prefix`-service. Then finally, select the one running task inside that service. The
info on the task will display its public IP address, which you can use to reach the deployment
from any browser using http://public.ip.address, where public.ip.address is the address for
that task.

If you visit "Cloud Watch" in the AWS console, you should see a dashboard created called
`prefix`-dashboard, where you can monitor the performance and log output of the project.

### Cleaning Up

#### Production
Once the process is over, you'll need to detach the results to hang on to them before you take down
the deployment. The steps for that are shown below. Simply examine the terraform state for the resources
corresponding to results, and after confirming that they are attached, detach them with the **state rm**
command. The three resources that hold results are the analytics database, workgroup, and bucket.

```bash
# list all resources
terraform state list

# remove the analytics resources that you want to keep
terraform state rm aws_athena_database.main
terraform state rm aws_athena_workgroup.main
terraform state rm aws_s3_bucket.db
```

When you are done, and detached analytics results from your deployment, you can destroy the deployment.

```bash
terraform destroy
```

#### Development
During development or testing, it may be necessary to destroy without detaching the analytics results from the deployment.
For this case, you can skip the terraform state commands and destroy the deployment.

```bash
terraform destroy
```

#### Clean-Up Detached Resources
In other cases, you may want to delete analytics resources after you have already detached them from the terraform
deployment. In these cases, you will need to delete following the same order to minimize errors. 

First, delete the Athena database by going to the Amazon Athena Service in AWS. In the menu on the left side, go to 
Data Sources, click on the appropriate data source name. Then, click on the appropriate database name. First delete 
any associated tables by selecting them and clicking the delete button. If successful, then delete the database by 
clicking the delete button. If you run into errors with either the tables or database, you can click the edit button 
instead. This takes you to AWS Glue where you can force deletion of the tables and/or database.

Second, delete the Athena Workgroup by clicking on Workgroups in the left side menu within the Amazon Athena Service.
Go to the appropriate workgroup name and click the delete button.

Last, delete the AWS S3 Bucket. Navigate to the Amazon S3 Service in AWS. Select the one with the same name as the
```analytics_bucket``` provided in the terraform.tfvars file. In order to delete the S3 bucket, it needs to be empty, 
so select all the contents and click delete. Follow the steps on-screen to confirm the delete. Once successful, return 
to the main Amazon S3 Service page and select the analytics bucket and click delete.

## Deploying PEST++ to AWS

Navigate to the "terraform/pest-aws" directory of this repository and create the terraform.tfvars.

There are a couple parameters you can supply, `pest_cmd` and `instance_root_volume_size`. `pest_cmd` controls which PEST++ executable
is used. It defaults to 'glm'. PEST++ uses a lot of disk space, so you'll need to make sure you have enough available. The default is 
4000gb, but as you can see it can be changed here using `instance_root_volume_size`. The entire process will fail if you don't have 
enough space, so if you are trying to cut costs by reducing it, make sure you know what you're doing. 

An example of variables for pest++ is shown below.

```
prefix="iwfm-pest"
pest_cmd="ies"
iwfm_model="<path-to-model>/c2vsimfg_version1.01.zip"
tag="1403"
resource_bucket="iwfm-bucket-487336382"
analytics_bucket="iwfm-analytics-65635398"
analytics_title="analysis_1"
instance_root_volume_size="4000"
region="us-east-2"
aws_access_key="your_access_key"
aws_secret_key="your_secret_key"
```

When you are done, and detached analytics results from your deployment, you can destroy the deployment.

```
terraform destroy
```

## Deploying custom parallel model processes to AWS

Follow the same instructions for deploying the IWFM model, but use the directory terraform/parallel-aws.
This process is a little more complex, as the model zip must have a file called control.sh at the top level.
This file indicates exactly what you want to do, and what parts of it can be done in parallel. An example
is shown below.

```
#!
cp FilesToCopy/1980_PUMPING_01.DAT "/Simulation\Groundwater\C2VSimFG_PumpRates.dat"
cp FilesToCopy/1980_WELLSPEC_01.DAT "/Simulation\Groundwater\C2VSimFG_WellSpec.dat"
/run_model.sh "Run 001"
#!
cp FilesToCopy/1980_PUMPING_02.DAT "/Simulation\Groundwater\C2VSimFG_PumpRates.dat"
cp FilesToCopy/1980_WELLSPEC_02.DAT "/Simulation\Groundwater\C2VSimFG_WellSpec.dat"
/run_model.sh "Run 002"
#!
cp FilesToCopy/1980_PUMPING_03.DAT "/Simulation\Groundwater\C2VSimFG_PumpRates.dat"
cp FilesToCopy/1980_WELLSPEC_03.DAT "/Simulation\Groundwater\C2VSimFG_WellSpec.dat"
/run_model.sh "Run 003"
```

This will run three processes in parallel, with 3 sequential steps in each. There is an upper-bound to the
size of this file, but it is very large and its unclear what it is. It's been tested with a 900 line script.

When deploying from Windows, running a script within control.sh will require the script to be called with the 
sh utility. e.g.

```bash
sh run_model.sh
```

There are a few systems that are built into the deployment, and can be used in control.sh without having to
be included in the model zip. These are:

- PreProcessor: This is the IWFM Preprocessor binary.
- Simulation: This is the IWFM Simulation binary.
- dos2unix: This is a utility that will convert DOS-formatted files to UNIX-formatted files.
- /run_simulation.sh: This is the script that actually runs the simulation.
- /run_model.sh: This runs the simulation and the analytics post-processing.
- /scripts/**: All the files from the postprocessing directory from this repository are included here.
- /opt/jdk-17.0.2: The JDK is installed here.
- python3: The Python3 interpreter is available, arbitrary scripts can be included in the model zip.

Anything else needs to be included in the model zip. Everything in the model zip is available at the root of
the file system.

## Deploying the Simulation to Azure

Note: Running on Azure is currently not supported, because the ephemeral space for containers is
only 15gb. The work here could be used as a starting point, but will fail due to the small size
permitted by Azure.

~~Terraform scripts are provided here to allow any Microsoft user to perform the same operation in
their Azure Cloud account. Because all the results are accessible via the browser, there is no
need to even deal with the Azure console, you can monitor the process from anywhere.~~

First you'll need to download the Azure CLI and Terraform, if you have not already. They are both
free, and supported on Windows, Linux, and Mac (Intel/ARM).

[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)

[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Next you'll need to log in to your Azure account:

```
az login
```

This will open a browser where you can complete the normal sign in process.

Then you can initialize terraform, and apply the template. Make sure to specify the ID of the Azure
subscription you want to use. Make sure to run these commands from the terraform/iwfm-azure directory
located within where ever you checked out this GitHub repository.

```
terraform init
terraform apply -var subscription_id=your_azure_subscription_id
```


## Building New Versions of the IWFM Codebase

The IWFM code is included here. If you want to make changes to it, you can check out this
repository, make your changes, and build a new image.

```
docker build . -t iwfm
```

Then you can run your new container in a similar way to above. Notice the new image name "iwfm".

```
docker run -p 8080:80 -e IWFM_MODEL=https://data.cnra.ca.gov/dataset/31f3ddf8-752a-4b04-99e0-2a9f9139817a/resource/bc00cfa5-86ac-4e95-acda-6df1f3d85a73/download/c2vsimfg_version1.01.zip -it iwfm
```
