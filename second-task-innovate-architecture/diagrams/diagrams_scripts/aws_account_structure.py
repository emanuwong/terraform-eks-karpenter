from diagrams import Diagram, Cluster
from diagrams.aws.management import Organizations
from diagrams.aws.security import IAM
from diagrams.aws.general import Users

with Diagram("AWS Account Structure for Innovate Inc.", show=True, filename="../diagrams_img/aws_account_structure", outformat="png", direction="TB"):
    
    company = Users("Innovate Inc.")
    sso = IAM("IAM Identity Center (SSO)")
    company >> sso

    mgmt = Organizations("Management Account")
    sso >> mgmt

    with Cluster("AWS Organization"):

        with Cluster("OU: Shared Services"):
            shared = Organizations("Shared Services")

        with Cluster("OU: Workloads"):
            with Cluster("Development"):
                dev = Organizations("Development")

            with Cluster("Production"):
                prod = Organizations("Production")

        mgmt >> shared
        mgmt >> dev
        mgmt >> prod
