local cmd = require("cmd")
local json = require("json")
local strings = require("strings")

local function contains(arr, val)
  for _, v in ipairs(arr) do
    if v == val then
      return true
    end
  end
  return false
end

local function build_host_map(configuration)
  local host_map = {}

  for service_name, service_config in pairs(configuration.services) do
    if service_config.ports then
      for _, port_config in ipairs(service_config.ports) do
        if port_config.protocol == "tcp" then
          local from_host = strings.join({ service_name, port_config.target }, ":")
          local to_host = strings.join({ "localhost", port_config.published }, ":")
          host_map[from_host] = to_host
        end
      end
    end
  end

  return host_map
end

local function replace_host(value, host_map)
  for from_host, to_host in pairs(host_map) do
    if strings.contains(value, from_host) then
      return string.gsub(value, from_host, to_host)
    end
  end
  return value
end

---@class MiseContext
---@field options MiseOptions

---@class MiseOptions
---@field services? string[]
---@field variables? string[]
---@field replace_hosts? boolean
---@field include_build_args? boolean

---@class EnvVar
---@field key string
---@field value string

---@class DockerComposeBuildConfig
---@field args? table<string, string>

---@class DockerComposeServiceConfig
---@field environment? table<string, string>
---@field build? DockerComposeBuildConfig

---@class DockerComposeConfig
---@field services table<string, DockerComposeServiceConfig>

---@param ctx MiseContext
---@return EnvVar[]
function PLUGIN:MiseEnv(ctx)
  local success, configuration = pcall(function()
    return json.decode(cmd.exec("docker compose config --format json"))
  end)

  if not success then
    return {}
  end

  ---@cast configuration DockerComposeConfig
  local host_map = build_host_map(configuration)

  ---@type EnvVar[]
  local env = {}

  local service_filter = ctx.options.services
  local variable_filter = ctx.options.variables
  local replace_hosts = ctx.options.replace_hosts
  local include_build_args = ctx.options.include_build_args

  if replace_hosts == nil then
    replace_hosts = false
  end

  if include_build_args == nil then
    include_build_args = false
  end

  for service_name, service_config in pairs(configuration.services) do
    local is_selected = service_filter and contains(service_filter, service_name)
    local has_environment = service_config.environment

    if (not service_filter or is_selected) and has_environment then
      for key, value in pairs(service_config.environment) do
        if not variable_filter or contains(variable_filter, key) then
          if replace_hosts then
            value = replace_host(value, host_map)
          end
          table.insert(env, { key = key, value = value })
        end
      end
    end

    if include_build_args and (not service_filter or is_selected) then
      local has_build_args = service_config.build and service_config.build.args
      if has_build_args then
        for key, value in pairs(service_config.build.args) do
          if not variable_filter or contains(variable_filter, key) then
            if replace_hosts then
              value = replace_host(value, host_map)
            end
            table.insert(env, { key = key, value = value })
          end
        end
      end
    end
  end

  return env
end
