local etlua  = require "etlua"
local socket = require "socket"
local url    = require "socket.url"

local rel_config_file = os.getenv("KONG_CONF") or "config/kong.conf"
local rel_env_file    = ".profile.d/kong-env"

local template_filename = arg[1]
local config_filename = arg[2].."/"..rel_config_file

local env_filename = arg[2].."/"..rel_env_file

local port = os.getenv("PORT")
local pg_url = os.getenv("DATABASE_URL")

local parsed_pg_url = url.parse(pg_url)
local pg_host = parsed_pg_url.host
local pg_port = parsed_pg_url.port
local pg_user = parsed_pg_url.user
local pg_password = parsed_pg_url.password
local pg_database = string.sub(parsed_pg_url.path, 2, -1)

local template_file = io.open(template_filename, "r")
local template = etlua.compile(template_file:read("*a"))
template_file:close()

local values = {
    proxy_listen = "0.0.0.0:"..port.."ssl http2",
    pg_host = pg_host,
    pg_port = pg_port,
    pg_user = pg_user,
    pg_password = pg_password,
    pg_database = pg_database
}

local config = template(values)
config_file = io.open(config_filename, "w")
config_file:write(config)
config_file:close()

print("Wrote Kong config: "..config_filename)

local env_file
env_file = io.open(env_filename, "a+")
env_file:write("export KONG_CONF="..rel_config_file.."\n")