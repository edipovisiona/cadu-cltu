# COSMOS CADU/CLTU Protocols (cosmos v4.1.1)

[![AUR](https://img.shields.io/aur/license/yaourt.svg)](https://github.com/edipovisiona/cadu-cltu/blob/master/LICENSE)

## What does it do

- Handles Command Sequence Number
- Handles Frame Sequence Number
- Handles CLCW flags
- Feedback user upon anomalous behavior
- Commands to unlock transmission, reset frame sequence number, set frame
- Tested with Ubuntu 14.10, Windows 10 x64

## Getting started

Be sure that 'pathtoyourcosmos' is your custom cosmos project folder name, such as 'demo'.

1) Copy config/targets/ to your 'pathtoyourcosmos/config/targets/', which will include target COP1

2) Copy lib/ contents to your 'pathtoyourcosmos/lib/'. That will include cadu, cltu and utils_visiona to your custom cosmos project.

3) Declare COP1 target at 'pathtoyourcosmos/config/system.txt'

```
DECLARE TARGET COP1
```

4) Following configurations happens at your cmd_tlm_server definition, which is 'pathtoyourcosmos/config/tools/cmd_tlm_server/cmd_tlm_server.txt'. Main interface is the interface configured to directly send data to OBDH:

```

4.1) Add CADU and CLTU protocols (must respect this order) to your main interface

```
INTERFACE MAIN_INT...
  PROTOCOL READ protocols/cop1_protocol
  PROTOCOL READ protocols/cadu_protocol
  PROTOCOL WRITE protocols/cltu_protocol.rb 
  PROTOCOL WRITE protocols/cop1_protocol
```

Done. CADU and CLTU should now work.

## License

GPL3