return function(...: any): () -> (() -> boolean)

    local storedTable = setmetatable({...}, {__mode="kv"})

    return function (): boolean
        return #storedTable == 0
    end

end