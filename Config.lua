local HttpService = game:GetService("HttpService")

local Config = {}

function Config.new(Name, Defaults)
    local self = {
        Defaults = table.clone(Defaults),
        Data = table.clone(Defaults),

        Folder = Name,
        File = Name .. "/config.json",
    }

    function self:Save()
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end

        local Success, Data = pcall(function()
            return HttpService:JSONEncode(self.Data)
        end)

        if not Success then
            warn("[Config] Failed to encode:", Data)

            return false
        end

        Success, Data = pcall(function()
            writefile(self.File, Data)
        end)

        if not Success then
            warn("[Config] Failed to save:", Data)

            return false
        end

        return true
    end

    function self:Load()
        if not isfile(self.File) then
            self:Save()

            return false
        end

        local Success, Data = pcall(function()
            return HttpService:JSONDecode(readfile(self.File))
        end)

        if not Success or type(Data) ~= "table" then
            warn("[Config] Invalid config, resetting...")
            
            self.Data = table.clone(self.Defaults)
            self:Save()

            return false
        end

        self.Data = table.clone(self.Defaults)

        for Key, Value in pairs(Data) do
            if self.Defaults[Key] ~= nil then
                self.Data[Key] = Value
            end
        end

        return true
    end

    function self:Reset()
        self.Data = table.clone(self.Defaults)
        self:Save()
    end

    function self:Get(Key)
        return self.Data[Key]
    end

    function self:Set(Key, Value)
        if self.Defaults[Key] == nil then
            warn("[Config] Unknown setting:", Key)

            return
        end

        self.Data[Key] = Value
    end

    self:Load()

    return self
end

return Config
