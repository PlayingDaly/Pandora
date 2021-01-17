
local function NetworkCode(c,n)
	local this = {
		code = c,
		name = n
	}

	return this
end


NetworkCodes = {
				NetworkCode("0x0001", "New Computer waiting for setup")
}