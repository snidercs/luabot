---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local Filesystem = require ('wpi.frc.Filesystem')

do
   local dirs = {
      Filesystem.getLaunchDirectory(),
      Filesystem.getOperatingDirectory(),
      Filesystem.getDeployDirectory()
   }

   for _, dir in ipairs (dirs) do
      assert(type(dir) == 'string', 'not a string: ' .. dir)
      assert(#dir > 0, 'empty path')
   end
end
