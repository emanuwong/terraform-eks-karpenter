from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from diagrams.aws.general import User
from diagrams.aws.management import Organizations
from diagrams.aws.compute import EKS
from diagrams.aws.database import RDS
from diagrams.aws.network import ALB, InternetGateway, NATGateway, PublicSubnet, PrivateSubnet
from diagrams.onprem.vcs import Github

with Diagram("Innovate Inc - Detailed Cloud Architecture", direction="TB", show=True, outformat="png", filename="../diagrams_img/full_architecture"):

    # Actors
    dev_user = User("Developer / Ops")
    ext_user = User("End User")

    with Cluster("AWS Organization"):
        management = Organizations("Management Account")

        with Cluster("Shared Services Account"):
            gh_actions = Custom("GitHub Actions", "../icons/github-actions.png")
            argo = Custom("ArgoCD", "../icons/argocd.png")
            ecr = Custom("ECR", "../icons/ecr.png")

        dev_user >> gh_actions >> ecr
        gh_actions >> argo

        # ======== DEV ACCOUNT ==========
        with Cluster("Dev Account"):
            with Cluster("VPC (dev)"):
                igw_dev = InternetGateway("IGW")
                alb_dev = ALB("ALB + WAF")

                with Cluster("AZs"):
                    with Cluster("Public Subnets"):
                        pub1 = PublicSubnet("AZ1")
                        pub2 = PublicSubnet("AZ2")
                        pub3 = PublicSubnet("AZ3")

                    with Cluster("Private Subnets [SG, NACL]"):
                        priv1 = PrivateSubnet("AZ1")
                        priv2 = PrivateSubnet("AZ2")
                        priv3 = PrivateSubnet("AZ3")
                        eks_dev = EKS("EKS (dev)")

                    with Cluster("Isolated Subnets [SG, NACL]"):
                        db1 = RDS("RDS AZ1")
                        db2 = RDS("RDS AZ2")
                        db3 = RDS("RDS AZ3")

                ext_user >> igw_dev >> alb_dev >> [pub1, pub2, pub3]
                pub1 >> priv1
                pub2 >> priv2
                pub3 >> priv3

                priv1 >> eks_dev
                priv2 >> eks_dev
                priv3 >> eks_dev

                eks_dev >> [db1, db2, db3]

        # ======== PROD ACCOUNT ==========
        with Cluster("Prod Account"):
            with Cluster("VPC (prod)"):
                igw_prod = InternetGateway("IGW")
                alb_prod = ALB("ALB + WAF")

                with Cluster("AZs"):
                    with Cluster("Public Subnets"):
                        pubp1 = PublicSubnet("AZ1")
                        pubp2 = PublicSubnet("AZ2")
                        pubp3 = PublicSubnet("AZ3")

                    with Cluster("Private Subnets [SG, NACL]"):
                        privp1 = PrivateSubnet("AZ1")
                        privp2 = PrivateSubnet("AZ2")
                        privp3 = PrivateSubnet("AZ3")
                        eks_prod = EKS("EKS (prod)")

                    with Cluster("Isolated Subnets [SG, NACL]"):
                        dbp1 = RDS("RDS AZ1")
                        dbp2 = RDS("RDS AZ2")
                        dbp3 = RDS("RDS AZ3")

                ext_user >> igw_prod >> alb_prod >> [pubp1, pubp2, pubp3]
                pubp1 >> privp1
                pubp2 >> privp2
                pubp3 >> privp3

                privp1 >> eks_prod
                privp2 >> eks_prod
                privp3 >> eks_prod

                eks_prod >> [dbp1, dbp2, dbp3]

        # ArgoCD deploys to both
        argo >> eks_dev
        argo >> eks_prod
