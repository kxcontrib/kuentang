Add-Type -Type @"
using System;
using System.Runtime.InteropServices;
namespace WT {
   public class Temp {
      [DllImport("user32.dll")]
      public static extern bool SetWindowText(IntPtr hWnd, string lpString); 
   }
}
"@
$path = "C:\Users\ktang\Documents\finance\kuentang\"
Set-Location -Path $path

$qprss = " results.q -p 1111",
		 " talk.q -p 1234 -gamma -100 -num 10000",
		 " talk.q -p 1235 -gamma -200 -num 10000"
		 
$processname = "C:\q\w32\q.exe"		 

if( $GLOBAL:plist -eq $null ) {

	$GLOBAL:plist = New-Object Collections.Generic.List[System.Diagnostics.Process]

	$qprss | ForEach-Object {
		$process = start $processname $_ -PassThru -WorkingDirectory $path
		Start-Sleep -Milliseconds 250
		[wt.temp]::SetWindowText($process.MainWindowHandle, $_)
		$GLOBAL:plist.Add( $process )
		}
}else{$GLOBAL:plist | ForEach-Object {
		if( -not $_.HasExited  ){ Stop-Process -Id $_.Id} }
		$GLOBAL:plist = $null
	}
	