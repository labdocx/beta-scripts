```powershell
New-ADOrganizationalUnit -name oollabsnet
New-ADOrganizationalUnit -Name 'Computer Accounts' -Path 'OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Managed Computers' -Path 'OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Office Laptops' -Path 'OU=Managed Computers,OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Office Workstations' -Path 'OU=Managed Computers,OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Remote Workstations' -Path 'OU=Managed Computers,OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Virtual Desktops' -Path 'OU=Managed Computers,OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Unmanaged Computers' -Path 'OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Isolated Computers' -Path 'OU=Unmanaged Computers,OU=Computer Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
New-ADOrganizationalUnit -Name 'Groups' -Path 'OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Distribution Groups' -Path 'OU=Groups,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Isolated Groups' -Path 'OU=Groups,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Security Groups' -Path 'OU=Groups,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Software via SCCM' -Path 'OU=Groups,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
New-ADOrganizationalUnit -Name 'Resources' -Path 'OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Printers' -Path 'OU=Resources,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Shared Mailboxes' -Path 'OU=Resources,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
New-ADOrganizationalUnit -Name 'Servers' -Path 'OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Development Servers' -Path 'OU=Servers,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Isolated Servers' -Path 'OU=Servers,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Production Servers' -Path 'OU=Servers,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Virtual Servers' -Path 'OU=Servers,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
New-ADOrganizationalUnit -Name 'User Accounts' -Path 'OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Managed Users' -Path 'OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Contact Users' -Path 'OU=Managed Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Contract Users' -Path 'OU=Managed Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Disabled Accounts' -Path 'OU=Managed Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Office Users' -Path 'OU=Managed Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Remote Users' -Path 'OU=Managed Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
    New-ADOrganizationalUnit -Name 'Unmanaged Users' -Path 'OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Isolated Users' -Path 'OU=Unmanaged Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Service Accounts' -Path 'OU=Unmanaged Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Sys Admin Accounts' -Path 'OU=Unmanaged Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
        New-ADOrganizationalUnit -Name 'Sys Help Desk Account' -Path 'OU=Unmanaged Users,OU=User Accounts,OU=oollabsnet,DC=internal,DC=oollabs,DC=com'
```

![AD OU Design](https://github.com/labdocx/beta-scripts/blob/main/Script_AD%20OU%20Design.png))
