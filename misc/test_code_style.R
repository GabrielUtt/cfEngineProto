print("This is a test wheter linter has a problem with a line that has more than eighty characters if the setting is so") # test_line_length_linter()

a = 13  #test assignment_linter()

if_else(a<13, TRUE, FALSE) # test commas_linter()

read.csv(file = "C:/absolute/paht") # test absolute_path_linter()

this_is_a_very_long_variable_name <- "hello world" # test object_length_linter()

thisIsNotSnakeCase <- "hello world" # test object_name_linter()



f_space <- function (){ #test spaces_left_parentheses_linter
  print("hello world")
}

f_space() 

# test trailing_whitespace_linter
b  =14 

# test trailing_blank_lines_linter
