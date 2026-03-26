@echo off

REM 
REM  Filename    : modules/utils/modules/workspace-info/getws.cmd
REM  Date        : 20 Apr 2023
REM  Author      : Balaji Venkataraman (b1v6@pge.com)
REM  Description : batchfile script to invoke powershell script
REM 


Powershell -NoProfile -ExecutionPolicy Bypass -Command "& %~dp0'\getws.ps1'"
