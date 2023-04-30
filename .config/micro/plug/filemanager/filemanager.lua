VERSION = "3.5.0"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")
local os = import("os")
local filepath = import("path/filepath")

-- Clear out all stuff in Micro's messenger
local function clear_messenger()
	-- messenger:Reset()
	-- messenger:Clear()
end

-- Holds the micro.CurPane() we're manipulating
local tree_view = nil
-- Keeps track of the current working directory
local current_dir = os.Getwd()
-- Keep track of current highest visible indent to resize width appropriately
local highest_visible_indent = 0
-- Holds a table of paths -- objects from new_listobj() calls
local scanlist = {}

-- Get a new object used when adding to scanlist
local function new_listobj(p, d, o, i)
	return {
		["abspath"] = p,
		["dirmsg"] = d,
		["owner"] = o,
		["indent"] = i,
		-- Since decreasing/increasing is common, we include these with the object
		["decrease_owner"] = function(self, minus_num)
			self.owner = self.owner - minus_num
		end,
		["increase_owner"] = function(self, plus_num)
			self.owner = self.owner + plus_num
		end
	}
end

-- Repeats a string x times, then returns it concatenated into one string
local function repeat_str(str, len)
	-- Do NOT try to concat in a loop, it freezes micro...
	-- instead, use a temporary table to hold values
	local string_table = {}
	for i = 1, len do
		string_table[i] = str
	end
	-- Return the single string of repeated characters
	return table.concat(string_table)
end

-- A check for if a path is a dir
local function is_dir(path)
	-- Used for checking if dir
	local golib_os = import("os")
	-- Returns a FileInfo on the current file/path
	local file_info, stat_error = golib_os.Stat(path)
	-- Wrap in nil check for file/dirs without read permissions
	if file_info ~= nil then
		-- Returns true/false if it's a dir
		return file_info:IsDir()
	else
		-- Couldn't stat the file/dir, usually because no read permissions
		micro.InfoBar():Error("Error checking if is dir: ", stat_error)
		-- Nil since we can't read the path
		return nil
	end
end

-- Returns a list of files (in the target dir) that are ignored by the VCS system (if exists)
-- aka this returns a list of gitignored files (but for whatever VCS is found)
local function get_ignored_files(tar_dir)
	-- True/false if the target dir returns a non-fatal error when checked with 'git status'
	local function has_git()
		local git_rp_results = RunShellCommand('git  -C "' .. tar_dir .. '" rev-parse --is-inside-work-tree')
		return git_rp_results:match("^true%s*$")
	end
	local readout_results = {}
	-- TODO: Support more than just Git, such as Mercurial or SVN
	if has_git() then
		-- If the dir is a git dir, get all ignored in the dir
		local git_ls_results =
			RunShellCommand('git -C "' .. tar_dir .. '" ls-files . --ignored --exclude-standard --others --directory')
		-- Cut off the newline that is at the end of each result
		for split_results in string.gmatch(git_ls_results, "([^\r\n]+)") do
			-- git ls-files adds a trailing slash if it's a dir, so we remove it (if it is one)
			readout_results[#readout_results + 1] =
				(string.sub(split_results, -1) == "/" and string.sub(split_results, 1, -2) or split_results)
		end
	end

	-- Make sure we return a table
	return readout_results
end

-- Returns the basename of a path (aka a name without leading path)
local function get_basename(path)
	if path == nil then
		micro.Log("Bad path passed to get_basename")
		return nil
	else
		-- Get Go's path lib for a basename callback
		local golib_path = import("filepath")
		return golib_path.Base(path)
	end
end

-- Returns true/false if the file is a dotfile
local function is_dotfile(file_name)
	-- Check if the filename starts with a dot
	if string.sub(file_name, 1, 1) == "." then
		return true
	else
		return false
	end
end

-- Structures the output of the scanned directory content to be used in the scanlist table
-- This is useful for both initial creation of the tree, and when nesting with uncompress_target()
local function get_scanlist(dir, ownership, indent_n)
	local golib_ioutil = import("ioutil")
	-- Gets a list of all the files in the current dir
	local dir_scan, scan_error = golib_ioutil.ReadDir(dir)

	-- dir_scan will be nil if the directory is read-protected (no permissions)
	if dir_scan == nil then
		micro.InfoBar():Error("Error scanning dir: ", scan_error)
		return nil
	end

	-- The list of files to be returned (and eventually put in the view)
	local results = {}
	local files = {}

	local function get_results_object(file_name)
		local abs_path = filepath.Join(dir, file_name)
		-- Use "+" for dir's, "" for files
		local dirmsg = (is_dir(abs_path) and "+" or "")
		return new_listobj(abs_path, dirmsg, ownership, indent_n)
	end

	-- Save so we don't have to rerun GetOption a bunch
	local show_dotfiles = config.GetGlobalOption("filemanager.showdotfiles")
	local show_ignored = config.GetGlobalOption("filemanager.showignored")
	local folders_first = config.GetGlobalOption("filemanager.foldersfirst")

	-- The list of VCS-ignored files (if any)
	-- Only bother getting ignored files if we're not showing ignored
	local ignored_files = (not show_ignored and get_ignored_files(dir) or {})
	-- True/false if the file is an ignored file
	local function is_ignored_file(filename)
		for i = 1, #ignored_files do
			if ignored_files[i] == filename then
				return true
			end
		end
		return false
	end

	-- Hold the current scan's filename in most of the loops below
	local filename

	for i = 1, #dir_scan do
		local showfile = true
		filename = dir_scan[i]:Name()
		-- If we should not show dotfiles, and this is a dotfile, don't show
		if not show_dotfiles and is_dotfile(filename) then
			showfile = false
		end
		-- If we should not show ignored files, and this is an ignored file, don't show
		if not show_ignored and is_ignored_file(filename) then
			showfile = false
		end
		if showfile then
			-- This file is good to show, proceed
			if folders_first and not is_dir(filepath.Join(dir, filename)) then
				-- If folders_first and this is a file, add it to (temporary) files
				files[#files + 1] = get_results_object(filename)
			else
				-- Otherwise, add to results
				results[#results + 1] = get_results_object(filename)
			end
		end
	end
	if #files > 0 then
		-- Append any files to results, now that all folders have been added
		-- files will be > 0 only if folders_first and there are files
		for i = 1, #files do
			results[#results + 1] = files[i]
		end
	end

	-- Return the list of scanned files
	return results
end

-- A short "get y" for when acting on the scanlist
-- Needed since we don't store the first 3 visible indicies in scanlist
local function get_safe_y(optional_y)
	-- Default to 0 so we can check against and see if it's bad
	local y = 0
	-- Make the passed y optional
	if optional_y == nil then
		-- Default to cursor's Y loc if nothing was passed, instead of declaring another y
		optional_y = tree_view.Cursor.Loc.Y
	end
	-- 0/1/2 would be the top "dir, separator, .." so check if it's past
	if optional_y > 2 then
		-- -2 to conform to our scanlist, since zero-based Go index & Lua's one-based
		y = tree_view.Cursor.Loc.Y - 2
	end
	return y
end

-- Joins the target dir's leading path to the passed name
local function dirname_and_join(path, join_name)
	-- The leading path to the dir we're in
	local leading_path = DirectoryName(path)
	-- Joins with OS-specific slashes
	return filepath.Join(leading_path, join_name)
end

-- Hightlights the line when you move the cursor up/down
local function select_line(last_y)
	-- Make last_y optional
	if last_y ~= nil then
		-- Don't let them move past ".." by checking the result first
		if last_y > 1 then
			-- If the last position was valid, move back to it
			tree_view.Cursor.Loc.Y = last_y
		end
	elseif tree_view.Cursor.Loc.Y < 2 then
		-- Put the cursor on the ".." if it's above it
		tree_view.Cursor.Loc.Y = 2
	end

	-- Puts the cursor back in bounds (if it isn't) for safety
	tree_view.Cursor:Relocate()

	-- Makes sure the cursor is visible (if it isn't)
	-- (false) means no callback
	tree_view:Center()

	-- Highlight the current line where the cursor is
	tree_view.Cursor:SelectLine()
end

-- Simple true/false if scanlist is currently empty
local function scanlist_is_empty()
	if next(scanlist) == nil then
		return true
	else
		return false
	end
end

local function refresh_view()
	clear_messenger()

	-- If it's less than 30, just use 30 for width. Don't want it too small

	if tree_view:GetView().Width < 30 then
		tree_view:ResizePane(30)
	end

	-- Delete everything in the view/buffer
	tree_view.Buf.EventHandler:Remove(tree_view.Buf:Start(), tree_view.Buf:End())

	-- Insert the top 3 things that are always there
	-- Current dir
	tree_view.Buf.EventHandler:Insert(buffer.Loc(0, 0), current_dir .. "\n")
	-- An ASCII separator
	tree_view.Buf.EventHandler:Insert(buffer.Loc(0, 1), repeat_str("─", tree_view:GetView().Width) .. "\n")
	-- The ".." and use a newline if there are things in the current dir
	tree_view.Buf.EventHandler:Insert(buffer.Loc(0, 2), (#scanlist > 0 and "..\n" or ".."))

	-- Holds the current basename of the path (purely for display)
	local display_content

	-- NOTE: might want to not do all these concats in the loop, it can get slow
	for i = 1, #scanlist do
		-- The first 3 indicies are the dir/separator/"..", so skip them
		if scanlist[i].dirmsg ~= "" then
			-- Add the + or - to the left to signify if it's compressed or not
			-- Add a forward slash to the right to signify it's a dir
			display_content = scanlist[i].dirmsg .. " " .. get_basename(scanlist[i].abspath) .. "/"
		else
			-- Use the basename from the full path for display
			-- Two spaces to align with any directories, instead of being "off"
			display_content = "  " .. get_basename(scanlist[i].abspath)
		end

		if scanlist[i].owner > 0 then
			-- Add a space and repeat it * the indent number
			display_content = repeat_str(" ", 2 * scanlist[i].indent) .. display_content
		end

		-- Newlines are needed for all inserts except the last
		-- If you insert a newline on the last, it leaves a blank spot at the bottom
		if i < #scanlist then
			display_content = display_content .. "\n"
		end

		-- Insert line-by-line to avoid out-of-bounds on big folders
		-- +2 so we skip the 0/1/2 positions that hold the top dir/separator/..
		tree_view.Buf.EventHandler:Insert(buffer.Loc(0, i + 2), display_content)
	end

	-- Resizes all views after messing with ours
    tree_view:Tab():Resize()
end

-- Moves the cursor to the ".." in tree_view
local function move_cursor_top()
	-- 2 is the position of the ".."
	tree_view.Cursor.Loc.Y = 2

	-- select the line after moving
	select_line()
end

local function refresh_and_select()
	-- Save the cursor position before messing with the view..
	-- because changing contents in the view causes the Y loc to move
	local last_y = tree_view.Cursor.Loc.Y
	-- Actually refresh
	refresh_view()
	-- Moves the cursor back to it's original position
	select_line(last_y)
end

-- Find everything nested under the target, and remove it from the scanlist
local function compress_target(y, delete_y)
	-- Can't compress the top stuff, or if there's nothing there, so exit early
	if y == 0 or scanlist_is_empty() then
		return
	end
	-- Check if the target is a dir, since files don't have anything to compress
	-- Also make sure it's actually an uncompressed dir by checking the gutter message
	if scanlist[y].dirmsg == "-" then
		local target_index, delete_index
		-- Add the original target y to stuff to delete
		local delete_under = {[1] = y}
		local new_table = {}
		local del_count = 0
		-- Loop through the whole table, looking for nested content, or stuff with ownership == y...
		-- and delete matches. y+1 because we want to start under y, without actually touching y itself.
		for i = 1, #scanlist do
			delete_index = false
			-- Don't run on y, since we don't always delete y
			if i ~= y then
				-- On each loop, check if the ownership matches
				for x = 1, #delete_under do
					-- Check for something belonging to a thing to delete
					if scanlist[i].owner == delete_under[x] then
						-- Delete the target if it has an ownership to our delete target
						delete_index = true
						-- Keep count of total deleted (can't use #delete_under because it's for deleted dir count)
						del_count = del_count + 1
						-- Check if an uncompressed dir
						if scanlist[i].dirmsg == "-" then
							-- Add the index to stuff to delete, since it holds nested content
							delete_under[#delete_under + 1] = i
						end
						-- See if we're on the "deepest" nested content
						if scanlist[i].indent == highest_visible_indent and scanlist[i].indent > 0 then
							-- Save the lower indent, since we're minimizing/deleting nested dirs
							highest_visible_indent = highest_visible_indent - 1
						end
						-- Nothing else to do, so break this inner loop
						break
					end
				end
			end
			if not delete_index then
				-- Save the index in our new table
				new_table[#new_table + 1] = scanlist[i]
			end
		end

		scanlist = new_table

		if del_count > 0 then
			-- Ownership adjusting since we're deleting an index
			for i = y + 1, #scanlist do
				-- Don't touch root file/dirs
				if scanlist[i].owner > y then
					-- Minus ownership, on everything below i, the number deleted
					scanlist[i]:decrease_owner(del_count)
				end
			end
		end

		-- If not deleting, then update the gutter message to be + to signify compressed
		if not delete_y then
			-- Update the dir message
			scanlist[y].dirmsg = "+"
		end
	elseif config.GetGlobalOption("filemanager.compressparent") and not delete_y then
		goto_parent_dir()
		-- Prevent a pointless refresh of the view
		return
	end

	-- Put outside check above because we call this to delete targets as well
	if delete_y then
		local second_table = {}
		-- Quickly remove y
		for i = 1, #scanlist do
			if i == y then
				-- Reduce everything's ownership by 1 after y
				for x = i + 1, #scanlist do
					-- Don't touch root file/dirs
					if scanlist[x].owner > y then
						-- Minus 1 since we're just deleting y
						scanlist[x]:decrease_owner(1)
					end
				end
			else
				-- Put everything but y into the temporary table
				second_table[#second_table + 1] = scanlist[i]
			end
		end
		-- Put everything (but y) back into scanlist, with adjusted ownership values
		scanlist = second_table
	end

	if tree_view:GetView().Width > (30 + highest_visible_indent) then
		-- Shave off some width
        tree_view:ResizePane(30 + highest_visible_indent)
	end

	refresh_and_select()
end

-- Prompts the user for deletion of a file/dir when triggered
-- Not local so Micro can access it
function prompt_delete_at_cursor()
	local y = get_safe_y()
	-- Don't let them delete the top 3 index dir/separator/..
	if y == 0 or scanlist_is_empty() then
		micro.InfoBar():Error("You can't delete that")
		-- Exit early if there's nothing to delete
		return
	end

    micro.InfoBar():YNPrompt("Do you want to delete the " .. (scanlist[y].dirmsg ~= "" and "dir" or "file") .. ' "' .. scanlist[y].abspath .. '"? ', function(yes, canceled)
        if yes and not canceled then
            -- Use Go's os.Remove to delete the file
            local go_os = import("os")
            -- Delete the target (if its a dir then the children too)
            local remove_log = go_os.RemoveAll(scanlist[y].abspath)
            if remove_log == nil then
                micro.InfoBar():Message("Filemanager deleted: ", scanlist[y].abspath)
                -- Remove the target (and all nested) from scanlist[y + 1]
                -- true to delete y
                compress_target(get_safe_y(), true)
            else
                micro.InfoBar():Error("Failed deleting file/dir: ", remove_log)
            end
        else
            micro.InfoBar():Message("Nothing was deleted")
        end
    end)
end

-- Changes the current dir in the top of the tree..
-- then scans that dir, and prints it to the view
local function update_current_dir(path)
	-- Clear the highest since this is a full refresh
	highest_visible_indent = 0
	-- Set the width back to 30
	tree_view:ResizePane(30)
	-- Update the current dir to the new path
	current_dir = path

	-- Get the current working dir's files into our list of files
	-- 0 ownership because this is a scan of the base dir
	-- 0 indent because this is the base dir
	local scan_results = get_scanlist(path, 0, 0)
	-- Safety check with not-nil
	if scan_results ~= nil then
		-- Put in the new scan stuff
		scanlist = scan_results
	else
		-- If nil, just empty it
		scanlist = {}
	end

	refresh_view()
	-- Since we're going into a new dir, move cursor to the ".." by default
	move_cursor_top()
end

-- (Tries to) go back one "step" from the current directory
local function go_back_dir()
	-- Use Micro's dirname to get everything but the current dir's path
	local one_back_dir = filepath.Dir(current_dir)
	-- Try opening, assuming they aren't at "root", by checking if it matches last dir
	if one_back_dir ~= current_dir then
		-- If DirectoryName returns different, then they can move back..
		-- so we update the current dir and refresh
		update_current_dir(one_back_dir)
	end
end

-- Tries to open the current index
-- If it's the top dir indicator, or separator, nothing happens
-- If it's ".." then it tries to go back a dir
-- If it's a dir then it moves into the dir and refreshes
-- If it's actually a file, open it in a new vsplit
-- THIS EXPECTS ZERO-BASED Y
local function try_open_at_y(y)
	-- 2 is the zero-based index of ".."
	if y == 2 then
		go_back_dir()
	elseif y > 2 and not scanlist_is_empty() then
		-- -2 to conform to our scanlist "missing" first 3 indicies
		y = y - 2
		if scanlist[y].dirmsg ~= "" then
			-- if passed path is a directory, update the current dir to be one deeper..
			update_current_dir(scanlist[y].abspath)
		else
			-- If it's a file, then open it
			micro.InfoBar():Message("Filemanager opened ", scanlist[y].abspath)
			-- Opens the absolute path in new vertical view
			micro.CurPane():VSplitIndex(buffer.NewBufferFromFile(scanlist[y].abspath), true)
			-- Resizes all views after opening a file
			-- tabs[curTab + 1]:Resize()
		end
	else
		micro.InfoBar():Error("Can't open that")
	end
end

-- Opens the dir's contents nested under itself
local function uncompress_target(y)
	-- Exit early if on the top 3 non-list items
	if y == 0 or scanlist_is_empty() then
		return
	end
	-- Only uncompress if it's a dir and it's not already uncompressed
	if scanlist[y].dirmsg == "+" then
		-- Get a new scanlist with results from the scan in the target dir
		local scan_results = get_scanlist(scanlist[y].abspath, y, scanlist[y].indent + 1)
		-- Don't run any of this if there's nothing in the dir we scanned, pointless
		if scan_results ~= nil then
			-- Will hold all the old values + new scan results
			local new_table = {}
			-- By not inserting in-place, some unexpected results can be avoided
			-- Also, table.insert actually moves values up (???) instead of down
			for i = 1, #scanlist do
				-- Put the current val into our new table
				new_table[#new_table + 1] = scanlist[i]
				if i == y then
					-- Fill in the scan results under y
					for x = 1, #scan_results do
						new_table[#new_table + 1] = scan_results[x]
					end
					-- Basically "moving down" everything below y, so ownership needs to increase on everything
					for inner_i = y + 1, #scanlist do
						-- When root not pushed by inserting, don't change its ownership
						-- This also has a dual-purpose to make it not effect root file/dirs
						-- since y is always >= 3
						if scanlist[inner_i].owner > y then
							-- Increase each indicies ownership by the number of scan results inserted
							scanlist[inner_i]:increase_owner(#scan_results)
						end
					end
				end
			end

			-- Update our scanlist with the new values
			scanlist = new_table
		end

		-- Change to minus to signify it's uncompressed
		scanlist[y].dirmsg = "-"

		-- Check if we actually need to resize, or if we're nesting at the same indent
		-- Also check if there's anything in the dir, as we don't need to expand on an empty dir
		if scan_results ~= nil then
			if scanlist[y].indent > highest_visible_indent and #scan_results >= 1 then
				-- Save the new highest indent
				highest_visible_indent = scanlist[y].indent
				-- Increase the width to fit the new nested content
				tree_view:ResizePane(tree_view:GetView().Width + scanlist[y].indent)
			end
		end

		refresh_and_select()
	end
end

-- Stat a path to check if it exists, returning true/false
local function path_exists(path)
	local go_os = import("os")
	-- Stat the file/dir path we created
	-- file_stat should be non-nil, and stat_err should be nil on success
	local file_stat, stat_err = go_os.Stat(path)
	-- Check if what we tried to create exists
	if stat_err ~= nil then
		-- true/false if the file/dir exists
		return go_os.IsExist(stat_err)
	elseif file_stat ~= nil then
		-- Assume it exists if no errors
		return true
	end
	return false
end

-- Prompts for a new name, then renames the file/dir at the cursor's position
-- Not local so Micro can use it
function rename_at_cursor(new_name)
	if micro.CurPane() ~= tree_view then
		micro.InfoBar():Message("Rename only works with the cursor in the tree!")
		return
	end

	-- Safety check they actually passed a name
	if new_name == nil then
		micro.InfoBar():Error('When using "rename" you need to input a new name')
		return
	end

	-- +1 since Go uses zero-based indices
	local y = get_safe_y()
	-- Check if they're trying to rename the top stuff
	if y == 0 then
		-- Error since they tried to rename the top stuff
		micro.InfoBar():Message("You can't rename that!")
		return
	end

	-- The old file/dir's path
	local old_path = scanlist[y].abspath
	-- Join the path into their supplied rename, so that we have an absolute path
	local new_path = dirname_and_join(old_path, new_name)
	-- Use Go's os package for renaming the file/dir
	local golib_os = import("os")
	-- Actually rename the file
	local log_out = golib_os.Rename(old_path, new_path)
	-- Output the log, if any, of the rename
	if log_out ~= nil then
		micro.Log("Rename log: ", log_out)
	end

	-- Check if the rename worked
	if not path_exists(new_path) then
		micro.InfoBar():Error("Path doesn't exist after rename!")
		return
	end

	-- NOTE: doesn't alphabetically sort after refresh, but it probably should
	-- Replace the old path with the new path
	scanlist[y].abspath = new_path
	-- Refresh the tree with our new name
	refresh_and_select()
end

-- Prompts the user for the file/dir name, then creates the file/dir using Go's os package
local function create_filedir(filedir_name, make_dir)
	if micro.CurPane() ~= tree_view then
		micro.InfoBar():Message("You can't create a file/dir if your cursor isn't in the tree!")
		return
	end

	-- Safety check they passed a name
	if filedir_name == nil then
		micro.InfoBar():Error('You need to input a name when using "touch" or "mkdir"!')
		return
	end

	-- The target they're trying to create on top of/in/at/whatever
	local y = get_safe_y()
	-- Holds the path passed to Go for the eventual new file/dir
	local filedir_path
	-- A true/false if scanlist is empty
	local scanlist_empty = scanlist_is_empty()

	-- Check there's actually anything in the list, and that they're not on the ".."
	if not scanlist_empty and y ~= 0 then
		-- If they're inserting on a folder, don't strip its path
		if scanlist[y].dirmsg ~= "" then
			-- Join our new file/dir onto the dir
			filedir_path = filepath.Join(scanlist[y].abspath, filedir_name)
		else
			-- The current index is a file, so strip its name and join ours onto it
			filedir_path = dirname_and_join(scanlist[y].abspath, filedir_name)
		end
	else
		-- if nothing in the list, or cursor is on top of "..", use the current dir
		filedir_path = filepath.Join(current_dir, filedir_name)
	end

	-- Check if the name is already taken by a file/dir
	if path_exists(filedir_path) then
		micro.InfoBar():Error("You can't create a file/dir with a pre-existing name")
		return
	end

	-- Use Go's os package for creating the files
	local golib_os = import("os")
	-- Create the dir or file
	if make_dir then
		-- Creates the dir
		golib_os.Mkdir(filedir_path, golib_os.ModePerm)
		micro.Log("Filemanager created directory: " .. filedir_path)
	else
		-- Creates the file
		golib_os.Create(filedir_path)
		micro.Log("Filemanager created file: " .. filedir_path)
	end

	-- If the file we tried to make doesn't exist, fail
	if not path_exists(filedir_path) then
		micro.InfoBar():Error("The file/dir creation failed")

		return
	end

	-- Creates a sort of default object, to be modified below
	-- If creating a dir, use a "+"
	local new_filedir = new_listobj(filedir_path, (make_dir and "+" or ""), 0, 0)

	-- Refresh with our new value(s)
	local last_y

	-- Only insert to scanlist if not created into a compressed dir, since it'd be hidden if it was
	-- Wrap the below checks so a y=0 doesn't break something
	if not scanlist_empty and y ~= 0 then
		-- +1 so it's highlighting the new file/dir
		last_y = tree_view.Cursor.Loc.Y + 1

		-- Only actually add the object to the list if it's not created on an uncompressed folder
		if scanlist[y].dirmsg == "+" then
			-- Exit early, since it was created into an uncompressed folder

			return
		elseif scanlist[y].dirmsg == "-" then
			-- Check if created on top of an uncompressed folder
			-- Change ownership to the folder it was created on top of..
			-- otherwise, the ownership would be incorrect
			new_filedir.owner = y
			-- We insert under the folder, so increment the indent
			new_filedir.indent = scanlist[y].indent + 1
		else
			-- This triggers if the cursor is on top of a file...
			-- so we copy the properties of it
			new_filedir.owner = scanlist[y].owner
			new_filedir.indent = scanlist[y].indent
		end

		-- A temporary table for adding our new object, and manipulation
		local new_table = {}
		-- Insert the new file/dir, and update ownership of everything below it
		for i = 1, #scanlist do
			-- Don't use i as index, as it will be off by one on the next pass after below "i == y"
			new_table[#new_table + 1] = scanlist[i]
			if i == y then
				-- Insert our new file/dir (below the last item)
				new_table[#new_table + 1] = new_filedir
				-- Increase ownership of everything below it, since we're inserting
				-- Basically "moving down" everything below y, so ownership needs to increase on everything
				for inner_i = y + 1, #scanlist do
					-- When root not pushed by inserting, don't change its ownership
					-- This also has a dual-purpose to make it not effect root file/dirs
					-- since y is always >= 3
					if scanlist[inner_i].owner > y then
						-- Increase each indicies ownership by 1 since we're only inserting 1 file/dir
						scanlist[inner_i]:increase_owner(1)
					end
				end
			end
		end
		-- Update the scanlist with the new object & updated ownerships
		scanlist = new_table
	else
		-- The scanlist is empty (or cursor is on ".."), so we add on our new file/dir at the bottom
		scanlist[#scanlist + 1] = new_filedir
		-- Add current position so it takes into account where we are
		last_y = #scanlist + tree_view.Cursor.Loc.Y
	end

	refresh_view()
	select_line(last_y)
end

-- Triggered with "touch filename"
function new_file(input_name)
	-- False because not a dir
	create_filedir(input_name, false)
end

-- Triggered with "mkdir dirname"
function new_dir(input_name)
	-- True because dir
	create_filedir(input_name, true)
end

-- open_tree setup's the view
local function open_tree()
	-- Open a new Vsplit (on the very left)
	micro.CurPane():VSplitIndex(buffer.NewBuffer("", "filemanager"), false)
	-- Save the new view so we can access it later
	tree_view = micro.CurPane()

	-- Set the width of tree_view to 30% & lock it
    tree_view:ResizePane(30)
	-- Set the type to unsavable
    -- tree_view.Buf.Type = buffer.BTLog
    tree_view.Buf.Type.Scratch = true
    tree_view.Buf.Type.Readonly = true

	-- Set the various display settings, but only on our view (by using SetLocalOption instead of SetOption)
	-- NOTE: Micro requires the true/false to be a string
	-- Softwrap long strings (the file/dir paths)
    tree_view.Buf:SetOptionNative("softwrap", true)
    -- No line numbering
    tree_view.Buf:SetOptionNative("ruler", false)
    -- Is this needed with new non-savable settings from being "vtLog"?
    tree_view.Buf:SetOptionNative("autosave", false)
    -- Don't show the statusline to differentiate the view from normal views
    tree_view.Buf:SetOptionNative("statusformatr", "")
    tree_view.Buf:SetOptionNative("statusformatl", "filemanager")
    tree_view.Buf:SetOptionNative("scrollbar", false)

	-- Fill the scanlist, and then print its contents to tree_view
	update_current_dir(os.Getwd())
end

-- close_tree will close the tree plugin view and release memory.
local function close_tree()
	if tree_view ~= nil then
		tree_view:Quit()
		tree_view = nil
		clear_messenger()
	end
end

-- toggle_tree will toggle the tree view visible (create) and hide (delete).
function toggle_tree()
	if tree_view == nil then
		open_tree()
	else
		close_tree()
	end
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Functions exposed specifically for the user to bind
-- Some are used in callbacks as well
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function uncompress_at_cursor()
	if micro.CurPane() == tree_view then
		uncompress_target(get_safe_y())
	end
end

function compress_at_cursor()
	if micro.CurPane() == tree_view then
		-- False to not delete y
		compress_target(get_safe_y(), false)
	end
end

-- Goes up 1 visible directory (if any)
-- Not local so it can be bound
function goto_prev_dir()
	if micro.CurPane() ~= tree_view or scanlist_is_empty() then
		return
	end

	local cur_y = get_safe_y()
	-- If they try to run it on the ".." do nothing
	if cur_y ~= 0 then
		local move_count = 0
		for i = cur_y - 1, 1, -1 do
			move_count = move_count + 1
			-- If a dir, stop counting
			if scanlist[i].dirmsg ~= "" then
				-- Jump to its parent (the ownership)
				tree_view.Cursor:UpN(move_count)
				select_line()
				break
			end
		end
	end
end

-- Goes down 1 visible directory (if any)
-- Not local so it can be bound
function goto_next_dir()
	if micro.CurPane() ~= tree_view or scanlist_is_empty() then
		return
	end

	local cur_y = get_safe_y()
	local move_count = 0
	-- If they try to goto_next on "..", pretends the cursor is valid
	if cur_y == 0 then
		cur_y = 1
		move_count = 1
	end
	-- Only do anything if it's even possible for there to be another dir
	if cur_y < #scanlist then
		for i = cur_y + 1, #scanlist do
			move_count = move_count + 1
			-- If a dir, stop counting
			if scanlist[i].dirmsg ~= "" then
				-- Jump to its parent (the ownership)
				tree_view.Cursor:DownN(move_count)
				select_line()
				break
			end
		end
	end
end

-- Goes to the parent directory (if any)
-- Not local so it can be keybound
function goto_parent_dir()
	if micro.CurPane() ~= tree_view or scanlist_is_empty() then
		return
	end

	local cur_y = get_safe_y()
	-- Check if the cursor is even in a valid location for jumping to the owner
	if cur_y > 0 then
		-- Jump to its parent (the ownership)
		tree_view.Cursor:UpN(cur_y - scanlist[cur_y].owner)
		select_line()
	end
end

function try_open_at_cursor()
	if micro.CurPane() ~= tree_view or scanlist_is_empty() then
		return
	end

	try_open_at_y(tree_view.Cursor.Loc.Y)
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Shorthand functions for actions to reduce repeat code
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Used to fail certain actions that we shouldn't allow on the tree_view
local function false_if_tree(view)
	if view == tree_view then
		return false
	end
end

-- Select the line at the cursor
local function selectline_if_tree(view)
	if view == tree_view then
		select_line()
	end
end

-- Move the cursor to the top, but don't allow the action
local function aftermove_if_tree(view)
	if view == tree_view then
		if tree_view.Cursor.Loc.Y < 2 then
			-- If it went past the "..", move back onto it
			tree_view.Cursor:DownN(2 - tree_view.Cursor.Loc.Y)
		end
		select_line()
	end
end

local function clearselection_if_tree(view)
	if view == tree_view then
		-- Clear the selection when doing a find, so it doesn't copy the current line
		tree_view.Cursor:ResetSelection()
	end
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- All the events for certain Micro keys go below here
-- Other than things we flat-out fail
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Close current
function preQuit(view)
	if view == tree_view then
		-- A fake quit function
		close_tree()
		-- Don't actually "quit", otherwise it closes everything without saving for some reason
		return false
	end
end

-- Close all
function preQuitAll(view)
	close_tree()
end

-- FIXME: Workaround for the weird 2-index movement on cursordown
function preCursorDown(view)
	if view == tree_view then
		tree_view.Cursor:Down()
		select_line()
		-- Don't actually go down, as it moves 2 indicies for some reason
		return false
	end
end

-- Up
function onCursorUp(view)
	selectline_if_tree(view)
end

-- Alt-Shift-{
-- Go to target's parent directory (if exists)
function preParagraphPrevious(view)
	if view == tree_view then
		goto_prev_dir()
		-- Don't actually do the action
		return false
	end
end

-- Alt-Shift-}
-- Go to next dir (if exists)
function preParagraphNext(view)
	if view == tree_view then
		goto_next_dir()
		-- Don't actually do the action
		return false
	end
end

-- PageUp
function onCursorPageUp(view)
	aftermove_if_tree(view)
end

-- Ctrl-Up
function onCursorStart(view)
	aftermove_if_tree(view)
end

-- PageDown
function onCursorPageDown(view)
	selectline_if_tree(view)
end

-- Ctrl-Down
function onCursorEnd(view)
	selectline_if_tree(view)
end

function onNextSplit(view)
	selectline_if_tree(view)
end

function onPreviousSplit(view)
	selectline_if_tree(view)
end

-- On click, open at the click's y
function preMousePress(view, event)
	if view == tree_view then
		local x, y = event:Position()
		-- Fixes the y because softwrap messes with it
		local new_x, new_y = tree_view:GetMouseClickLocation(x, y)
		-- Try to open whatever is at the click's y index
		-- Will go into/back dirs based on what's clicked, nothing gets expanded
		try_open_at_y(new_y)
		-- Don't actually allow the mousepress to trigger, so we avoid highlighting stuff
		return false
	end
end

-- Up
function preCursorUp(view)
	if view == tree_view then
		-- Disallow selecting past the ".." in the tree
		if tree_view.Cursor.Loc.Y == 2 then
			return false
		end
	end
end

-- Left
function preCursorLeft(view)
	if view == tree_view then
		-- +1 because of Go's zero-based index
		-- False to not delete y
		compress_target(get_safe_y(), false)
		-- Don't actually move the cursor, as it messes with selection
		return false
	end
end

-- Right
function preCursorRight(view)
	if view == tree_view then
		-- +1 because of Go's zero-based index
		uncompress_target(get_safe_y())
		-- Don't actually move the cursor, as it messes with selection
		return false
	end
end

-- Workaround for tab getting inserted into opened files
-- Ref https://github.com/zyedidia/micro/issues/992
local tab_pressed = false

-- Tab
function preIndentSelection(view)
	if view == tree_view then
		tab_pressed = true
		-- Open the file
		-- Using tab instead of enter, since enter won't work with Readonly
		try_open_at_y(tree_view.Cursor.Loc.Y)
		-- Don't actually insert a tab
		return false
	end
end

-- Workaround for tab getting inserted into opened files
-- Ref https://github.com/zyedidia/micro/issues/992
function preInsertTab(view)
	if tab_pressed then
		tab_pressed = false
		return false
	end
end
function preInsertNewline(view)
    if view == tree_view then
        return false
    end
    return true
end
-- CtrlL
function onJumpLine(view)
	-- Highlight the line after jumping to it
	-- Also moves you to index 3 (2 in zero-base) if you went to the first 2 lines
	aftermove_if_tree(view)
end

-- ShiftUp
function preSelectUp(view)
	if view == tree_view then
		-- Go to the file/dir's parent dir (if any)
		goto_parent_dir()
		-- Don't actually selectup
		return false
	end
end

-- CtrlF
function preFind(view)
	-- Since something is always selected, clear before a find
	-- Prevents copying the selection into the find input
	clearselection_if_tree(view)
end

-- FIXME: doesn't work for whatever reason
function onFind(view)
	-- Select the whole line after a find, instead of just the input txt
	selectline_if_tree(view)
end

-- CtrlN after CtrlF
function onFindNext(view)
	selectline_if_tree(view)
end

-- CtrlP after CtrlF
function onFindPrevious(view)
	selectline_if_tree(view)
end

-- NOTE: This is a workaround for "cd" not having its own callback
local precmd_dir

function preCommandMode(view)
	precmd_dir = os.Getwd()
end

-- Update the current dir when using "cd"
function onCommandMode(view)
	local new_dir = os.Getwd()
	-- Only do anything if the tree is open, and they didn't cd to nothing
	if tree_view ~= nil and new_dir ~= precmd_dir and new_dir ~= current_dir then
		update_current_dir(new_dir)
	end
end

------------------------------------------------------------------
-- Fail a bunch of useless actions
-- Some of these need to be removed (read-only makes some useless)
------------------------------------------------------------------

function preStartOfLine(view)
	return false_if_tree(view)
end

function preStartOfText(view)
    return false_if_tree(view)
end

function preEndOfLine(view)
	return false_if_tree(view)
end

function preMoveLinesDown(view)
	return false_if_tree(view)
end

function preMoveLinesUp(view)
	return false_if_tree(view)
end

function preWordRight(view)
	return false_if_tree(view)
end

function preWordLeft(view)
	return false_if_tree(view)
end

function preSelectDown(view)
	return false_if_tree(view)
end

function preSelectLeft(view)
	return false_if_tree(view)
end

function preSelectRight(view)
	return false_if_tree(view)
end

function preSelectWordRight(view)
	return false_if_tree(view)
end

function preSelectWordLeft(view)
	return false_if_tree(view)
end

function preSelectToStartOfLine(view)
	return false_if_tree(view)
end

function preSelectToStartOfText(view)
    return false_if_tree(view)
end

function preSelectToEndOfLine(view)
	return false_if_tree(view)
end

function preSelectToStart(view)
	return false_if_tree(view)
end

function preSelectToEnd(view)
	return false_if_tree(view)
end

function preDeleteWordLeft(view)
	return false_if_tree(view)
end

function preDeleteWordRight(view)
	return false_if_tree(view)
end

function preOutdentSelection(view)
	return false_if_tree(view)
end

function preOutdentLine(view)
	return false_if_tree(view)
end

function preSave(view)
	return false_if_tree(view)
end

function preCut(view)
	return false_if_tree(view)
end

function preCutLine(view)
	return false_if_tree(view)
end

function preDuplicateLine(view)
	return false_if_tree(view)
end

function prePaste(view)
	return false_if_tree(view)
end

function prePastePrimary(view)
	return false_if_tree(view)
end

function preMouseMultiCursor(view)
	return false_if_tree(view)
end

function preSpawnMultiCursor(view)
	return false_if_tree(view)
end

function preSelectAll(view)
	return false_if_tree(view)
end

function init()
    -- Let the user disable showing of dotfiles like ".editorconfig" or ".DS_STORE"
    config.RegisterCommonOption("filemanager", "showdotfiles", true)
    -- Let the user disable showing files ignored by the VCS (i.e. gitignored)
    config.RegisterCommonOption("filemanager", "showignored", true)
    -- Let the user disable going to parent directory via left arrow key when file selected (not directory)
    config.RegisterCommonOption("filemanager", "compressparent", true)
    -- Let the user choose to list sub-folders first when listing the contents of a folder
    config.RegisterCommonOption("filemanager", "foldersfirst", true)
    -- Lets the user have the filetree auto-open any time Micro is opened
    -- false by default, as it's a rather noticable user-facing change
    config.RegisterCommonOption("filemanager", "openonstart", false)

    -- Open/close the tree view
    config.MakeCommand("tree", toggle_tree, config.NoComplete)
    -- Rename the file/dir under the cursor
    config.MakeCommand("rename", rename_at_cursor, config.NoComplete)
    -- Create a new file
    config.MakeCommand("touch", new_file, config.NoComplete)
    -- Create a new dir
    config.MakeCommand("mkdir", new_dir, config.NoComplete)
    -- Delete a file/dir, and anything contained in it if it's a dir
    config.MakeCommand("rm", prompt_delete_at_cursor, config.NoComplete)
    -- Adds colors to the ".." and any dir's in the tree view via syntax highlighting
    -- TODO: Change it to work with git, based on untracked/changed/added/whatever
    config.AddRuntimeFile("filemanager", config.RTSyntax, "syntax.yaml")

    -- NOTE: This must be below the syntax load command or coloring won't work
    -- Just auto-open if the option is enabled
    -- This will run when the plugin first loads
    if config.GetGlobalOption("filemanager.openonstart") then
        -- Check for safety on the off-chance someone's init.lua breaks this
        if tree_view == nil then
            open_tree()
            -- Puts the cursor back in the empty view that initially spawns
            -- This is so the cursor isn't sitting in the tree view at startup
            micro.CurPane():NextSplit()
        else
            -- Log error so they can fix it
            micro.Log(
                "Warning: filemanager.openonstart was enabled, but somehow the tree was already open so the option was ignored."
            )
        end
    end
end
