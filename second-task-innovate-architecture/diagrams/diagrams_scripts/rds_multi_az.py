from diagrams import Diagram, Cluster
from diagrams.aws.database import RDS
from diagrams.aws.compute import EKS
from diagrams.aws.security import KMS
from diagrams.custom import Custom
from diagrams.aws.storage import S3
from diagrams.generic.blank import Blank

with Diagram("Database Strategy: RDS Multi-AZ with Backups", direction="LR", show=True, outformat="png", filename="../diagrams_img/rds_multi_az"):

    with Cluster("EKS Cluster"):
        app_pods = EKS("App Pods")
        sg = Custom("SG: DB Access", "../icons/sg.png")  # Puedes usar tu propio icono

    with Cluster("Private Subnets (3 AZs)"):
        rds_primary = RDS("RDS Primary\nPostgreSQL")
        rds_standby = RDS("Standby\n(Multi-AZ)")
        rds_readreplica = RDS("Read Replica\n(Optional)")

    backups = Custom("Automated Backups", "../icons/backup.png") 

    # Flow
    app_pods >> sg >> rds_primary
    rds_primary >> rds_standby
    rds_primary >> rds_readreplica
    rds_primary >> backups
