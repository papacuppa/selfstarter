module ApplicationHelper
def number_to_currency(number, options = {})
options = options.stringify_keys
precision, unit, separator, delimiter = options.delete("precision") { 2
}, options.delete("unit") { "£" }, options.delete("separator") { "." },
options.delete("delimiter") { "," }
separator = "" unless precision > 0
begin
	parts = number_with_precision(number, precision).split('.')
	unit + number_with_delimiter(parts[0], delimiter) + separator +
parts[1].to_s
rescue
	number
end
