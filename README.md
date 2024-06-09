# Bootcamp solution via Terraform

## Variables

- As tags should be used, there is variable for them with default value set to used tags.
- To reach reosurce naming consistency name preffix is defined as variable
- Location is set as variable so it can be change outside of code when needed.
- Your user should be assigned postgres admin that is reason why user_id and user_name are defined as variable. Azuread data shoul be used instead but managed identity does not have access to Entra ID directory.

## Tasks

### Task 1

- Solution can be found in `resource-group.tf` file

### Task 2

- Solution can be found in `vnet.tf` file
-
- We need 30 assigneable IP addresses in each subnet. Azure has 5 reserved IP addresses. This means we need two /26 subnets, that means we need /25 address space.
- For those interested, here is mathematical solution
  $$30 = 2^{32-x}-5$$
  $$30 + 5 = 2^{32-x}$$
  $${log_2 35} = {log_2 2^{32-x}}$$
  $${log_2 35} = 32 - x$$
  $$x = 32 - {log_2 35}$$
  $$x = 32 - 5.129283$$
  $$ x ≈ 26.780$$
- As subnet mask needs to be whole number we get 26. While this works it is better to use substitution method. With 27 mask we get 27 assigneable addresses so we need /26 mask for each subnet. That is why otal address space will be /25.
- One of the subnets should be delegated to PostgreSQL Flexible server.

## Task 3

- Solution can be found in `virtual-machine.tf` and `network.tf` files.
- `network.tf` contains public ip address and network interface card that will be assigned to virtual machine.
- `virtual-machine.tf` contains configuration of VM, that includes:
  - SKU is B2s as this fullfill requrements with lowest price
  - Enable System assigned identity which will be used for Key Vault access
  - Image references Windows server OS to fulfill requiremnts
  - No not store password for my admin account i am using random generator. This password can be then found in tfstate file.

## Task 4

- Solution can be found in `dns.tf` file.
- Two zones are created, one for database and other for Key vault.
- To ensure right records translation zones must be named properly:
  - For Key Vault naming is `*.privatelink.vaultcore.azure.net`
  - For PostgreSQL naming is `*.privatelink.postgres.database.azure.com`
- Both zones are linked to created VNET to ensure records are translated successfully.

## Task 5

- Solution can be found in `key-vault.tf` and `private-endpoints.tf` files.
- To satisfy requirements three parameters needs to be set in `key-vault.tf` file:
  - `enable_rbac_authorization` set to `true` so RBAC authorization is being used.
  - `sku_name` set to `Premium` so Key Vault SKU is premium
  - `public_network_access_enabled` set to `false` so there is no access to Key Vault over public internet.
- Creation of private nedpoint which enables access to Key Vault via virtual network is configured in `private-endpoints.tf` file.

## Task 6

- Solution can be found in `sql.tf` file.
- To satisfy requirments few things needs to be set:
  - `public_network_access_enabled` set to `false` so there is no access to database over public internet.
  - `delegated_subnet_id` set to id of subnet delegated to PostgreSQL so VNET injection is possible.
  - `private_dns_zone_id` set to id of private `DNS zone created for PostgreSQL flexible servers.
  - `storage_mb` set to `32768` to ensure capacity is 32GB.
