require "libs.fileActions"
require "libs.folderActions"

--Deploy Actions
Deploy = {}

function Deploy:TransmitFileBuffer(filebuffer,nic,address,port)
	if filebuffer then
		--Log.Information("Copying Files in Buffer")
		for k,v in ipairs(filebuffer) do
			nic:send(address,port,"0x0014",v.path,v.data)
		end
	end
end
function Deploy:RemoteFactoryBootEEPROM(nic,address,port)
	local path = '/src/EEPROMs/MainCpuEEPROM.lua'
	
	--Pass the Intermediate EEprom
	local eeData = File:Read(path)

	if eeData then
		--Transmit the new EEprom
		nic:send(address,port,"0x0013", path)
		print(string.format("Response Code(%s) Sent to: %s on port %s", "0x0013", address, port))
		return true
	else 
		error(string.format("Unable to read %s", path)) 
		return false
	end
end
function Deploy:RemoteFactorySetup(address, port)
	local nic = SysConfig.Network_Manager.execute.nic
	
	--Respond to the request
	nic:send(address,port,"0x0012")
	print(string.format("Response Code(%s) Sent to: %s on port %s", "0x0012", address, port))
	
	--Create the Settings file
	local settingsFilePath, settingsFile = SysConfig.Settings_Manager.execute.CreateRemoteSettings()

	--Build File Copy Buffer
	local _buffer = Folder:CopyFolderToBuffer("/", {"/.vs"}, true)

	--Transmit the file buffer
	if _buffer then
		--Transmit File Buffer
		self:TransmitFileBuffer(_buffer, nic,address,port)
	end

	--Transmit the settings File(Sent after the file copy to overwrite the base settings file)
	nic:send(address,port,"0x0014", settingsFilePath, settingsFile)

	--Transmit boot EEprom
	if self:RemoteFactoryBootEEPROM(nic,address,port) then
		--Transmit cleanup message
		nic:send(address,port,"0x0016")
		print(string.format("Response Code(%s) Sent to: %s on port %s", "0x0016", address, port))
	else
		print("new EEProm failed to send")
	end
end