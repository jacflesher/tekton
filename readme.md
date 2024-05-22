### Tekton Pipeline

1. Install [podman](https://podman.io/docs/installation)

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools)

1. Install [tkn](https://github.com/tektoncd/cli/blob/main/releases.md)

1. Install [minikube](https://minikube.sigs.k8s.io/docs/start/) (for local testing)

1. If using Windows, start command-prompt as Administrator

1. Create podman VM
    ```
    podman machine init
    ```

1. Start podman VM
    ```
    podman machine start
    ```

1. Start minikube local kubernetes cluster
    ```
    minikube start --driver "podman"
    ```

1. Install [tekton](https://tekton.dev/docs/installation/pipelines)
    ```
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    ```

1. Switch to new tekton namespace created in previous step
    ```
    kubectl config set-context "minikube" --namespace "tekton-pipelines"
    ```

1. Create free account at https://docker.io. If you already have an account, skip to next step.

1. Log into podman using docker.io account
    ```
    podman login docker.io
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
    kubectl get jobs
    ```

1. View logs
    ```
    kubectl get pods
    kubectl describe pod/<POD-NAME>
    ```