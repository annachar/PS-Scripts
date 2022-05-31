@echo off

"C:\Program Files (x86)\WinSCP\WinSCP.com" ^
  /command ^
    "open sftp://Syntax2DJRC:Syn1348@djrcfeed.dowjones.com/ -hostkey=""ssh-dss 1024 E0a6kO8ecZqpjAotAZClu0yWjneHeWWrIHmtSFy3DBA=""" ^
    "cd /CSV" ^
    "lcd \\192.168.131.13\LDEroot\LdeFiles\DJ-Full" ^
    "get *_f.zip -latest" ^
    "exit"