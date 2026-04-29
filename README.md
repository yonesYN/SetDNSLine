# SetDNSLine
A .bat file for simply set DNS

-  `config.txt` and `SetDNSLine.bat` must be in the same location.
## Configuration
```py
INTERFACE: 'Ethernet' # Optional

DNS1		'0.0.0.0'
DNS2		'0.0.0.0','0.0.0.0'
DNS3		'0.0.0.0','0.0.0.0','0.0.0.0'
```

> [!NOTE]
> The `INTERFACE:` can be used in 3 ways
```r
Empty                 # Select
INTERFACE:  Auto      # First index Interface
INTERFACE: 'Ethernet' # Interface name
```
