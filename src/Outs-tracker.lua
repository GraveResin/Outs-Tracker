--[[======================================x
    This script is to help keep track of
    the outs in the meat department at
    ███████ in ██████, ██ 1/8/2025.
        --Written by:GraveResin
            --keep it clean
                --mind the mess
x======================================]] --

--//////
local function menu()
	print("File backup routines will be added soon.")
	print("\nPlease select from the options:")
	print("1: Starting Outs")
	print("2: Ending Outs")
	print("3: View todays list")
	print("4: Delete all")
	print("5: Exit program\n:[?]:")
end
--//////

--//////
--Checks if the file exists and returns
--true of false depending.
local function file_exist(file_name)
	local file = io.open(file_name, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end
--//////

--//////
--Checks if the input is a number.
local function get_number(prompt)
	while true do
		io.write(prompt)
		local input = io.read()
		local number = tonumber(input)
		if number then
			return number
		else
			print("Invalid input. Enter a number.")
		end
	end
end
--//////

--//////
--Takes the items number and adds all together to get a total.
local function calculate_total(items)
	local total = 0
	for key, item in pairs(items) do
		total = total + item.number
	end
	return total
end
--//////

--//////
--Holds the logic for writing the data to the file.
local function write_to_file(filename, items, current_list)
	--calculates the total number of outs
	local total = calculate_total(items)
	local file = io.open(filename, "a")
	if not file then
		print("Could not open " .. filename)
		return
	end
	--Writes the data to the file along with the current date.
	file:write(current_list .. " " .. os.date("%m/%d/%y\n"))
	for key, item in pairs(items) do
		file:write(string.format("%s, Number: %d\n", item.name, item.number))
	end
	file:write(string.format("Total number of Outs: %d\n", total))
	file:write("////////////////////\n\n")
	file:flush()
	file:close()
end
--//////

--//////
--clears the screen for both windows and unix systems hopefully
local function screen_clear()
	--os.execute("clear")
	if package.config:sub(1,1) == "\\" then
		os.execute("cls")
	else
		os.execute("clear")
	end

end
--//////

--//////
--[[
--Makes the directory that the list will be outputted in.
local function folder_exists()
	local folder_name = "lists"
	local command
	--attempts to make this work on both Windows and Unix/Linux
	if package.config:sub(1, 1) == "\\" then
		command = "mkdir " .. folder_name
	else
		command = "mkdir -p " .. folder_name
	end

	local success = os.execute(command)
	screen_clear()
	if success then
		print("Folder , " .. folder_name .. ", created successfully")
	else
		print("Failed to create: " .. folder_name .. ". Can not continue.")
		print("Exiting...")
		os.exit()
	end
end
]]--
--//////

--//////
--Makes the list type
local out_list_type
--This handels the logic for making the file if it does not exist
local file_name = "outs_list.txt"
if not file_exist(file_name) then
	while true do
		print(file_name .. " is not found. Make new one? y/n")
		local selection = io.read()
		if selection == "y" then
			screen_clear()
			local new_file, err = io.open(file_name, "w")
			--Throws an error if the file cannot be opened.
			if not new_file then
				print("Error opening file: " .. (err or "unkown error"))
			else
				--Gives the date of creation.
				local date_made = os.date("%m/%d/%y\n\n")
				new_file:write("File created on " .. date_made)
				new_file:flush()
				new_file:close()
				print("File created.")
				break
			end
		elseif selection == "n" then
			print("Cannot continue without " .. file_name .. ", exiting")
			os.exit()
		else
			print("Invalid option.")
		end
	end
end
--//////

--//////
--Just closes the file when called if the file is even open or able to be closed
local function file_close(file, err)
	if not file then
		print("Error closing file: " .. (err or "unkown errer"))
	else
		file:flush()
		file:close()
	end
end
--//////

--//////
local function print_list(file_read)
	--Read the file to find today's outs list.
	local today = os.date("%m/%d/%y")
	local file, err = io.open(file_name, "r")
	if not file then
		print("Could not open file: " .. file_name)
	else
		local in_today_section = false
		local found_starting_outs = false
		local found_ending_outs = false

		print("Today's outs list (" .. today .. "):")
		for line in file:lines() do
			--Check for today's starting or ending sections.
			if line:find(today) and line:find("Starting Outs") then
				in_today_section = true
				found_starting_outs = true
				--Print "Starting Outs" header.
				print("\n" .. line)
			elseif line:find(today) and line:find("Ending Outs") then
				in_today_section = true
				found_ending_outs = true
				--Print "Ending Outs" header.
				print("\n" .. line)
			elseif in_today_section then
				--Stop reading if we reach the end of today's section,
				if line:find("////////////////////") then
					in_today_section = false
				else
					--Print lines in today's section.
					print(line)
				end
			end
		end
		file_close(file, err)

		--Handle cases where no data was found for today.
		if not found_starting_outs and not found_ending_outs then
			print("No data found for today (" .. today .. ").")
		end
	end
end
--//////

--//////
--Prints the list when called
local function display_counts(items, list_type)
	screen_clear()
	print("\n" .. list_type .. " " .. os.date("%m/%d/%y"))
	for _, item in pairs(items) do
		print("", item.name, "Number of outs:", item.number)
	end
	local total = calculate_total(items)
	print("The total number of outs is:", total)
end
--//////

--//////
--prints the prompt to input the numbers for the lists
local function update_items(items)
	for key, item in pairs(items) do
		print("Updating data for:", item.name)
		local new_number = get_number("Enter a new number for " .. item.name .. ": ")
		item.number = new_number
	end
end
--//////

--//////
--replaces newlines with whitespace and attempts to remove odd characters
local function sanitize(note)
	note = note:gsub("[\r\n]", " ")
	return note
end
--//////

--//////
local function get_note()
	--max character length
	local max_length = 200
	while true do
		print("Enter yor note (max " .. max_length .. " characters)")
		local note = io.read()
		--Trims off whitespace
		note = note:match("^%s*(.-)%s*$")
		if note and note ~= " " then
			if #note <= max_length then
				return sanitize(note)
			else
				print("Note is too long. The character limit it " .. max_length)
			end
		else
			print("Note cannot be empty. Please try again.")
		end
	end
end
--//////

--[[
	Start of the main portion of the program.
]] --
--Contains all of the items that we need. Change as needed.
local items = {
	CKN = { name = "CKN", number = 0 },
	PRK = { name = "Prk", number = 0 },
	STK = { name = "STK", number = 0 },
	GB  = { name = "GB", number  = 0 }
}

screen_clear()
while true do
	local file, err = io.open(file_name, "a")
	--Displays the options to select.
	menu()

	--holds the option that was selected
	local option_selected = io.read()

	--All the option logic will is held here.
	--This will ask the user for the outs
	--assoiciated with the item.
	if option_selected == "1" then
		screen_clear()
		out_list_type = "Starting Outs"
		update_items(items)
		write_to_file(file_name, items, out_list_type)
		screen_clear()
		--Asks if you would like to see the outs and the total outs.
		print("Would you like to see the counts of each item and the total outs? y/n")
		while true do
			local print_option = io.read()
			if print_option == "y" then
				screen_clear()
				display_counts(items, out_list_type)
				print("Press enter to continue...")
				local cont = io.read()
				break
				--Exits if "n" is selected
			elseif print_option == "n" then
				screen_clear()
				print("Use option 3 in the menu to view at any time")
				file_close(file, err)
				break
			else
				print("Invalid option selected")
			end
		end
		--End of Option 1

		--Option 2
	elseif option_selected == "2" then
		screen_clear()
		out_list_type = "Ending Outs"
		update_items(items)
		write_to_file(file_name, items, out_list_type)
		screen_clear()
		while true do
			print("Would you like to see the counts of each item and the total outs? y/n")
			local print_option = io.read()
			if print_option == "y" then
				display_counts(items, out_list_type)
				print("Press enter to continue...")
				local cont = io.read()
				break
				--Exits if "n" is selected
			elseif print_option == "n" then
				screen_clear()
				print("Use option 3 in the menu to view at any time")
				break
				--file_close(file, err)
			else
			screen_clear()
				print("Invalid option selected")
			end
		end
		--Note Section
		while true do
			print("Leave a note for today? y/n")
			local note_option = io.read()
			if note_option == "y" then
				screen_clear()
				print("Note:\n")
				local note_text = get_note()
				if not file then
					print("Error finding file: " .. (err or "Unkown errer"))
				else
					file:write("Notes for: " .. os.date("%m/%d/%y") .. "\n")
					file:write(note_text .. "\n////////////////////\n")
					file:flush()
					print("Note written successfully.")
					break
				end
			elseif note_option == "n" then
				if not file then
					print("Error finding file: " .. (err or "Unknown error"))
					break
				else
					file:write("Notes for: " .. os.date("%m/%d/%y") .. "\n")
					file:write(":[No Notes]:\n////////////////////\n")
					file:flush()
					break
				end
			else
				screen_clear()
				print("Invalid option")
			end
		end
		--End of Option 2 and Note Section

		--Option 3
	elseif option_selected == "3" then
		screen_clear()
		print_list(file_name)
		print("Press enter to continue...")
		local cont = io.read()
		screen_clear()
		file_close(file, err)
		--End of Option 3

		--Option 4
	elseif option_selected == "4" then
		screen_clear()
		print("This has yet to be implemented. Delete the file manually.")
		file_close(file, err)
		--End of option 4
	elseif option_selected == "5" then
		file_close(file, err)
		screen_clear()
		print("Exiting. Have a good day.")
		break
	else
		print("Not and option. Kick rocks")
		file_close(file, err)
	end
end
--End of Option 4
