from diagrams import Diagram, Cluster
from diagrams.aws.network import InternetGateway, NATGateway, PublicSubnet, PrivateSubnet, ALB
from diagrams.aws.compute import EKS
from diagrams.aws.database import RDS

with Diagram("Network Design - VPC (per environment)", direction="TB", filename="../diagrams_img/network_design", outformat="png", show=True):

    igw = InternetGateway("Internet Gateway")
    alb = ALB("ALB (HTTPS + WAF)")

    with Cluster("Public Subnets (3 AZs)"):
        pub1 = PublicSubnet("AZ1")
        pub2 = PublicSubnet("AZ2")
        pub3 = PublicSubnet("AZ3")

    with Cluster("NAT Gateways"):
        nat1 = NATGateway("NAT AZ1")
        nat2 = NATGateway("NAT AZ2")
        nat3 = NATGateway("NAT AZ3")

    with Cluster("Private Subnets (NACL: private-nacl)"):
        priv1 = PrivateSubnet("AZ1")
        priv2 = PrivateSubnet("AZ2")
        priv3 = PrivateSubnet("AZ3")
        with Cluster("EKS Nodes [SG: workload-sg]"):
            eks = EKS("EKS")

    with Cluster("Isolated Subnets (NACL: db-nacl)"):
        with Cluster("RDS Instances [SG: rds-sg]"):
            db1 = RDS("RDS AZ1")
            db2 = RDS("RDS AZ2")
            db3 = RDS("RDS AZ3")

    # Traffic flow
    igw >> alb
    alb >> [pub1, pub2, pub3]

    pub1 >> nat1 >> priv1
    pub2 >> nat2 >> priv2
    pub3 >> nat3 >> priv3

    priv1 >> eks
    priv2 >> eks
    priv3 >> eks

    eks >> [db1, db2, db3]
