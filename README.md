# Bootcamp solution via Terraform

## Variables

- As tags should be used, there is variable for them with default value set to used tags.
- To achieve resources naming consistency name preffix is defined as variable
- Location is set as variable so it can be changed outside of the code when needed.
- Your user should be assigned postgres admin that is reason why user_id and user_name are defined as variable. Azuread data shoul be used instead but managed identity does not have access to Entra ID directory.

## Tasks

### Task 1

- Solution can be found in `resource-group.tf` file.

### Task 2

- Solution can be found in `vnet.tf` file.
-
- We need 30 assigneable IP addresses in each subnet. Azure has 5 reserved IP addresses. This means we need two /26 subnets, that means we need /25 address space.
- For those interested, here is mathematical solution
  $$30 = 2^{32-x}-5$$
  $$30 + 5 = 2^{32-x}$$
  $${log_2 35} = {log_2 2^{32-x}}$$
  $${log_2 35} = 32 - x$$
  $$x = 32 - {log_2 35}$$
  $$x = 32 - 5.129283$$
  $$x ≈ 26.780$$
- As subnet mask needs to be whole number we get 26. While this works it is better to use substitution method. With 27 mask we get 27 assigneable addresses so we need /26 mask for each subnet. That is why otal address space will be /25.
- One of the subnets needes to be delegated to PostgreSQL Flexible server.

### Task 3

- Solution can be found in `virtual-machine.tf` and `network.tf` files.
- `network.tf` contains public ip address and network interface card that will be assigned to virtual machine.
- `virtual-machine.tf` contains configuration of VM, that includes:
  - SKU is B2s as this fullfill requirements with lowest price.
  - Enable System assigned identity which will be used for Key Vault access.
  - Image references Windows server to fulfill requirements.
  - To not store password in repository for my admin account i am using random generator. This password can be then found in tfstate file.

### Task 4

- Solution can be found in `dns.tf` file.
- Two zones are created, one for database and other for Key vault.
- To ensure right records translation zones must be named properly:
  - For Key Vault naming is `*.privatelink.vaultcore.azure.net`
  - For PostgreSQL naming is `*.privatelink.postgres.database.azure.com`
- Both zones are linked to created VNET to ensure records are translated successfully.

### Task 5

- Solution can be found in `key-vault.tf` and `private-endpoints.tf` files.
- To satisfy requirements three parameters needs to be set in `key-vault.tf` file:
  - `enable_rbac_authorization` set to `true` so RBAC authorization is being used.
  - `sku_name` set to `premium` so Key Vault SKU is premium
  - `public_network_access_enabled` set to `false` so there is no access to Key Vault over public internet.
- Creation of private nedpoint which enables access to Key Vault via virtual network is configured in `private-endpoints.tf` file.

### Task 6

- Solution can be found in `postgre.tf` file.
- To satisfy requirments few things needs to be configured:
  - `public_network_access_enabled` set to `false` so there is no access to database over public internet.
  - `delegated_subnet_id` set to id of subnet delegated to PostgreSQL for VNET injection.
  - `private_dns_zone_id` set to id of private DNS zone created for PostgreSQL flexible servers.
  - `storage_mb` set to `32768` to ensure capacity is 32GB.
- There is also `azurerm_postgresql_flexible_server_active_directory_administrator` resource which add our user as administrator of db.

### Task 7

- Solution can be found in `nsg.tf`
- We create one new rule that allows inbound connections to port 3389 (RDP).
- No need to specify deny all inbound connections as those are denied by default in NSG, also inter VNET communication is allowed.
- This NSG needs to be associated with subnet where VM is placed.

### Task 8

- Solution can be found in `rbac.tf` file.
- We need to assign role `Key Vault Secrets Officer` to system managed identity which is created with Virtual Machine.

### Task 9

- Download `main.py` and `requirements.txt` to your computer
- Connect via RDP ti Windows VM that you have created.
- Copy downloaded files into VM
- Install Python inside VM, this can be done via powershell as follows:

```powershell
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe" -OutFile "c:/temp/python-3.12.4-amd64.exe"
c:/temp/python-3.12.4-amd64.exe /quiet InstallAllUsers=0 InstallLauncherAllUsers=0 PrependPath=1 Include_test=0
```

- Ensure Python is installed and added to the system PATH by running `python`
- As script needs to environment variables set them the way you want, here is powershell example:

```powershell
$Env:KV_URI = 'https://<vault_name>.vault.azure.net'
$Env:SECRET_VALUE = 'examplevalue'
```

- run following commands:

```
pip install -r requirements.txt
python main.py
```

- You can check that secret is created by accessing key vault inside VM. Dont forget to assign yourself needed role.

### Task 10

- As you have configured your user account you should be able to connect to database with your Entra ID account (This will not work for Guest accounts.)
- Download software of your choice for database connection.
- Hostname is
- Password is not your account's password. Token is needed. You can generate it with az cli:

```
az account get-access-token --resource-type oss-rdbms

```

- After you have a token use it as a passowrd.

## Bonus Tasks

### Task 1

- Solution can be found in `log-analytics.tf`, `data-collection.tf` and `vm-extensions.tf` files.
- Log Analytics Workspace needs to be deployed, it is a place where metrics will be send.
- Azure Monitoring Agent needs to be installed. This is done via VM extension. Same applies to Dependancy agent.
- Data collection rule needs to be created, this tells monitoring agent what to collect and where to send collected data.
- This collection rule needs to be associated with resource, where it will be applied, in our case it is created VM.

### Task 2

- There are multiple CI/CD solutions. This one is for Github Actions
- First, we will need User Assigned Managed Identity (UAMI), UAMI uses OpenID Connect for authN. Service principal can use same mechanism.
- UAMI needs to have required roles assigned, in our case Contributor and User role access admin should be enough.
- If you have state file located in container in storage account, UAMI should habe storage blob data contributor role.
- There are two pipelines `terraform.yaml` and tf-destroy.yaml`. Both includes set of environment variables that needs to be set
  - `ARM_SUBSCRIPTION_ID` - Terraform reads this variable to get info about subscription id
  - `ARM_TENANT_ID` - Terraform reads this variable to get info about tenant id
  - `ARM_CLIENT_ID` - Terraform reads this variable to get info about UAMI ID that will be used for deployment
  - `ARM_USE_AZUREAD` - This tells Terraform to use Entra ID authentication to access tfstate sotred in storage account (Default is key based authentication)
  - `ARM_USE_OIDC` - This tells Terraform that OpenID Connect authentication will be used.
  - TF*VAR*\* - You can set Terraform variables via environment variables by using TF*VAR* prefix. For example to set `user_id` variable `TF_VAR_user_id` environment variable is set.
- All the variables are set as repository secrets so they are not publicly visible. You can read more about Github secrets [here](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions).
- Terraform plan runs everytime new pull request to main branch is created. This will check changes made to the code.
- Terraform apply can be triggered manually or is being run automatically whenever there is a new commit to main branch (this includes marged pull request).
- Terraform destry can be triggered manually.

### Task 3

- Solution can be found in `vm_extensions.tf` file.
- To install Python provided `installPython.ps1` script in assignment repository is used.
- This script is executed via CustomScriptExtensions VM extension. Script's content is passed as URI.
