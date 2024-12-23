ARG AIRFLOW_VERSION=2.10.3

FROM apache/airflow:${AIRFLOW_VERSION}

# ARG KUBE_PROVIDER_VERSION=10.0.1

# RUN pip install apache-airflow-providers-cncf-kubernetes==${KUBE_PROVIDER_VERSION}

# COPY --chown=airflow:root ./kube.config /root/.kube/config
# ENV PATH="$PATH:$HOME/.kube/plugins"

# USER root

# RUN <<EOF
#     ## util packages
#     apt update
#     apt install -y git-all
#     # apt install unzip

#     ## install kubectl
#     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#     install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#     rm kubectl

#     ## install kubelogin plugin for oidc
#     # curl -L -o kubelogin.zip https://github.com/int128/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin_linux_amd64.zip
#     # unzip kubelogin.zip -d kube-login-plugin
#     # mkdir $HOME/.kube/plugins
#     # mv -T kube-login-plugin/kubelogin $HOME/.kube/plugins/kubectl-oidc_login
#     # rm -r kube-login-plugin kubelogin.zip

#     ## install helm
#     curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# EOF

# USER airflow

RUN pip install apache-airflow-providers-cncf-kubernetes==10.0.1