-- add_rules("mode.debug", "mode.release")
-- set_languages("c99")
-- add_requires("libcurl", "cjson")

-- target("c_slack")
--     set_kind("binary")
--     add_files("src/*.c")
--     add_packages("cjson", "libcurl")


add_requires("libcurl", { system = false, static = true })
add_requires("cjson", { system = false, static = true })
add_requires("openssl", { system = false, static = true }) -- libcurl might need this

target("slack_client")                                   -- or whatever name you want for your binary
set_kind("binary")
add_files("src/*.c")                                     -- assuming your main.c is in src directory

-- Static linking flags
add_ldflags("-static", { force = true })

-- Add the dependencies
add_packages("libcurl", "cjson", "openssl")

-- System libraries that might be needed
add_syslinks("pthread", "dl", "z")

-- SSL related links that might be needed
add_syslinks("ssl", "crypto")

-- Additional flags for static linking
if is_plat("linux") then
    add_ldflags("-Wl,--no-as-needed")
    add_ldflags("-Wl,--whole-archive")
    add_ldflags("-Wl,--no-whole-archive")
end

-- Make sure we include necessary headers
add_includedirs("/usr/include")
add_includedirs("/usr/local/include")
