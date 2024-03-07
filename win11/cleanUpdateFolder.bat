@echo off

net stop wuauserv
net stop bits
net stop appidsvc
net stop cryptsvc

rmdir /s /q C:\Windows\SoftwareDistribution

net start wuauserv
net start bits
net start appidsvc
net start cryptsvc