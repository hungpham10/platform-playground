# Google Cloud Platform
## Setup Service Account
To make infrastructure works as expected we must create a new service account which will be act as the endpoint to access resource of GCP with
least privileges. To do this, we must follow these steps:

#### Step 1:
Create service account using console.cloud.google.com, we don't need to grant any specific permission, just only create a new service
account in tab: IAM & Admin > Service Accounts

#### Step 2:
Add roles `Service Account Token Creator` and `Service Usage Consumer` to account. Open tab: IAM & Admin > IAM, filter your email, if not see,
just add new one by using button +Add. Edit account by using button with pen icon on the far right of the account after fiter and peform adding
new roles.

#### Step 3:
Select the approviated project using command `gcloud config set project <the project id>`

#### Step 4:
Check if our `gcloud` cloud access and get IAM correctly with command ` gcloud iam service-accounts get-iam-policy <user-email>`

#### Step 5:
Bind your account with the service account, using this command `gcloud iam service-accounts add-iam-policy-binding <service-email>
--member="user:<user-email>" --role="roles/iam.serviceAccountTokenCreator"`

### Step 6:
Update a new file .tfvar inside environments with the new service account that we have created above.

## Setup IAP using terraform
## Setup billing using terraform
## Manage Cloud-function using terraform
