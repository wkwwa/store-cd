# demo app - developing with k8s and Gitlab CI/CD

<img width="500" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

This demo contains the code for delivering and deploying the infrastructure for an  [online store](https://gitlab.praktikum-services.ru/Stasyan/momo-store).

This stage is the second stage of a full application build-delivery cycle, using CI/CD practices.

The build and release stage is described [here](https://github.com/wkwwa/store-ci)

CD is implemented through a [Downstream Pipeline](.gitlab-ci.yml), in which three child pipelines will be executed:

+ [Deploying Yandex Cloud](terraform/.gitlab-ci.yml) and creating a Managed Service for Kubernetes cluster using Terraform.
    <details>

    <summary>To create a Managed Service for Kubernetes cluster, you need to prepare the infrastructure in advance:</summary>

    1. [Install and initialize](https://yandex.cloud/ru/docs/cli/quickstart#linux_1) Yandex Cloud command line interface.
    2. [Create a service account](https://yandex.cloud/ru/docs/iam/operations/sa/create) with rights to deploy to the cloud in the directory where the Kubernetes cluster is being created. Resources needed by the Kubernetes cluster will be created on behalf of this account.  
        ```
        # Получение идентификатора облака
        yc resource-manager cloud list

        # Получение идентификатора каталога
        yc resource-manager folder list
        
        yc iam service-account create --name service-tf
        yc resource-manager folder add-access-binding <folderID> --service-account-name service-tf --role editor
        ```
    3. [Create an authorization key](https://yandex.cloud/ru/docs/iam/operations/authorized-key/create) for the service account.
        ```
        yc iam key create \\
            --service-account-name service-tf \\
            --output sa-key.json
        ```
    4. Add the key output to the [GitLab CI/CD variables](https://docs.gitlab.com/ee/ci/variables/#for-a-project): $YC_KEY
        ```
        cat sa-key.json | pbcopy
        ```
    5. Create a service account with write permissions to the storage and an authorization key for the S3 bucket and YDB table to load Terraform states.
        ```
        yc iam service-account create --name service-s3-ybd
        yc resource-manager folder add-access-binding <folderID> --service-account-name service-s3-ybd --role storage.uploader
        yc resource-manager folder add-access-binding <folderID> --service-account-name service-s3-ybd --role ydb.editor
        yc iam access-key create --service-account-name service-s3-ybd
        ```
    6. Add the key output to the GitLab CI/CD environment variables: $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY
    7. [Create an S3 bucket](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage) and [a YDB table.](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-lock)
    8. Edit the terraform/provider.tf file, specifying the parameters for connecting to the cloud, S3, and YDB.

    </details>

+ [Deploying the online store](momo-store-chart/.gitlab-ci.yml) is done by installing a Helm package, which, after building the chart, is published and stored in the Nexus repository. The chart contains 2 subcharts: frontend and backend, which use the image of [previously prepared containers](https://gitlab.com/devops3761117/momo-store) from a private repository in Gitlab.

+ [Deploying monitoring tools Prometheus and Grafana](monitoring-tools/.gitlab-ci.yml) is done by installing a Helm chart.
    <details>

    <summary>After installation, you need to configure [Grafana](http://localhost:3000) to add Prometheus as a data source:</summary>

    1. Go to the Configuration section (the gear icon in the left menu) and select Data Sources.
    2. Add (the Add Data Source button) a data source of the Prometheus type. As a URL, you can use the address of the Kubernetes service: http://prometheus:9090.
    3. To import a dashboard into Grafana, go to the Import menu and paste the dashboard ID in the field with the title: import via grafana.com. Click the Load button.

    </details>