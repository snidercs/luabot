local Filesystem = require ('frc.Filesystem')

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
