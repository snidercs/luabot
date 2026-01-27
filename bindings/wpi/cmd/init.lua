---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---@module 'wpi.cmd'

local M = {
    Command = require('wpi.cmd.Command'),
    CommandScheduler = require('wpi.cmd.CommandScheduler'),
    FunctionalCommand = require('wpi.cmd.FunctionalCommand'),
    InstantCommand = require('wpi.cmd.InstantCommand'),
    RunCommand = require('wpi.cmd.RunCommand'),
    Subsystem = require('wpi.cmd.Subsystem')
}

return M
