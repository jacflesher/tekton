### Tekton Pipeline

1. Install [podman](https://podman.io/docs/installation)

1. Install [qemu](https://www.qemu.org/download)

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools)

1. Install [minikube](https://minikube.sigs.k8s.io/docs/start/) (for local testing)

1. Install [tekton](https://tekton.dev/docs/installation/pipelines)
    ```
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    ```

1. Create free account at https://docker.io

1. Log into podman using docker.io account
    ```
    podman login docker.io
    ```

1. Build new image using the Dockerfile (the dot at the end means 'THIS DIRECTORY' so it know where to look for it if you run the command in the same place.  If not running the command in the same folder, make sure to change the .(dot) to a full path to the directory holding the "Dockerfile").  Update image reference in cronjob.yaml, and both sample-task yaml files
    ```
    podman build -t docker.io/<your-repository>/ubi9:v0.1 .
    ```
    or, you can use my image, its public. In that case, you can skip this step.

1. Start minikube
    ```
    minikube start --driver "qemu"
    ```

1. Enable minikube ingress
    ```
    minikube addons enable ingress
    ```

1. Create secret
    ```
    kubectl apply -f secret.yaml
    ```

1. Create service account 
    ```
    kubectl apply -f service-account.yaml
    ```

1. Create role permissions for service account
    ```
    kubectl apply -f role.yaml
    ```

1. Create new role binding to bind role to service account
    ```
    kubectl apply -f role-binding.yaml
    ```

1. Create pipeline
    ```
    kubectl apply -f pipeline.yaml
    ```

1. Create tasks
    ```
    kubectl apply -f sample-task-1.yaml
    kubectl apply -f sample-task-2.yaml
    ```

1. Create cronjob to run pipeline on a schedule using our service account as the user
    ```
    kubectl apply -f cronjob.yaml
    ```

1. Watch your pipeline run!
    ```
    kubectl get jobs --namespace tekton-pipelines
    ```

1. View logs
    ```
    kubectl logs job/JOB-NAME --namespace tekton-pipelines
    ```