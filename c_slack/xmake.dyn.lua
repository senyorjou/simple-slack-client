add_rules("mode.debug", "mode.release")
set_languages("c99")
add_requires("libcurl", "cjson")

target("slack_client")
set_kind("binary")
add_files("src/*.c")
add_packages("cjson", "libcurl")
