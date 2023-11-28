<#
BSD 2-Clause License

Copyright (c) 2023, Nick Wolff <nick@wolff.tech>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# Display Device Name and Serial Number
Write-Host "Current Device Name:" 
Hostname

get-ciminstance win32_bios | format-list serialnumber

# Check for TPM
get-tpm | format-list TpmPresent,TpmReady,TpmEnabled,TpmActivated,TpmOwned,RestartPending,AutoProvisioning,ManagedAuthLevel

# Stop Script if TPM check fails
$TPMver = wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get SpecVersion -value
if ($TPMver -like "*2.0*") {
	Write-Host "The TPM Specification version on this Device is 2.0. Continuing..."
	Write-Hoost "`n"
} else {
	Write-Host "WARNING:"
	Write-Host "Autopilot Pre-Provisiong will not work on this device because"
	Write-Host "The TPM Specification version is not 2.0 or some other issue."
	Write-Host "`n"
	Write-Host "Please enroll manually or attempt to run this again after a reboot."
	write-Host "`n"
	Pause
	exit
}

# Start services required to setup device by User
Write-Host "Starting Settings, Computer-Management, & Program and Features"
Write-Host "`n"
Start-Process -FilePath "compmgmt.msc"
Start-Process -FilePath "appwiz.cpl"
Start-Process ms-Settings:

# Instructions for user to follow
Write-Host "Follow the steps below..."
Write-Host "`n"
Write-Host "1. From Settings, sign into the Wireless Network."
Write-Host "`n"
Write-Host "2. In System > About change the license to the Coretek Windows Enterprise license."
Write-Host "`n"
Write-Host "3. Set Screen Timeout to NEVER from: Settings > System > Power & Battery > Screen & Sleep."
Write-Host "`n"
Write-Host "4. Preform windows updates on the system and restart as needed. (Will need to re-run this script when restart occurs)"
Write-Host "`n"
Write-Host "5. From Settings > App > Installed Apps uninstall any software not needed."
Write-Host "`n"
Write-Host "6. Re-Name the device following the company naming scheme and restart the device a final time"
Write-Host "`n"
Pause

# Check Device Name
Write-Host "`n"
$systemDeviceName = Hostname

while ( $condition -lt 1) {
	$userDeviceName = Read-Host "Please Enter the new Device Name:"
	$systemDeviceName = Hostname

	Write-Host "`n"

	if ( $userDeviceName -eq $systemDeviceName ) {
		Write-Host "Confirmed device names match, continuing with autopilot enrollment..."
		Write-Host "`n"
		$condition = 1
	} else {
		Wirte-Host "The device name does not match what was entered. Please check your spelling and the device name and attempt again."
		Write-Host "`n"
		Write-Host "If this doesn't work, please rename the device and start the script again."
		Write-Host "`n"
		$condition = 0
	}
}

#Enroll the Device in Autopilot
Install-Script -Name get-windowsautopilotinfocommunity -Force

Write-Host "When prompted, please login with your elevated PIM-ed up admin account that has write permissions to Intune."
Write-Host "`n"

get-windowsautopilotinfocommunity.ps1 -Online -Assign -AssignedComputerName $userDeviceName

Write-Host "All commands have been completed."
Write-Host "`n"

Write-Host "If there were no errors in the console above,, please continue with Autopilot setup of the device."
Write-Host "`n"
Write-Host "Do so by going back to the Windows Device Setup screen and pressing the Windows Key 5 times to select Autopilot Setup."

Write-Host "`n"
Write-Host "End of Script, please close this window."

Pause
