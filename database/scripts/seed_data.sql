-- User Roles
INSERT INTO user_roles (role_name, description, created_at)
VALUES 
    ('admin', 'Administrator with full access', CURRENT_TIMESTAMP),
    ('developer', 'Software developer with repository access', CURRENT_TIMESTAMP),
    ('security', 'Security team member', CURRENT_TIMESTAMP),
    ('devops', 'DevOps engineer', CURRENT_TIMESTAMP);

-- Environment Configurations
INSERT INTO environment_configs (env_name, description, is_production, created_at)
VALUES
    ('development', 'Development environment for testing', false, CURRENT_TIMESTAMP),
    ('staging', 'Staging environment for pre-production testing', false, CURRENT_TIMESTAMP),
    ('production', 'Production environment', true, CURRENT_TIMESTAMP);

-- Security Policies
INSERT INTO security_policies (policy_name, description, is_active, severity_level, created_at)
VALUES
    ('data_encryption', 'Data must be encrypted at rest and in transit', true, 'HIGH', CURRENT_TIMESTAMP),
    ('access_control', 'Role-based access control policy', true, 'HIGH', CURRENT_TIMESTAMP),
    ('audit_logging', 'System-wide audit logging policy', true, 'MEDIUM', CURRENT_TIMESTAMP),
    ('backup_retention', 'Data backup retention policy', true, 'HIGH', CURRENT_TIMESTAMP);

-- Compliance Requirements
INSERT INTO compliance_requirements (requirement_name, description, category, deadline, created_at)
VALUES
    ('GDPR_data_protection', 'General Data Protection Regulation requirements', 'Privacy', '2025-12-31', CURRENT_TIMESTAMP),
    ('SOC2_compliance', 'SOC 2 Type II compliance requirements', 'Security', '2025-12-31', CURRENT_TIMESTAMP),
    ('HIPAA_compliance', 'Healthcare data protection requirements', 'Privacy', '2025-12-31', CURRENT_TIMESTAMP);

-- Infrastructure Components
INSERT INTO infrastructure_components (component_name, component_type, status, region, created_at)
VALUES
    ('prod-vnet', 'Virtual Network', 'ACTIVE', 'eastus2', CURRENT_TIMESTAMP),
    ('prod-keyvault', 'Key Vault', 'ACTIVE', 'eastus2', CURRENT_TIMESTAMP),
    ('prod-firewall', 'Azure Firewall', 'ACTIVE', 'eastus2', CURRENT_TIMESTAMP),
    ('prod-appgateway', 'Application Gateway', 'ACTIVE', 'eastus2', CURRENT_TIMESTAMP);

-- Monitoring Alerts
INSERT INTO monitoring_alerts (alert_name, description, severity, threshold, created_at)
VALUES
    ('high_cpu_usage', 'CPU usage exceeds 80%', 'HIGH', '80', CURRENT_TIMESTAMP),
    ('memory_pressure', 'Memory usage exceeds 90%', 'HIGH', '90', CURRENT_TIMESTAMP),
    ('security_breach', 'Security breach detection', 'CRITICAL', '1', CURRENT_TIMESTAMP),
    ('ssl_cert_expiry', 'SSL certificate expiration warning', 'MEDIUM', '30', CURRENT_TIMESTAMP);