require "libs.fileactions"
require "libs.utils"

SettingsManager = {
	FilePath = "/src/os/settings.fncs"
}

function SettingsManager:ReadSettings()
	--Read the settings file if exists
end
function SettingsManager:WriteSettingsFile()
	--Write settings file (os.settings.fncs)
end
function SettingsManager:GetSetting(setting)
	--Return settings data
end
function SettingsManager:SetSetting(setting)
	--Insert or overwrite setting
end
function SettingsManager:CreateSettingsForDeployment(deployOptions)

end
function SettingsManager:GetDeploymentOptions()
	--Returns options available to set in deployment settings file
end

function SettingsManager:Initialize()
	print("Checking for settings file")
	print("SETTINGS IS FUTURE DEV")
	--Check the file exists
	--if not File:Exists(self.FilePath) then
	--	print("No Settings File Found")
	--else
	--	print("Settings File Found")
	--end

end

SettingsManager.CreateRemoteSettings = function()
	local data = ''


	print("Create Settings file for remote deploy")

	return SettingsManager.FilePath, data
end