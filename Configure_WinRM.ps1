function Set-PSRemotingCredSSP {
    try {
        Write-Host -ForegroundColor Green "Starting configuration for PS Remoting with CredSSP..."
        Write-Host -ForegroundColor Green "Checking current network connection profiles..."
        $publicProfiles = Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq "Public" }
        if ($publicProfiles) {
            Write-Host -ForegroundColor Green "Found Public network profile(s). Changing them to Private..."
            $publicProfiles | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction Stop
            Write-Host -ForegroundColor Green "Network profiles updated to Private."
        }
        else {
            Write-Host -ForegroundColor Green "No Public network profiles found; skipping network profile update."
        }
        
        Write-Host -ForegroundColor Green "Enabling PowerShell remoting..."
        Enable-PSRemoting -Force -ErrorAction Stop
        Write-Host -ForegroundColor Green "PowerShell remoting enabled successfully."
        
        Write-Host -ForegroundColor Green "Enabling CredSSP for WinRM listeners (Server role)..."
        Enable-WSManCredSSP -Role Server -Force -ErrorAction Stop
        Write-Host -ForegroundColor Green "CredSSP enabled successfully as Server."
        
        Write-Host -ForegroundColor Green "PS Remoting with CredSSP configuration completed successfully."
    }
    catch {
        Write-Host -ForegroundColor Green "Error during configuration for PS Remoting with CredSSP: $_"
    }
}

function New-SelfSignedCert {
    try {
        Write-Host -ForegroundColor Green "Creating self-signed certificate..."
        $certParams = @{
            CertStoreLocation = 'Cert:\LocalMachine\My'
            DnsName           = $env:COMPUTERNAME
            NotAfter          = (Get-Date).AddYears(1)
            Provider          = 'Microsoft Software Key Storage Provider'
            Subject           = "CN=$env:COMPUTERNAME"
        }
        $cert = New-SelfSignedCertificate @certParams
        Write-Host -ForegroundColor Green "Certificate created successfully with Thumbprint: $($cert.Thumbprint)"
        return $cert
    }
    catch {
        Write-Host -ForegroundColor Green "Error creating certificate: $_"
        return $null
    }
}

function New-HttpsListener {
    param (
        [Parameter(Mandatory = $true)]
        $Certificate
    )
    try {
        Write-Host -ForegroundColor Green "Creating HTTPS listener for WinRM..."
        $httpsParams = @{
            ResourceURI = 'winrm/config/listener'
            SelectorSet = @{
                Transport = "HTTPS"
                Address   = "*"
            }
            ValueSet = @{
                CertificateThumbprint = $Certificate.Thumbprint
                Enabled               = $true
            }
        }
        New-WSManInstance @httpsParams
        Write-Host -ForegroundColor Green "HTTPS listener created successfully."
    }
    catch {
        Write-Host -ForegroundColor Green "Error creating HTTPS listener: $_"
    }
}

function New-FirewallRule {
    try {
        Write-Host -ForegroundColor Green "Configuring firewall rule for port 5986..."
        $firewallParams = @{
            Action      = 'Allow'
            Description = 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]'
            Direction   = 'Inbound'
            DisplayName = 'Windows Remote Management (HTTPS-In)'
            LocalPort   = 5986
            Profile     = 'Any'
            Protocol    = 'TCP'
        }
        New-NetFirewallRule @firewallParams
        Write-Host -ForegroundColor Green "Firewall rule configured successfully."
    }
    catch {
        Write-Host -ForegroundColor Green "Error configuring firewall rule: $_"
    }
}

function Clear-WinRMServiceCertificateThumbprint {
    try {
        Write-Host -ForegroundColor Green "Clearing CertificateThumbprint from WinRM service configuration..."
        winrm set winrm/config/service '@{CertificateThumbprint=""}'
        Write-Host -ForegroundColor Green "CertificateThumbprint cleared from WinRM service configuration successfully."
    }
    catch {
        Write-Host -ForegroundColor Green "Error clearing CertificateThumbprint from WinRM service: $_"
    }
}

Set-PSRemotingCredSSP

$cert = New-SelfSignedCert
if ($null -ne $cert) {
    New-HttpsListener -Certificate $cert
} else {
    Write-Host -ForegroundColor Green "Certificate creation failed. Skipping HTTPS listener creation."
}

New-FirewallRule

Clear-WinRMServiceCertificateThumbprint
