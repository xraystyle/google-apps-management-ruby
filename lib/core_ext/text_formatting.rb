# This is a small extension to the string class which provides various color
# and formatting outputs for text in the terminal without adding any dependencies
# on additional gems. Credit for this goes to this StackOverflow answer: http://stackoverflow.com/a/11482430
# and this page for the references: http://misc.flogisoft.com/bash/tip_colors_and_formatting
# Colors and formatting are for 16 color terminals.

class String

	def self.available_colors #Useful in IRB if you need a quick color list.

		puts "\nAvailable formatting options:"
		puts
		puts "bold\ndim\nunderlined\nblink\nreverse\n\n"

		puts "\nAvailable text colors:"
		puts
		puts "red\ngreen\nyellow\nblue\nmagenta\ncyan\nlight_gray\ndark_gray\nlight_red\nlight_green\nlight_yellow\nlight_blue\nlight_magenta\nlight_cyan\nwhite\n\n"

		puts "Available highlight colors:"
		puts
		puts "red\ngreen\nyellow\nblue\nmagenta\ncyan\nlight gray\ndark gray\nlight red\nlight green\nlight yellow\nlight blue\nlight magenta\nlight cyan\nwhite\n\n"

	end


	# Add the color code escape characters to the string.
	def colorize(color_code)
		"\e[#{color_code}m#{self}\e[0m"
	end


	# Color code definitions for formatting.

	def bold
		colorize(1)
	end

	def dim
		colorize(2)
	end

	def underlined
		colorize(4)
	end

	def blink
		colorize(5)
	end

	def reverse
		colorize(7)
	end

	def hidden # hide the output. Useful for passwords.
		colorize(8)
	end

	# Color code definitions for the text itself.

	def red
		colorize(31)
	end

	def green
		colorize(32)
	end

	def yellow
		colorize(33)
	end

	def blue
		colorize(34)
	end

	def magenta
		colorize(35)
	end

	def cyan
		colorize(36)
	end

	def light_gray
		colorize(37)
	end

	def dark_gray
		colorize(90)
	end

	def light_red
		colorize(91)
	end

	def light_green
		colorize(92)
	end

	def light_yellow
		colorize(93)
	end

	def light_blue
		colorize(94)
	end

	def light_magenta
		colorize(95)
	end

	def light_cyan
		colorize(96)
	end

	def white
		colorize(97)
	end

	def black
		colorize(30)
	end

	# Color code definitions for highlighting colors.

	def highlight_red
		colorize(41)
	end

	def highlight_green
		colorize(42)
	end

	def highlight_yellow
		colorize(43)
	end

	def highlight_blue
		colorize(44)
	end

	def highlight_magenta
		colorize(45)
	end

	def highlight_cyan
		colorize(46)
	end

	def highlight_light_gray
		colorize(47)
	end

	def highlight_dark gray
		colorize(100)
	end

	def highlight_light_red
		colorize(101)
	end

	def highlight_light_green
		colorize(102)
	end

	def highlight_light_yellow
		colorize(103)
	end

	def highlight_light_blue
		colorize(104)
	end

	def highlight_light_magenta
		colorize(105)
	end

	def highlight_light_cyan
		colorize(106)
	end

	def highlight_white
		colorize(107)
	end

end
























