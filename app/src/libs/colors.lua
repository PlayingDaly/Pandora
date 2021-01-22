--Colors
local function color(r, g, b, a)
	local this = {
		r = r,
		g = g,
		b = b,
		a = a or 1
	}
	function this:Details()
		return string.format("(%s,%s,%s,%s)", self.r, self.g, self.b, self.a)
	end
	function this:Copy()
		return color(self.r,self.g,self.b,self.a)
	end
	function this:IsTransparent()
		if self.r == -9 then 
			return true 
		end
	end
	function this:Compare(color)
		return self.r == color.r and self.g == color.g and self.b == color.b and self.a == color.a
	end

	return this
end
Colors = {
		Aqua = color(0,1,1),
		Black = color(0,0,0),
		Blue = color(0,0,1),
		Clear = color(0,0,0,0),
		Green = color(0,1,0),
		Purple = color(1,0,1),
		Orange = color(1,0.2,0,1),
		Red = color(1,0,0),
		Transparent = color(-9,-9,-9,-9),
		Yellow = color(1,1,0),
		White = color(1,1,1),

		Custom = function(r,g,b,a)
					return ColorCreator:Create(r,g,b,a)
				 end
	}

ColorCreator = {}
function ColorCreator:Create(r,g,b,o)
	return color(r/255,g/255,b/255,0)
end
function ColorCreator:Help()
	return string.format("To Create a color enter the red,green,blue values 0-255 and the opacity value 0-1(0 for transparent, 1 for solid)")
end