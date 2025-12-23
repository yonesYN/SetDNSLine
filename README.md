# SetDNSLine
A .bat file for simply set DNS

-  `config.txt` and `SetDNSLine.bat` must be in the same location.
## Configuration
```py
INTERFACE: 'Ethernet' # Optional

1.1   # Don't remove this.
DNS1:		'0.0.0.0'
DNS2:		'0.0.0.0','0.0.0.0'
DNS3:		'0.0.0.0','0.0.0.0','0.0.0.0'
```

> [!NOTE]
> The `INTERFACE:` can be used in 3 ways
```r
INTERFACE:            # Select mod
INTERFACE:  Auto      # First index of Interface
INTERFACE: 'Ethernet' # Use Interface name
```
