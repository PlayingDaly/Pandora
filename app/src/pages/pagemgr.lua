require "pages._systemstatus"

PageManager = {
	Configuration = nil,
	Network = nil,
	Power = nil,
	Production = nil,
	Storage = nil,
	System_Status = System_Status_Page,
	Transport = nil,

}
--function PageManager:CreatePage(event,num,func,layout,navbarlink)
--	local page = func(event,num,layout,navbarlink)
--	return page
--end