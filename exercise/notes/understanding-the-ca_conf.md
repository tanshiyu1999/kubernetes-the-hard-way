SAN (Subject Alternative Name)
- The main thing to understand is
- This is a list of trusted service by the CA
- This is only used in the control panel node
- This is ONLY used for kubectl command when the nodes communicate to each other
- When the CA decide that it is a good idea to add a service again, it re-issues a signed cert for control panel with new service in SAN list. 
- This enables us to add the service.