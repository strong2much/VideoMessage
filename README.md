VM - video messaging
====================

Flash web application to record short video messages. Works only with Flash Media Server (FMS).

Requirements
------------

1. Adobe Flash Professional CS6 (using for visual elements -buttons and etc.)
2. Adobe Flash Builder 4.6 (using libraries and for working with AS3-files)
3. Adobe Flash Media Server 4.0 (server-side for video recording)

Set-ups
-------

1. Set up your Adobe Flash Professional CS6.
Press Ctrl+U (in Windows) to launch settings dialog. Choose ActionScript, and under the languages choose ActionScript 3.0.
Then adjust "Flex SDK path". Need to reference to Adobe Flash Builder 4.6 framework lib.

2. Set up your Adobe Flash Builder 4.6.
Create new Flash Professional project. Choose "VM.fla" as your working file.

3. Set up your Adobe Flash Media Server 4.0.
Add contents of a folder "server-side" to new created folder "vm" under "{FMS_INSTALLING_FOLDER}/applications"
Add new created folder "vm" to "{FMS_INSTALLING_FOLDER}/webroot" (it is needed in order recorded files is saved in Apache webroot, so we can access them by http)
Edit "fms.ini" file and add following strings, but replace <FMS_Installation_Dir> with the proper value:

	```
	VM_COMMON_DIR = <FMS_Installation_Dir>\webroot\vm
	VM_DIR = <FMS_Installation_Dir>\vm\streams
	```
