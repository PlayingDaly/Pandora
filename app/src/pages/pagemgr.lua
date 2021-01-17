require "pages._systemstatus"
require "pages._network"

PageManager = {
	Configuration = nil,
	Network = Network_Page,
	Power = nil,
	Production = nil,
	Storage = nil,
	System_Status = System_Status_Page,
	Transport = nil,

}
PageManagerTabOrder = {
	"System_Status",
	"Network",
	"Production",
	"Storage",
	"Power",
	"Transport",
	"Configuration"
}
--function PageManager:CreatePage(event,num,func,layout,navbarlink)
--	local page = func(event,num,layout,navbarlink)
--	return page
--end