---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')

---@class CommandScheduler
---Singleton scheduler for managing command execution in the command-based framework.
---The scheduler is responsible for running commands, managing subsystem requirements,
---and handling command lifecycle.
---@field private _scheduledCommands table<Command, boolean> Set of currently running commands
---@field private _requirements table<Subsystem, Command> Map of subsystem to command using it
---@field private _subsystems table<Subsystem, Command|nil> Map of subsystem to default command
---@field private _inRunLoop boolean Flag to prevent scheduling during run
---@field private _disabled boolean Whether the scheduler is disabled
---@field private _defaultButtonLoop EventLoop Default event loop for button/trigger polling
local CommandScheduler = class()

-- Singleton instance
local instance = nil

---Creates a new CommandScheduler instance (private, use getInstance)
---@return CommandScheduler instance A new scheduler instance
local function create()
    local EventLoop = require('wpi.event.EventLoop')
    local inst = setmetatable({}, CommandScheduler)
    inst._scheduledCommands = {}
    inst._requirements = {}
    inst._subsystems = {}
    inst._inRunLoop = false
    inst._disabled = false
    inst._defaultButtonLoop = EventLoop.new()
    return inst
end

---Gets the singleton CommandScheduler instance
---@return CommandScheduler instance The singleton scheduler instance
function CommandScheduler.getInstance()
    if not instance then
        instance = create()
    end
    return instance
end

---Resets the singleton instance (used for testing)
function CommandScheduler.resetInstance()
    instance = nil
end

---Gets the default button loop for trigger polling
---@return EventLoop The default event loop for button/trigger polling
function CommandScheduler:getDefaultButtonLoop()
    return self._defaultButtonLoop
end

---Registers subsystems with the scheduler for periodic execution
---@param ... Subsystem One or more subsystems to register
function CommandScheduler:registerSubsystem(...)
    local subsystems = {...}
    for _, subsystem in ipairs(subsystems) do
        if not subsystem then
            -- Skip nil subsystems (could log warning)
        elseif self._subsystems[subsystem] ~= nil then
            -- Already registered, skip (could log warning)
        else
            -- Register with no default command
            self._subsystems[subsystem] = false
        end
    end
end

---Unregisters subsystems from the scheduler
---@param ... Subsystem One or more subsystems to unregister
function CommandScheduler:unregisterSubsystem(...)
    local subsystems = {...}
    for _, subsystem in ipairs(subsystems) do
        self._subsystems[subsystem] = nil
    end
end

---Sets the default command for a subsystem
---@param subsystem Subsystem The subsystem
---@param command Command|nil The default command, or nil to clear
function CommandScheduler:setDefaultCommand(subsystem, command)
    if not self._subsystems[subsystem] then
        self:registerSubsystem(subsystem)
    end
    self._subsystems[subsystem] = command
end

---Gets the command currently requiring a subsystem
---@param subsystem Subsystem The subsystem to check
---@return Command|nil The command requiring the subsystem, or nil
function CommandScheduler:requiring(subsystem)
    return self._requirements[subsystem]
end

---Schedules one or more commands
---@param ... Command One or more commands to schedule
function CommandScheduler:schedule(...)
    if self._disabled then
        return
    end
    
    if self._inRunLoop then
        error("Commands cannot be scheduled from inside the run loop")
    end
    
    local commands = {...}
    for _, command in ipairs(commands) do
        -- Skip if already scheduled
        if not self._scheduledCommands[command] then
            -- Check requirements and cancel conflicting commands
            local requirements = command:getRequirements()
            for _, subsystem in ipairs(requirements) do
                local requiring = self._requirements[subsystem]
                if requiring then
                    -- Handle interruption behavior
                    local behavior = requiring:getInterruptionBehavior()
                    if behavior == 0 then  -- kCancelSelf
                        self:cancel(requiring)
                    else  -- kCancelIncoming (1)
                        return  -- Don't schedule the new command
                    end
                end
            end
            
            -- Schedule the command
            self._scheduledCommands[command] = true
            
            -- Mark subsystems as required
            for _, subsystem in ipairs(requirements) do
                self._requirements[subsystem] = command
            end
            
            -- Initialize the command
            command:initialize()
        end
    end
end

---Cancels one or more commands
---@param ... Command One or more commands to cancel
function CommandScheduler:cancel(...)
    if self._inRunLoop then
        error("Commands cannot be canceled from inside the run loop")
    end
    
    local commands = {...}
    for _, command in ipairs(commands) do
        if self._scheduledCommands[command] then
            -- Call done(true) for interrupted
            command:done(true)
            
            -- Remove from scheduled commands
            self._scheduledCommands[command] = nil
            
            -- Clear requirements
            local requirements = command:getRequirements()
            for _, subsystem in ipairs(requirements) do
                if self._requirements[subsystem] == command then
                    self._requirements[subsystem] = nil
                end
            end
        end
    end
end

---Cancels all scheduled commands
function CommandScheduler:cancelAll()
    -- Collect all commands first to avoid modifying table during iteration
    local commands = {}
    for command, _ in pairs(self._scheduledCommands) do
        table.insert(commands, command)
    end
    
    for _, command in ipairs(commands) do
        self:cancel(command)
    end
end

---Checks if a command is currently scheduled
---@param command Command The command to check
---@return boolean True if the command is scheduled
function CommandScheduler:isScheduled(command)
    return self._scheduledCommands[command] ~= nil
end

---Runs one iteration of the scheduler
---This should be called from the robot's periodic method
function CommandScheduler:run()
    if self._disabled then
        return
    end
    
    self._inRunLoop = true
    
    -- Step 1: Call periodic() on all registered subsystems
    for subsystem, _ in pairs(self._subsystems) do
        subsystem:periodic()
    end
    
    -- Step 2: Poll default button loop (for triggers)
    self._defaultButtonLoop:poll()
    
    -- Step 3: Execute scheduled commands
    local commandsToFinish = {}
    for command, _ in pairs(self._scheduledCommands) do
        command:execute()
        
        if command:isFinished() then
            table.insert(commandsToFinish, command)
        end
    end
    
    -- Finish completed commands
    for _, command in ipairs(commandsToFinish) do
        command:done(false)
        self._scheduledCommands[command] = nil
        
        -- Clear requirements
        local requirements = command:getRequirements()
        for _, subsystem in ipairs(requirements) do
            if self._requirements[subsystem] == command then
                self._requirements[subsystem] = nil
            end
        end
    end
    
    -- Step 4: Schedule default commands for unused subsystems
    for subsystem, defaultCommand in pairs(self._subsystems) do
        -- Only if there's a default command and subsystem is not in use
        if defaultCommand and not self._requirements[subsystem] then
            self._scheduledCommands[defaultCommand] = true
            self._requirements[subsystem] = defaultCommand
            defaultCommand:initialize()
        end
    end
    
    -- Step 5: Call simulationPeriodic in sim mode
    -- TODO: Detect sim mode and call simulationPeriodic
    
    self._inRunLoop = false
    
    -- Step 6: Execute deferred actions from button loop (triggers scheduling commands)
    -- This must happen AFTER _inRunLoop is set to false
    self._defaultButtonLoop:executeDeferredActions()
end

---Disables the scheduler
function CommandScheduler:disable()
    self._disabled = true
end

---Enables the scheduler
function CommandScheduler:enable()
    self._disabled = false
end

return CommandScheduler
