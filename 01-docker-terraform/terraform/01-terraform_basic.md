Terraform is a file where we can write a code to setup cloud infrastructures for our project.
Cloud resources are very expensive.
So, terraform allows us to quickly release cloud resources after use with quick command.

Easier Infrastructure lifecycle management
Add our terraform code in VCS

Terraform is IaC (Infrastructure as Code)

Main files involved:
main.tf
variables.tf
Optional: resources.tf, output.tf
.tfstate


Execution steps
1. terraform init:
        Initializes & configures the backend, installs plugins/providers, & checks out an existing configuration from a version control
2. terraform plan:
        Matches/previews local changes against a remote state, and proposes an Execution Plan.
3. terraform apply:
        Asks for approval to the proposed plan, and applies changes to cloud
4. terraform destroy
        Removes your stack from the Cloud



Instead of locally installing terraform, we can use docker image
> docker run -v $(pwd):/app -w /app hashicorp/terraform:latest init

Here, $(pwd) is a host machine location mapped to /app in terraform container. We need to map this volume because we need to make main.tf file available for terraform to process.

> pwd
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/01-docker-terraform/terraform/terraform_basic

> ls
main.tf


Remember to use a proper .gitignore to ignore your cloud credentials

> docker run --rm  -v $(pwd):/app -w /app -e GOOGLE_CREDENTIALS=./keys/my-creds.json  hashicorp/terraform:latest plan
This command will set  ./keys/my-creds.json into GOOGLE_CREDENTIALS environment variable and pass into docker container and run the command plan.

> docker run --rm -it -v $(pwd):/app -w /app -e GOOGLE_CREDENTIALS=./keys/my-creds.json hashicorp/terraform:latest apply

Here -it (Interactive Terminal) is crurial for apply. Because Terraform asks for “yes” confirmation before making changes.
 --rm : command will automatically removes the container once the command finishes, keeping your Docker environment clean.

If you use variables within terraform main.tf, you don’t need to pass GOOGLE_CREDENTIALS in command as environment variables.
You store the my-creds.json key file for you service account into your host machine in $(pwd) and store this key file in variables.tf file.


Now you can only use commands like:
> docker run - - rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest apply
> docker run - - rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest destroy
