--[[MIT License

    Copyright (c) 2020 ProgCat

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.



    Implementation by playingdaly for PAN
--]]


-- Allows user to run task dyanmicly
TaskMgr = {
    tasks = {}, -- coroutine pool
    pid_counter = 1, -- keep track of new pid
}
tim = 1
-- spawn a interval task
-- params:
-- * sec number
-- * func function
-- * single_run bool
-- return pid
function TaskMgr:spawnTimed(sec, func, single_run, ...)
    local vars = {...}
    local task = {
        name = string.format("%s@%d", debug.getinfo(2, "S").short_src, debug.getinfo(2, "S").lastlinedefined),
        pid=self.pid_counter,
        single_run = single_run,
        co=nil,
        pause=false,
        interval=0,
        timestamp = 0,
        error_msg = nil,
        error_handler = debug.traceback
    }
    task.interval = sec * 1000
    task.timestamp = computer.millis()
    if single_run then
        task.co = coroutine.create(function()
            local normal, err_msg = xpcall(func, task.error_handler, vars)
            if not normal then
                task.error_msg = err_msg
                print(string.format('[Error] Timed Task %s(pid %d):\n%s', task.name, task.pid, task.error_msg))
            end
            coroutine.yield()
        end)
    else
        --loop run
        task.co = coroutine.create(function()
            while true do
                local normal, err_msg = xpcall(func, task.error_handler, vars)
                --print("timedTaskRun "..tim)
                tim = tim + 1
                if not normal then
                    task.error_msg = err_msg
                    print(string.format('[Error] Timed Task %s(pid%d):\n %s', task.name, task.pid, task.error_msg))
                    -- kill the coroutine
                    break
                end
                coroutine.yield()
            end
        end)
    end
    table.insert(self.tasks, task)
    self.pid_counter = self.pid_counter + 1
    return task.pid
end

-- spawn a task
-- params:
-- * func function
-- * single_run bool
-- return pid
function TaskMgr:spawn(func, single_run, ...)
    local vars = {...}
    local task = {
        name = string.format("%s@%d", debug.getinfo(2, "S").short_src, debug.getinfo(2, "S").lastlinedefined),
        pid=self.pid_counter,
        single_run = single_run,
        co=nil,
        pause=false,
        interval=0,
        timestamp = 0,
        error_msg = nil,
        error_handler = debug.traceback
    }

    if single_run then
        task.co = coroutine.create(function()
            local normal, err_msg = xpcall(func, task.error_handler, vars)
            if not normal then
                task.error_msg = err_msg
                print(string.format('[Error] Task %s(pid %d) | %s', task.name, task.pid, task.error_msg))
            end
            coroutine.yield()
        end)
    else
        --loop run
        task.co = coroutine.create(function()
            while true do
                local normal, err_msg = xpcall(func, task.error_handler, vars)
                if not normal then
                    task.error_msg = err_msg
                    print(string.format('[Error] Task %s(pid %d) | %s', task.name, task.pid, task.error_msg))
                    -- kill the coroutine
                    break
                end
                coroutine.yield()
            end
        end)
    end
    table.insert(self.tasks, task)
    self.pid_counter = self.pid_counter + 1
    return task.pid
end

function TaskMgr:getError(pid)
    for _, task in ipairs(self.tasks) do
        if task.pid == pid then return task.error_msg end
    end
    return nil
end

function TaskMgr:setErrorHandler(pid, handler)
    for idx, task in ipairs(self.tasks) do
        if task.pid == pid then
            task.error_handler = handler or debug.traceback
        end
    end
end

function TaskMgr:start(pid)
    for idx, task in ipairs(self.tasks) do
        if task.pid == pid then
            task.pause = false
        end
    end
end

-- kill a task
-- params:
-- * pid number
-- return whether task exist and killed
function TaskMgr:kill(pid)
    -- find task by pid, then stop n delete it
    for idx, task in ipairs(self.tasks) do
        if task.pid == pid then
            table.remove(self.tasks, idx)
            return true
        end
    end
    return false
end

-- return whether the task is paused
function TaskMgr:isPaused(pid)
    for _, task in ipairs(self.tasks) do
        if task.pid == pid then return task.pause end
    end
    return false
end

function TaskMgr:isDead(pid)
    for _, task in ipairs(self.tasks) do
        if task.pid == pid then return coroutine.status(task.co) == "dead" end
    end
    return true
end

function TaskMgr:setName(pid, name)
    for _, task in ipairs(self.tasks) do
        if task.pid == pid then
            task.name = name
            return true
        end
    end
end

-- pause/unpause a task
-- params:
-- * pid number
-- return whether task found and paused/unpaused
function TaskMgr:setPause(pid, state)
    if state ~= nil then
        -- find task by pid, and set the flag
        for _, task in ipairs(self.tasks) do
            if task.pid == pid then
                task.pause = state
                return true
            end
        end
    end
    return false
end

function TaskMgr:setExit(pid, state)
    if state ~= nil then
        -- find task by pid, and set the flag
        for _, task in ipairs(self.tasks) do
            if task.pid == pid then
                task.exited = state
                return true
            end
        end
    end
    return false
end



function TaskMgr:run()
    while true do
        -- keep the flow running
        for _, task in ipairs(self.tasks) do
            if coroutine.status(task.co) ~= "dead" then
                if task.pause == false then
                    if task.interval == 0 then
                        coroutine.resume(task.co)
                    else
                        -- timed task
                        if (computer.millis() - task.timestamp) >= task.interval then
                            task.timestamp = computer.millis() -- reset
                            coroutine.resume(true, task.co)
                        end
                    end
                end
            elseif task.single_run == true then
                -- clean up single run dead threads
                self:kill(task.pid)
            end
            computer.skip()
        end
        computer.skip()
    end
end
