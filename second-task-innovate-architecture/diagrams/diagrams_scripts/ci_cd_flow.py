from diagrams import Diagram, Cluster
from diagrams.onprem.vcs import Github
from diagrams.custom import Custom
from diagrams.aws.compute import EKS
from diagrams.aws.general import User

with Diagram("CI/CD Pipeline + Multi-Account Deployment", direction="LR", show=True, outformat="png", filename="../diagrams_img/ci_cd_flow"):

    developer = User("Developer")

    with Cluster("App Code"):
        app_repo = Github("App Source Repo")

    with Cluster("Shared Services Account"):
        github_actions = Custom("GitHub Actions", "../icons/github-actions.png")
        scan = Custom("Security Scan", "../icons/github-actions.png")
        lint = Custom("Lint/Test", "../icons/github-actions.png")
        build = Custom("Docker Build", "../icons/github-actions.png")
        ecr = Custom("Amazon ECR", "../icons/ecr.png")
        manifests_repo = Github("Manifests Repo")
        argocd = Custom("ArgoCD", "../icons/argocd.png")

    with Cluster("Target Environments"):
        eks_dev = EKS("EKS (dev)")
        eks_prod = EKS("EKS (prod)")

    # Flow: Developer pushes code
    developer >> app_repo >> github_actions

    # CI steps in order
    github_actions >> scan >> lint >> build >> ecr
    build >> manifests_repo

    # CD Flow (GitOps)
    manifests_repo >> argocd
    argocd >> [eks_dev, eks_prod]
