/*
  -- Web Panel
    - Player Management

  -- Admin Commands
    - Replace commands with a custom made UI for STAFF

  -- Permissions System
    - Finish it, with aces and principals

  -- Module System
    - Anti theft system for sub-resources
      Includes:
        - zman.license.lua => { "a90d-98ba" }
        - Obfuscate module loading function (there's no need for anyone to edit that file, all it does is load modules, so let's obfuscate it)
        - Upon loading a module, check if module's license is valid (POST request)
        - If said license is not valid, let's not load the module and skip to the next one, and inform the server owner
          Utils.Logger.Warn(("Exception when loading ~red~%s~white~ module. ~yellow~(License is not valid)"):format(module.name))
        - Maybe allow users to reset licenses? (In case they're stolen) or just IP lock them?

    If we're able to implement this we should be able to stop obfuscated resources for ZMan framework successfuly :)
	    (at least until someone decides to re-write the module system kek)

    - Error handling
      - On error when loading a module, let's upload the output to a pastebin and give it to system admin
    
    - Exclusion
      - If module's folder name starts with exc.foldername let's not load it (instead of deleting the module from the folder)

  -- Bugs
    - Fix ZMan.Ped() => ???

  -- Habitats
    - Allow for two or more people inside a single habitat (max. 3)
    - Split the bill of Habitat => habitat price / number of people
*/