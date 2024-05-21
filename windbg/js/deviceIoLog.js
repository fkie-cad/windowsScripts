// Logs <module>!DeviceControl input and output
// 
//
// last changed: 11.04.2024
// version: 1.0.0
//
// usage: 
// winDbg> .scriptload C:\scripts\windbg\js\deviceIoLog.js
// winDbg> [dx Debugger.State.Scripts.deviceIoLog.Contents.init(moduleName, moduleOffset, [outFileName, [flags]])]
// winDbg> !initLog(moduleName, moduleOffset, [outFileName, [flags]])
// winDbg> g
// winDbg> [dx Debugger.State.Scripts.deviceIoLog.Contents.exit()]
// winDbg> !exitLog()
// winDbg> .scriptunload C:\scripts\windbg\js\deviceIoLog.js
//
// params:
//   moduleName: name of the module to log
//   moduleOffset: module offset to the DeviceControl function
//   outFileName: [optional] output file name, defaults to %tmp%\devio.log
//   flags: [optional] flags.
//            1: verbose mode
//
// remarks:
// - Just logs buffered IO at the moment
// - Sometimes breaks for unknown reasons and has to be manually continued by typing "g"
//      breaks in nt!IofCallDriver+0x55
// - Sometimes the return values are not filled, 
//     may depend on the arbitrary breaking.
//   So the log file has to be fixed on some places.
// - Spams the console with log prints of the function calls. 
//   It's not known how to suppress this behaviour.
//   Without this spamming it would run much faster. 
//

"use strict";

// General function shortcuts
const execute = cmd => host.namespace.Debugger.Utility.Control.ExecuteCommand(cmd);
const log = msg => host.diagnostics.debugLog(`${msg}`);
const logLn = msg => host.diagnostics.debugLog(`${msg}\n`);
const logErr = msg => host.diagnostics.debugLog(`[e] ${msg}\n`);

const FLAG_VERBOSE = 1;

var textWriter = null;
var outFile = null;
var flags = 0;
var initialized = false;
var counter = 0;



// lib

function read_u32(addr) {
    return host.memory.readMemoryValues(addr, 1, 4)[0];
}

function read_u64(addr) {
    return host.memory.readMemoryValues(addr, 1, 8)[0];
}

function paddedByte(value)
{
    if ( value < 0x10 )
        return "0" + value.toString(16);
    else 
        return value.toString(16);
}

function bytesToU16(bytes)
{
    var val = 0;
    val = val.bitwiseOr(bytes[1].bitwiseShiftLeft(0x08));
    val = val.bitwiseOr(bytes[0]);
    return val;
}

function bytesToU32(bytes)
{
    var val = 0;
    val = val.bitwiseOr(bytes[3].bitwiseShiftLeft(0x18));
    val = val.bitwiseOr(bytes[2].bitwiseShiftLeft(0x10));
    val = val.bitwiseOr(bytes[1].bitwiseShiftLeft(0x08));
    val = val.bitwiseOr(bytes[0]);
    return val;
}

function bytesToU64(bytes)
{
    var val = 0;
    val = val.bitwiseOr(bytes[7].bitwiseShiftLeft(0x38));
    val = val.bitwiseOr(bytes[6].bitwiseShiftLeft(0x30));
    val = val.bitwiseOr(bytes[5].bitwiseShiftLeft(0x28));
    val = val.bitwiseOr(bytes[4].bitwiseShiftLeft(0x20));
    val = val.bitwiseOr(bytes[3].bitwiseShiftLeft(0x18));
    val = val.bitwiseOr(bytes[2].bitwiseShiftLeft(0x10));
    val = val.bitwiseOr(bytes[1].bitwiseShiftLeft(0x08));
    val = val.bitwiseOr(bytes[0]);
    return val;
}

// end lib



// Defines array that contains the API version and the exported functions. 
// The exported functions can later be called in two ways: 
// - !initLog or dx @$initLog()
// - !exitLog or dx @$exitLog()
function initializeScript()
{
    log("initializeScript()\n");
    return [
        new host.apiVersionSupport(1, 3),
        new host.functionAlias(init, "initLog"),
        new host.functionAlias(exit, "exitLog"),
    ];
}

// runs every time the script is unloaded. 
// - calls exit() if not done yet
function uninitializeScript()
{
    log("uninitializeScript()\n");
    exit();
}

//
// initializing stuff
// - create log file and setup text writer
// - set a bp at known <moduleName>!DeviceControl offset
// 
function init(moduleName, moduleOffset, outFileName, flags_)
{
    log("init()\n");
    
    if ( initialized )
        exit();
    
    var ctl = host.namespace.Debugger.Utility.Control;
    var fs = host.namespace.Debugger.Utility.FileSystem;

    // get filename
    if ( !outFileName )
        outFileName = fs.TempDirectory + "\\devio.log";
    log("outFileName: "+outFileName+"\n");
    
    if ( flags_ )
        flags = flags_;
    log("flags: "+flags+"\n");
    
    // open file and prepare writer
    outFile = fs.CreateFile(outFileName, "CreateAlways");
    textWriter = fs.CreateTextWriter(outFile, "Utf16");
    
    // init file
    textWriter.WriteLine("#;ioctl;inputBufferLength;inputBufferBytes;rax;outputBufferLength;outputBufferBytes");
    
    
    // there seems not to be a "SetBreakpointAtModuleOffset
    // "SetBreakpointAtOffset" requires a function name, i.e. known symbols
    // var bp = ctl.SetBreakpointAtOffset('', 0x1ef0, moduleName);
    // bp.Command = 'dx @$scriptContents.onEnter(); gc;'
    
    execute("bu20 "+moduleName+"+"+moduleOffset.toString(16)+" \"dx @$scriptContents.onEnter();gc;\"");
    // execute("bu20 "+moduleName+"+"+moduleOffset.toString(16)+" \"dx @$scriptContents.onEnter();\""); // for debugging purposes, no gc
    
    initialized = true;
}

//
// clean up
// - close log file
// - clear bp at <moduleName>!DeviceControl
//
function exit()
{
    log("exit()\n");
    
    if ( !initialized )
        return;
    
    try
    {
        if ( outFile )
            outFile.Close();
    }
    catch ( e )
    {
        logErr(e);
    }
    outFile = null;
    
    execute("bc20");
    counter = 0;
    
    initialized = false;
}

//
// on enter the DeviceControl function
// - log all input params
// - set one shot bp at return address and pass required params to that function
//
function onEnter()
{
    var s = 0;

    var ctl = host.namespace.Debugger.Utility.Control;
    var registers = host.namespace.Debugger.State.DebuggerVariables.curthread.Registers.User;
    
    if ( flags & FLAG_VERBOSE )
        log("enter\n");
    // textWriter.WriteLine("enter");
    
    // var rcx = registers.rcx
    // log("  rcx: "+rcx.toString(16)+"\n");
    var rdx = registers.rdx
    // log("  rdx: "+rdx.toString(16)+"\n");
    
    var irp = host.createTypedObject(rdx, "nt", "_IRP");
    var systemBuffer = irp.AssociatedIrp.SystemBuffer.address;
    var stackAddr = irp.Tail.Overlay.CurrentStackLocation.address;
    // log("  systemBuffer: "+systemBuffer.toString(16)+"\n");
    // log("  stackAddr: "+stackAddr.toString(16)+"\n");
    var stack = host.createTypedObject(stackAddr, "ntkrnlmp", "_IO_STACK_LOCATION");
    
    var outputBufferLength = stack.Parameters.DeviceIoControl.OutputBufferLength;
    var inputBufferLength = stack.Parameters.DeviceIoControl.InputBufferLength;
    var ioctl = stack.Parameters.DeviceIoControl.IoControlCode;
    var systemBufferBytes = new Array();
    if ( inputBufferLength.getLowPart() )
    {
        systemBufferBytes = host.memory.readMemoryValues(systemBuffer, inputBufferLength.getLowPart(), 1);
    }
    
    if ( flags & FLAG_VERBOSE )
    {
        log("  ioctl: 0x"+ioctl.toString(16)+" ("+typeof(ioctl)+")\n");
        log("  outputBufferLength: 0x"+outputBufferLength.toString(16)+" ("+typeof(outputBufferLength)+")\n");
        log("  inputBufferLength: 0x"+inputBufferLength.toString(16)+" ("+typeof(inputBufferLength)+")\n");
        log("  systemBuffer: "+systemBuffer.toString(16)+" ("+typeof(systemBuffer)+")\n");
    }
    
    //
    // write raw data to file
    // counter;ioctl;inputBufferLength;inputBuffer;
    //
    textWriter.Write(counter.toString(10)+";0x"+ioctl.toString(16)+";0x"+inputBufferLength.toString(16)+";");
    if ( inputBufferLength.getLowPart() )
    {
        if ( flags & FLAG_VERBOSE )
        {
            log("  inputBufferBytes: ");
            for ( var i = 0; i < inputBufferLength.getLowPart(); i++ ) 
            {
                log(paddedByte(systemBufferBytes[i])+" ");
            }
            log("\n");
        }
        for ( var i = 0; i < inputBufferLength.getLowPart(); i++ ) 
        {
            textWriter.Write(paddedByte(systemBufferBytes[i])+" ");
        }
        textWriter.Write(";");
    }
    counter++;
    
    // create one time bp at return address
    //
    // can't pass systemBuffer as 64-bit value (object)
    // there should be a better way than splitting
    // rax could be passed as 64-bit as well, why not systembuffer??
    execute("bp /1 /p $proc /t $thread @$ra \"dx @$scriptContents.onReturn("+systemBuffer.getLowPart()+", "+systemBuffer.getHighPart()+", "+outputBufferLength.getLowPart()+"); gc;\"");

    return false;
}


//
// on return of the DeviceIoControl function
// - log all output params
//
function onReturn(systemBufferLow, systemBufferHigh, outputBufferLength)
{
    var s = 0;

    var registers = host.namespace.Debugger.State.DebuggerVariables.curthread.Registers.User;
    // var ctl = host.namespace.Debugger.Utility.Control;
    var log = host.diagnostics.debugLog;
    var rax = registers.rax

    if ( flags & FLAG_VERBOSE )
    {
        log("return\n");
        log("  rax: 0x"+rax.toString(16)+" ("+typeof(rax)+")\n");
        log("  systemBufferLow: 0x"+systemBufferLow.toString(16)+" ("+typeof(systemBufferLow)+")\n");
        log("  systemBufferHigh: 0x"+systemBufferHigh.toString(16)+" ("+typeof(systemBufferHigh)+")\n");
        log("  outputBufferLength: 0x"+outputBufferLength.toString(16)+" ("+typeof(outputBufferLength)+")\n");
        log("  flags: 0x"+flags.toString(16)+" ("+typeof(flags)+")\n");
    }
    textWriter.Write("0x"+rax.toString(16)+";0x"+outputBufferLength.toString(16)+";");
    
    if ( outputBufferLength )
    {
        var systemBuffer = host.Int64(systemBufferLow, systemBufferHigh);
        var systemBufferBytes = host.memory.readMemoryValues(systemBuffer, outputBufferLength, 1);
    
        if ( flags & FLAG_VERBOSE )
        {
            log("  outputBufferBytes: ");
            for ( var i = 0; i < outputBufferLength; i++ ) 
            {
                log(paddedByte(systemBufferBytes[i])+" ");
            }
            log("\n");
        }
        
        for ( var i = 0; i < outputBufferLength; i++ ) 
        {
            textWriter.Write(paddedByte(systemBufferBytes[i])+" ");
        }
    }
    // always create col
    textWriter.Write(";");
    textWriter.Write("\n");
    
    return false;
}
