local json = require "json"

unpack = unpack or table.unpack

local function InstallFromLocal(f, folder)
  folder = folder or "packages"
  local file, err = io.open(f, "r")

  if file == nil then print("Error: " .. err) return false end

  local content = file:read("*a")

  local decompressed = content

  local data = json.decode(decompressed) or { name = "", files = {} }

  local name = data.name

  if not name then print("Unable to find package name") return false end

  print("Installing " .. name)

  os.execute("mkdir " .. JoinPath(folder, name))

  local files = data.files

  local outdirs = {}
  local outfiles = {}
  local out = {}

  for path, fileContent in pairs(files) do
    if fileContent == 1 then
      table.insert(outdirs, path)
    else
      table.insert(outfiles, path)
    end
  end

  for _, path in ipairs(outdirs) do
    table.insert(out, path)
  end

  for _, path in ipairs(outfiles) do
    table.insert(out, path)
  end

  for _, path in ipairs(out) do
    local fileContent = files[path]

    if fileContent == 1 then
      print("Creating directory " .. path .. "...")
      os.execute("mkdir " .. JoinPath(folder, name, unpack(SplitStr(path, "/"))))
    else
      print("Creating file " .. path .. "...")
      local p = JoinPath(folder, name, unpack(SplitStr(path, "/")))
      local thisFile, ferr = io.open(p, "wb")
      if not thisFile then print("Failed to build file " .. path .. ": " .. ferr) return false end
      ---@diagnostic disable-next-line: need-check-nil
      thisFile:write(fileContent)
      ---@diagnostic disable-next-line: need-check-nil
      thisFile:close()
    end
  end

  file:close()
  ModularCM.getPackages()
  return true
end

local function getpackagefiles(folder)
  local t = {}

  local files = ScanDir(folder)

  for _, file in pairs(files) do
    if IsDir(JoinPath(folder, file)) then
      table.insert(t, JoinPath(folder, file))
      local subfiles = getpackagefiles(JoinPath(folder, file))
      for _, subfile in pairs(subfiles) do
        table.insert(t, subfile)
      end
    else
      table.insert(t, JoinPath(folder, file))
    end
  end

  return t
end

local deflate = require('LibDeflate')

local function obfuscate(file, content, amount)
  amount = amount or (math.random(1, 20))

  local obfuscated = deflate:EncodeForPrint(deflate:CompressDeflate(content, { level = 9 }))
  local code = "local deflate = require('LibDeflate')\n"
  code = code .. "local content = deflate:DecompressDeflate(deflate:DecodeForPrint(\"" .. obfuscated .. "\"))\n"
  code = code .. "return load(content, \"" .. file .. "\", \"bt\", _G)()"

  if amount == 1 then
    return code
  else
    return obfuscate(file, code, amount - 1)
  end
end

local function Compile(package, folder, noprompt)
  folder = folder or "packages"
  local t = getpackagefiles(JoinPath(folder, package))
  local sep = IsWindows and "\\" or "/"

  local files = {}

  if not noprompt then print("Would you like to obfuscate the package? (y/n)") end
  local obfuscateAnswer = noprompt and "n" or io.read()

  for _, file in ipairs(t) do
    print("Compiling " .. file .. "...")
    if IsDir(file) then
      local fileNameSplit = SplitStr(file, sep)
      table.remove(fileNameSplit, 1)
      table.remove(fileNameSplit, 1)
      local fileName = table.concat(fileNameSplit, "/")
      files[fileName] = 1
    else
      local nf, err = io.open(file, "rb")
      if not nf then print("Failed to open file " .. file .. ": " .. err) return end
      local fileContent = nf:read("*a")
      local fileNameSplit = SplitStr(file, sep)
      table.remove(fileNameSplit, 1)
      table.remove(fileNameSplit, 1)
      local fileName = table.concat(fileNameSplit, "/")

      if obfuscateAnswer == "y" and fileName:sub(-4) == ".lua" then
        fileContent = obfuscate(fileName, fileContent)
      end

      files[fileName] = fileContent
    end
  end

  local p = {
    files = files,
    name = package,
  }

  local compressed = json.encode(p)

  print("Compiled package...")
  
  if noprompt then
    io.write("Please write the output file name > ")
    local name = io.read("l")

    local file, err = io.open(name, "w")
    if not file then
      print("Could not open file for writing. Reason: " .. err)
      return
    end
    file:write(tostring(compressed))
    file:close()
  end
end

local function Delete(package, folder)
  folder = folder or "packages"
  print("Deleting " .. package .. "...")
  if IsWindows then
    os.execute("rmdir " .. JoinPath(folder, package) .. "/s /q")
  else
    os.execute("rm -rd -rf " .. JoinPath(folder, package) .. " -r")
  end
  print("Deleted " .. package .. ".")
  ModularCM.getPackages()
end

local function GitClone(url, packageName, folder)
  folder = folder or "packages"
  local p = JoinPath(folder, packageName)
  print("Initiating download...")
  local s = os.execute("git clone " .. url .. " '" .. p .. "'")
  print(s and ("Successfully installed " .. packageName) or "Failed to install the package")
  if s then
    Delete(JoinPath(packageName, '.git'))
    local uf = io.open(JoinPath(folder, packageName, 'update.json'), "w")
    if not uf then return end
    uf:write(tostring(json.encode({ git = url })))
    uf:close()
  end

  ModularCM.getPackages()
end

local function gitupdatepackage(p, folder)
  folder = folder or "packages"
  local f = io.open(JoinPath(folder, p, "update.json"))
  if not f then return end -- No file :megamind:
  local thing = json.decode(f:read(), 1, nil) or { git = nil }

  if thing.git then
    local git = thing.git
    local name = p
    Delete(p)
    GitClone(git, name)
  end
end

local function GitUpdate()
  for _, p in ipairs(ModularCM.getPackages()) do
    gitupdatepackage(p)
  end
end

local function Mod(args)
  local action = args[1]

  if action == "add" then
    local f = args[2]
    if not f then return print("Please specify file name") end
    local s = InstallFromLocal(f, args[3])
    if s then
      print("Successfully installed package from local file")
    else
      print("Failed to install package")
    end
  elseif action == "compile" then
    local package = args[2]
    if not package then return print("Please specify package name") end
    print("Compiling...")
    Compile(package)
  elseif action == "list" then
    local packages = ScanDir("packages")
    for _, package in pairs(packages) do
      print(package)
    end
  elseif action == "git" then
    local url = args[2]
    if not url then return print("Please specify a URL") end
    local name = args[3]
    if not name then return print("Please specify a package name to install it as") end

    GitClone(url, name, args[3])
  elseif action == "git_update" then
    GitUpdate()
  elseif action == "delete" then
    local package = args[2]
    if not package then return print("Please specify package name") end
    Delete(package, args[3])
  elseif action == "help" then
    print("Usage: mod <action> [args]")
    print("Actions:")
    print("  add <file> [folder]")
    print("  compile <package> [folder]")
    print("  delete <package> [folder]")
    print("  list")
    print("  git <url> <name> [folder]")
    print("  git_update")
  else
    print("Unknown operation " .. action)
  end
end

BindCommand("mod", Mod)
