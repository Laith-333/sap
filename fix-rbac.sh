#!/bin/bash
# ===========================================
# FIX SCRIPT FOR TERRAFORM RBAC ISSUE
# ===========================================
# 
# The problem: Terraform tries to read existing secrets during 
# state refresh BEFORE the role assignment is created.
#
# Run these steps in order:

echo "Step 1: Remove secrets from Terraform state (they'll be recreated)"
echo "======================================================================"

terraform state rm azurerm_key_vault_secret.pipelines 2>/dev/null || echo "pipelines not in state"
terraform state rm azurerm_key_vault_secret.microsoft 2>/dev/null || echo "microsoft not in state"
terraform state rm azurerm_key_vault_secret.jumbo 2>/dev/null || echo "jumbo not in state"

echo ""
echo "Step 2: Apply ONLY the role assignment first"
echo "============================================="
echo "Run: terraform apply -target=azurerm_role_assignment.kv_secrets -target=time_sleep.wait_for_rbac"

echo ""
echo "Step 3: Wait for RBAC propagation (90 seconds built into time_sleep)"
echo "====================================================================="

echo ""
echo "Step 4: Apply the rest"
echo "======================"
echo "Run: terraform apply"

echo ""
echo "============================================="
echo "ALTERNATIVE: Manual Azure CLI fix"
echo "============================================="
echo "If the above doesn't work, run this Azure CLI command BEFORE terraform plan:"
echo ""
echo "az role assignment create \\"
echo "  --role \"Key Vault Secrets Officer\" \\"
echo "  --assignee \$(az account show --query user.name -o tsv) \\"
echo "  --scope /subscriptions/e8fd00c7-068f-4e91-9d44-5e9cdaf82185/resourceGroups/SAP_Enveriment_RG/providers/Microsoft.KeyVault/vaults/peiplnessecrets123"
echo ""
echo "Then wait 60-90 seconds and run terraform plan/apply"
