driveListPath = WScript.Arguments.Item(0)     ' Path to drive list
templateDirPath =  WScript.Arguments.Item(1)  ' Path to template directory
outputDirPath =  WScript.Arguments.Item(2)    ' Path to output directory

Set fso = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
Set colDrives = objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive")
Set objRegEx = CreateObject("VBScript.RegExp")

' RegEx for finding references to physical drives in template files
objRegEx.Global = True
objRegEx.IgnoreCase = False
objRegEx.Pattern = "\\\\\.\\PhysicalDrive\d+"

' Clear out all vmdk files in the output directory
Set outputDir = fso.GetFolder(outputDirPath)
For Each f In outputDir.Files
    If LCase(Right(f.name, 5)) = ".vmdk" Then
         f.Delete
    End If
Next

' For each disk_template,disk_signature pair in the drive list file, get the
' current drive number associated with the signature, and output a vmdk based on
' disk_template with the updated disk number
infoMessage = ""
Set driveList = fso.OpenTextFile(driveListPath)
Do Until driveList.AtEndOfStream
    fname = driveList.ReadLine
    sig = driveList.ReadLine
    For Each objDrive in colDrives
        If IsNull(objDrive.Signature) Then
            MsgBox objDrive.DeviceID + ": Ignoring drive (null signature)."
        ElseIf sig = CStr(objDrive.Signature) Then
            infoMessage = infoMessage + CStr(objDrive.DeviceID) + ": "
            infoMessage = infoMessage + fname + vbCrLf
            deviceID = "\\.\PhysicalDrive" & Mid(objDrive.DeviceID, 18)
            Set inFile = fso.OpenTextFile(templateDirPath & fname & ".vmdk")
            inFileContents = inFile.ReadAll
            inFile.Close
            outFileContents = objRegEx.Replace(inFileContents, deviceID)
            outputPath = outputDirPath & fname & ".vmdk"
            Set outFile = fso.CreateTextFile(outputPath, 1, 0)
            outFile.Write(outFileContents)
            outFile.Close
            Exit For
        End If
    Next
Loop
driveList.Close
infoMessage = "Raw disks updated." + vbCrLf + vbCrLf + infoMessage
MsgBox infoMessage
