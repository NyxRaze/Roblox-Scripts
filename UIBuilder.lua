
local UIBuilder = {}

--// MacLib
local MacLib = loadstring(game:HttpGet(
	"https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"
))()

--// Types
export type Component = {
	Type: string,
	[string]: any,
}

export type SectionData = {
	Side: string,
	Components: { Component },
}

export type TabData = {
	Name: string,
	Image: string?,
	Sections: { SectionData },
}

--// Component Constructor
function UIBuilder:Component(Type: string, Properties: {[string]: any}?): Component
	local Component = Properties or {}
	Component.Type = Type

	return Component
end

--// Components
function UIBuilder:Button(
	Name: string,
	Callback: (() -> ())
): Component

	return self:Component("Button", {
		Name = Name,
		Callback = Callback,
	})
end

function UIBuilder:Toggle(
	Name: string,
	Default: boolean,
	Callback: ((boolean) -> ())
): Component

	return self:Component("Toggle", {
		Name = Name,
		Default = Default,
		Callback = Callback,
	})
end

function UIBuilder:Dropdown(
	Name: string,
	Search: boolean,
	Multi: boolean,
	Required: boolean,
	Options: { string },
	Default: number | { string },
	Callback: ((boolean) -> ())
): Component

	return self:Component("Dropdown", {
		Name = Name,
        Search = Search,
        Multi = Multi,
        Required = Required,
        Options = Options,
		Default = Default,
		Callback = Callback,
	})
end

function UIBuilder:Header(Text: string): Component
    return self:Component("Header", {
        Text = Text
    })
end

function UIBuilder:Paragraph(
	Id: string,
	Header: string,
	Body: string
): Component

	return self:Component("Paragraph", {
		Id = Id,
		Header = Header,
		Body = Body,
	})
end

function UIBuilder:Label(Text: string): Component
    return self:Component("Label", {
        Text = Text
    })
end

function UIBuilder:SubLabel(Text: string): Component
    return self:Component("SubLabel", {
        Text = Text
    })
end

function UIBuilder:Divider(): Component
	return self:Component("Divider")
end

--// Section
function UIBuilder:Section(
	Side: string,
	Components: { Component }
): SectionData

	return {
		Side = Side,
		Components = Components,
	}
end

--// Tab
function UIBuilder:Tab(
	Name: string,
	Image: string?,
	Sections: { SectionData }
): TabData

	return {
		Name = Name,
		Image = Image,
		Sections = Sections,
	}
end

--// Window
function UIBuilder:CreateWindow(Properties: {[string]: any})
	return MacLib:Window(Properties)
end

--// Build
function UIBuilder:Build(
	Window: any,
	Tabs: { TabData }
)
	local TabGroup = Window:TabGroup()
	local References = {}

	for _, TabData in ipairs(Tabs) do
		local Tab = TabGroup:Tab({
			Name = TabData.Name,
			Image = TabData.Image or "",
		})

		for _, SectionData in ipairs(TabData.Sections) do
			local Section = Tab:Section({
				Side = SectionData.Side,
			})

			for _, ComponentData in ipairs(SectionData.Components) do
				if ComponentData.Type == "Divider" then
					Section:Divider()
					continue
				end

				local ComponentFunction = Section[ComponentData.Type]

				if typeof(ComponentFunction) == "function" then
					local Component = ComponentFunction(Section, ComponentData)

					if ComponentData.Id then
						References[ComponentData.Id] = Component
					end
				else
					warn(
						"[UIBuilder] Unknown component:",
						ComponentData.Type
					)
				end
			end
		end
	end

	return TabGroup, References
end
