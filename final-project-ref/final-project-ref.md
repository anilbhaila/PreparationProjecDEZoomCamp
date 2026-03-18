https://github.com/zacharyt-cs/reddit-data-engineering/blob/main/README.md

Let's setup Terraform
> docker run --rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest init
> docker run --rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest plan
> docker run --rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest apply
> docker run --rm -it -v $(pwd):/app -w /app hashicorp/terraform:latest destroy
