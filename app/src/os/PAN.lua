

require "libs.utils"
require "libs.taskmgr"
require "libs.sysTime"
require "libs.datastructs"
require "libs.fileActions"
require "libs.folderActions"
require "libs.logging"

require "kernel.settingsmgr"
require "kernel.displaymgr"
require "kernel.eventmgr"
require "kernel.networkmgr"


--PANDORA Meaning
--P lanetary
--A utomated
--N etwork
--D elivery
--O ptimization
--R eal-time
--A nalysis


SysConfig = {
	AppName = "PANDORA",
	Version = 0.1,
	NumGenerator = math.random,
	Time = SysTime,
	Debug = false,

	Display_Manager =	nil,
	Event_Manager = nil,
	Network_Manager =	nil,
	Power_Manager = nil,
	Production_Manager = nil,
	Settings_Manager = nil,
	Storage_Manager =	nil,
	System_Status_Manager = nil,
	Train_Manager = nil
}

function Initialize()
 	print(".....Initializing "..SysConfig.AppName.."...........")
 	print(".....System Configuration Loading...")

	--Read Settings file here
	SysConfig.Settings_Manager = AppModule:RegisterAndInitialize({enabled = true, execute = SettingsManager})
	
	--Register Display Manager
	--Init args:
	--	Key: Screen designator (screen1 or screen2)
	--	Fields:
	--		name = Screen Component name
	--		width = Screen Render width
	--		isMirror = Does screen mirror desktop. If mirror display, the width value will be ignored. It will inherit from the primary display
	--	desktop s is currently reserved for a screen driver(will change if large screens are interactable)
	SysConfig.Display_Manager = AppModule:RegisterAndInitialize({enabled = true,  execute = DisplayManager, refresh_rate = 1.0, initArgs = {["screen1"] = {name = "screen1", width = 220, isMirror = true}} })

	--Enable Event Listener
	SysConfig.Event_Manager = AppModule:RegisterAndInitialize({enabled = true,  execute = EventManager })

	--Enable Network Manager
	SysConfig.Network_Manager = AppModule:RegisterAndInitialize({enabled = true, execute = NetworkManager})
end

function Program()
 	Initialize()
 	Log.Information(SysConfig.AppName.." is Running!")

	---------------------------------EXAMPLE CODE FOR FILE COPY/DEPLOY KEEP--------------------------
	--Copy the entire drive using /
	--tt = Folder:CopyFolderToBuffer("/", {"/.vs"}, true)
	--for k,v in ipairs(tt) do Log.Debug(k.." "..v.path) end
	--Copies the Buffer to the drive
	--Folder:WriteFolderBuffer('/testCopy/',tt)
	-------------------------------------------------------------------------------------------------



	if SysConfig.Debug then
		SysConfig.Display_Manager.execute:GetAllScreenDetails()
		SysConfig.Event_Manager.execute.Listen()
		SysConfig.Display_Manager.execute.Render()
	else
		--App seems to run with 2 or more tasks, 1 task(spawned) causes massive fps drop and stuttering
		TaskMgr:spawn(SysTime.Start)
		TaskMgr:spawnTimed(SysConfig.Display_Manager.refresh_interval,SysConfig.Display_Manager.execute.Render)
		TaskMgr:spawn(SysConfig.Event_Manager.execute.Listen)

		--Run the OS Indefinitely
		TaskMgr:run()

	end

 	print(SysConfig.AppName.." Finished. Shutting Down")
	Log.Information(SysConfig.AppName.." Finished. Shutting Down")
 	computer.stop()
end

Program()



--TODO
[[	
	Screen Mirror() -- Done
	DropDown 
	ListBox
	Pagination
	Checkbox
	Settings Manager - Read/Write and defined settings
	Queue System for queuing builds
	Deployment - On Floppy for easy startup?

	Tab Page Designs
	
	Network_Manager ( all) -- Whitelisting and blacklisting
	Inventory Manager
	Remote Factory Deployment
	Power Plant manager
	Transport Manager(Trucks/Trains)
	Speaker/Sound Mgr


]]