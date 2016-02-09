--[[--------------------------------------------------------------------------
 *  Copyright (c) 2014 Lawrence Livermore National Security, LLC.  Produced at
 *  the Lawrence Livermore National Laboratory (cf, AUTHORS, DISCLAIMER.LLNS).
 *  LLNL-CODE-658032 All rights reserved.
 *
 *  This file is part of the Flux resource manager framework.
 *  For details, see https://github.com/flux-framework.
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the license, or (at your option)
 *  any later version.
 *
 *  Flux is distributed in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the IMPLIED WARRANTY OF MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the terms and conditions of the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 *  See also:  http://www.gnu.org/licenses/
 ---------------------------------------------------------------------------]]
 --
 --  Convenience module for running Flux lua bindings tests. Use as:
 --
 --  local test = require 'fluxometer'.init (...)
 --  test:start_session { size = 2 }
 --
 --  The second line is optional if a test does not require a flux
 --   session in order to run.
 --
 --  Other convenience methods in the test object include
 --
 --  test:say ()  -- Issue debug output as diagnostics
 --  test:die ()  -- bail out of tests
 --
 ---------------------------------------------------------------------------
 --
---------------------------------------------------------------------------
--
--  Test harness configuration:
--
local top_srcdir = "@abs_top_srcdir@"
local top_builddir = "@abs_top_builddir@"

--  Default path for flux(1) binary
local fluxbindir = top_builddir .. "/src/cmd"

if os.getenv ("FLUX_TEST_INSTALLED_PATH") then
    --
    --  We are attempting to test against an installed flux(1).
    --   Therefore, we grab proper LUA_PATH and LUA_CPATH by invoking
    --   lua(1) under flux-env. We then _append_ in-tree paths so
    --   that test dependencies can be picked up such as Test/More.lua
    --   and lalarm.so
    --
    --  Reset fluxbindir to requested path by env variable:
    fluxbindir = os.getenv ("FLUX_TEST_INSTALLED_PATH")
    local flux = fluxbindir .. "/flux"
    local read_path = function (v)
        local cmd = string.format (flux.." env lua -e 'print (package.%s)'", v)
        local p = io.popen (cmd):read ("*all")
        return p:match ("^%s*(.-);*%s*$")
    end
    package.path = read_path ("path") .. ';' ..
                     top_srcdir .. "/src/bindings/lua/?.lua"
    package.cpath = read_path ("cpath") .. ';' ..
                     top_builddir .. "/src/bindings/lua/.libs/?.so"
else
    --
    -- Testing in-tree, simply append explicit path to lua bindings to
    --  package.path and package.cpath to hand down to test scripts
    --
    package.path = top_srcdir .. "/src/bindings/lua/?.lua" .. ';'
	    .. package.path
    package.cpath = top_builddir .. "/src/bindings/lua/.libs/?.so" .. ';'
	    .. package.cpath
end

---------------------------------------------------------------------------
local getopt = require 'flux.alt_getopt'.get_opts
local posix = require 'flux.posix'
require 'Test.More'

---------------------------------------------------------------------------
local fluxTest = {
    top_srcdir = top_srcdir,
    top_builddir = top_builddir
}
fluxTest.__index = fluxTest

--  Options:
local cmdline_opts = {
    help =     { char = 'h' },
    verbose =  { char = 'v' }
}

---
--  Append path p to PATH environment variable:
--
local function do_path_prepend (p)
    posix.setenv ("PATH", p .. ":" .. os.getenv ("PATH"))
end

---
--  Reinvoke "current" test script under a flux session using flux-start
--
function fluxTest:start_session (t)
    -- If fluxometer session is already active just return:
    if self.flux_active then return end
    posix.setenv ("FLUXOMETER_ACTIVE", "t")

    local size = t.size or 1
    local extra_args = t.args or {}
    local cmd = { self.flux_path, "start",
                  unpack (self.start_args),
                  string.format ("--size=%d", size) }

    if t.args then
        for _,v in pairs (t.args) do
            table.insert (cmd, v)
        end
    end

    table.insert (cmd, self.arg0)

    -- Adjust package.path so we find fluxometer.lua
    local p = self.src_dir..'/?.lua;'..package.path
    posix.setenv ("LUA_PATH", p)

    -- reexec script under flux-start if necessary:
    --  (does not return)
    local r, err = posix.exec (unpack (cmd))
    error (err)
end


function fluxTest:say (...)
    diag (self.prog..": "..string.format (...))
end


function fluxTest:die (...)
    BAIL_OUT (self.prog..": "..string.format (...))
end


---
--   Create fluxometer test object
--
function fluxTest.init (...)
    local debug = require 'debug'
    local test = setmetatable ({}, fluxTest)

    if os.getenv ("FLUXOMETER_ACTIVE") then
        test.flux_active = true
    end

    -- Get path to current test script using debug.getinfo:
    test.arg0 = debug.getinfo (2).source:sub (2)
    test.prog = test.arg0:match ("/*([^/]+)%.t")

    local cwd, err = posix.getcwd ()
    if not cwd then error (err) end
    test.src_dir = cwd

    -- If arg0 doesn't contain absolute path, then assume
    --  local directory and prepend src_dir
    if not test.arg0:match ('^/') then
        test.arg0 = test.src_dir..'/'..test.arg0
    end

    test.log_file = "lua-"..test.prog..".broker.log"
    test.start_args = { "-o,-q,-L" .. test.log_file }

    local path = fluxbindir.."/flux"
    local mode = posix.stat (path, 'mode')
    if mode and mode:match('^rwx') then
        do_path_prepend (fluxbindir)
        test.flux_path = path
    else
        test:die ("Failed to find flux path")
    end

    test.trash_dir = "trash-directory.lua-"..test.prog
    if test.flux_active then
        os.execute ("rm -rf "..test.trash_dir)
        posix.mkdir (test.trash_dir)
        posix.chdir (test.trash_dir)
        cleanup (function ()
                     posix.chdir (test.src_dir)
                     os.execute ("rm "..test.log_file)
                     os.execute ("rm -rf "..test.trash_dir)
                 end)
    end
    return test
end

return fluxTest
-- vi: ts=4 sw=4 expandtab
