
### Set up `wsl`

1. Install
    ```
    wsl --install --distribution debian --no-launch
    ```

1. Set to use version 2 explicitly
    ```
    wsl --set-default-version 2
    ```

1. Log into VM
    ```
    wsl --distribution Debian
    ```

1. Install common packages that you will need
    ```bash
    sudo apt update
    sudo apt install -y git ssh net-tools dnsutils vim curl podman jq yq
    ```

1. Install brew
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

1. From inside you WSL VM, install DistroD.  This is required for K3S to run later since it need systemd to work.  This step is not required unless using WSL for local testing

    * Curl to download the install script
    ```bash
    curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
    ```

    * Update permissions for the install script so that it is executable
    ```
    chmod +x install.sh
    ```

    * Execute the install script as sudo while passing "install" as single arg
    ```
    sudo ./install.sh install
    ```

    * Make the DistroD container start at windows startup
    ```
    sudo /opt/distrod/bin/distrod enable --start-on-windows-boot
    ```

    A popup will appear asking for your **Windows** admin password, not the WSL password. 

    If you are successful, you will see 

    `[Distrod] Distrod will now start automatically on Windows startup.`

    * Exit the VM
    ```
    exit
    ```

    * Restart WSL
    ```
    wsl --terminate Debian && wsl --distribution Debian
    ```

### Configure SSH keys for github

1. Create the ssh configuration directory and "cd" into it and "pwd" to show you are in the directory
    ```
    mkdir "${HOME}/.ssh" && cd "${HOME}/.ssh" && pwd
    ```

1. Add your private key which matches your public key stored in github. you can use "nano" to create a new file, paste the key into it, and then ctrl+X and make sure to save. Since we install "VIM" when setting up our VM, we can also use that for the same process. 
    ```
    nano ssh.key # you can choose any name, I chose "ssh.key" but the name is not too important
    ```

1. Run this command to clone down *this repo and if successful, `cd` into it, print out the present working directory `pwd`, and list the contents `ls`.  You should see a bunch of yaml files (and this readme.md file!)
    ```bash
    if git clone git@github.com:jacflesher/tekton.git; then echo; cd tekton; echo; pwd; echo; ls; else echo; echo "$(tput setaf 1)git clone failed$(tput sgr0)"; fi
    ```

### Install K3S

1. Curl down the install scripts and run it
    ```bash
    curl -sfL https://get.k3s.io | sh -
    ```

1. Since we are running k3s in our local environment, lets open up the k3s config files.  
    ```bash
    sudo chmod 777 /etc/rancher/k3s/k3s.yaml
    ```
    **Warning**: *You would NOT do this step if building a server. This opens up the local system to tampering.This step is only necessary while testing k3s locally since we are not connecting from an outside client*

1. We should also configure the kube config file as if we were running on a client
    ```bash
    ln -s "/etc/rancher/k3s/k3s.yaml" "${HOME}/.kube/config"
    echo 'KUBE_CONFIG_PATH="${HOME}/.kube/config"' >> "${HOME}/.profile"
    source "${HOME}/.profile"
    ```

1. You're done! Test kubernetes!
    ```bash
    $ kubectl get nodes
    NAME              STATUS   ROLES                  AGE     VERSION
    laptop-ub89s5db   Ready    control-plane,master   6m54s   v1.29.4+k3s1
    ```

### Build your first tekton automation pipeline!

1. Install [tekton](https://tekton.dev/docs/installation/pipelines)
    ```bash
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    ```

1. Set default namespace to `tekton-pipelines` which was created when we installed tekton above
    ```bash
    sudo kubectl config set-context default --namespace tekton-pipelines
    ```

1. Verify you are indeed targeting tekton-pipelines namespace
    ```bash
    $ kubectl config get-contexts
    CURRENT   NAME      CLUSTER   AUTHINFO   NAMESPACE
    *         default   default   default    tekton-pipelines
    ```

1. Setup secrets and role based permissions
    ```
    kubectl apply -f secret.yaml
    kubectl apply -f service-account.yaml
    kubectl apply -f role.yaml
    kubectl apply -f role-binding.yaml
    ```

1. Create pipeline and tasks
    ```
    kubectl apply -f pipeline.yaml
    kubectl apply -f sample-task-1.yaml
    kubectl apply -f sample-task-2.yaml
    ```

1. Create cronjob to run pipeline on a schedule using our service account as the user. This is where you would set your schedule for when you want the automated task to run.
    ```
    kubectl apply -f cronjob.yaml
    ```

1. (Optional) Install tekton cli binary [tkn](https://github.com/tektoncd/cli/blob/main/releases.md), for pipeline specific tasks like watching it run
    ```bash
    curl -L "https://github.com/tektoncd/cli/releases/download/v0.37.0/tektoncd-cli-0.37.0_Linux-64bit.deb" --output "tkn.deb" && sudo dpkg -i "tkn.deb"
    ```