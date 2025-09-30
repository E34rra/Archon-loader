local Loader = {}

function Loader:ExecuteScript(Args)
    local ScriptKey = Args.ScriptKey or 'JcaXlhVYvRWptYXrRqFXrETroJaZmwQN'
    
    local source = [[
        script_key = ']] .. ScriptKey .. [[';
        loadstring(
            game:HttpGet(
                'https://api.luarmor.net/files/v3/loaders/6b4b66f576ef7e2708176a6a38717e49.lua'
            )
        )()
    ]]
    
    local env = string.lower(identifyexecutor())
    
    if string.find(env, "zenith") then
        for _, actor in getactorthreads() do
            run_on_thread(actor, [[
                if not getrenv().shared.require then return end
            ]] .. source)
        end
    elseif string.find(env, "potassium") then
        run_on_thread(getactorthreads()[1], source)
    else
        local RunOnParallelLuaState = run_on_actor or run_on_parallel_lua_state
        local GetAllActorInstances = getactors or get_actors
        local GetFeatureFlag = getfflag or get_fflag

        if GetFeatureFlag and GetFeatureFlag('DebugRunParallelLuaOnMainThread') then
            return loadstring(source)()
        end

        local ActorInstances = GetAllActorInstances and GetAllActorInstances()
        if ActorInstances and RunOnParallelLuaState then
            local TargetActor = ActorInstances[1]
            if TargetActor then
                local Success, Result = pcall(function()
                    return RunOnParallelLuaState(TargetActor, source)
                end)
                if Success then
                    return Result
                end
            end
        end

        local GetCurrentActorThreads = get_actor_threads or getactorthreads
        local RunOnThread = run_on_thread
        
        if GetCurrentActorThreads and RunOnThread then
            local ActiveThreads = GetCurrentActorThreads()
            local TargetThread = ActiveThreads[1]
            if TargetThread then
                local Success, Result = pcall(function()
                    return RunOnThread(TargetThread, source)
                end)
                if Success then
                    return Result
                end
            end
        end

        return loadstring(source)()
    end
    
    return true
end

return Loader
