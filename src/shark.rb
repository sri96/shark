#Shark is a simple testing tool for testing file system operations. It is still under development

require 'optparse'
require 'fileutils'

class Shark

  def initialize(a1,a2,a3)

    @features_directory = a1

    @files_directory = a2

    @base_path = a3

  end

  def start_test

    def read_file_line_by_line(input_path)

      file_id = open(input_path)

      file_line_by_line = file_id.readlines()

      file_id.close

      return file_line_by_line

    end

    def find_file_name(input_path, file_extension)

      extension_remover = input_path.split(file_extension)

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("/")

      remaining_string = remaining_string.reverse

      return remaining_string[remaining_string.length-path_finder..-1]

    end

    def parse_feature(input_feature_contents)

      #This method extracts scenarios from a feature file

      #Input:
      #input_feature_contents => An array containing the contents of a feature file

      #Output:
      #feature_name => Name and description of the feature described in the file
      #modified_scenarios => An array containing scenario descriptions and scenario steps

      def find_all_matching_indices(input_string,pattern)

        locations = []

        index = input_string.index(pattern)

        while index != nil

          locations << index

          index = input_string.index(pattern,index+1)


        end

        return locations


      end

      while input_feature_contents[0].eql?("\n")

        input_feature_contents.delete_at(0)

      end

      feature_contents_string = input_feature_contents.join

      feature_name = ""

      if feature_contents_string.include?("Scenario:")

        feature_name = feature_contents_string[feature_contents_string.index("Feature:")...feature_contents_string.index("Scenario:")].rstrip

      else

        feature_name = feature_contents_string.rstrip

      end

      scenarios = []

      scenarios_index = find_all_matching_indices(feature_contents_string,"Scenario:")

      scenarios_index << -1

      for x in 0...scenarios_index.length-1

        scenario = feature_contents_string[scenarios_index[x]...scenarios_index[x+1]]

        scenarios << [scenario.lstrip]

      end

      modified_scenarios = scenarios.dup

      scenarios.each_with_index do |s,index|

        scenario_steps = s[0].split("    ")[1..-1]

        modified_scenarios[index] << scenario_steps

      end

      return feature_name,modified_scenarios

    end

    def parse_and_test_steps(input_steps,test_files_directory,configuration,config_variables,base_path)

      #This method parses the steps for a given scenario and produces a result using the following keywords

      #Keywords

      #Input
      #File
      #When
      #Run
      #Output
      #Equal

      #Input:
      #input_steps => An array containing the steps

      #Output:
      #test_result => A string and a boolean containing the results of the test

      def read_file_line_by_line(input_path)

        file_id = open(input_path)

        file_line_by_line = file_id.readlines()

        file_id.close

        return file_line_by_line

      end

      input_procedures = input_steps.reject {|element| !element.include?("$input")}

      input_file_names = []

      input_procedures.each do |procedure|

        if procedure.include? "$file"

          opening_quotes = procedure.index("\"")

          file_name = procedure[opening_quotes...procedure.index("\"",opening_quotes+1)]

          input_file_names << file_name

        end

      end

      input_file_contents = input_steps.dup

      test_files_directory = test_files_directory.sub(Dir.pwd,"").sub("/","")

      input_file_names = input_file_names.collect{|element| test_files_directory+element[1..-1]}

      run_procedures = input_file_contents.reject{ |element| !element.include?("$run")}

      run_keywords = ["$cliusage"]

      configuration_vars = config_variables.keys

      modified_keyword_usage = nil

      executable_statements = [[]]*configuration_vars.length

      run_keywords.each do |keyword|

        keyword_usage = configuration.reject { |element| !element.include?(keyword)}

        modified_keyword_usage = keyword_usage.dup

        keyword_usage.each_with_index do |line,index|

          configuration_vars.each_with_index do |var,var_index|

            modified_keyword_usage[index] = modified_keyword_usage[index].gsub(var,"#{config_variables[var]}")

            statement_split = modified_keyword_usage[index].split("=>")

            executable_statements[var_index] << statement_split[1].lstrip.rstrip

          end

        end

      end

      configuration_vars.each_with_index do |var,index|

        current_var_run_procedures = run_procedures.reject{|element| !element.include?(var)}

        current_var_run_procedures.each do |run|

          current_executable_statements = executable_statements[index]

          current_executable_statements.each do |executable|

            input_file_names.each do |file_name|

              current_executable_statement = executable.gsub("$file",file_name)

              cli_output = `#{current_executable_statement.strip.lstrip.rstrip}`

            end

          end

        end


      end

      output_procedures = input_steps.reject {|element| !element.include?("$output")}

      matching_file_names = []

      output_file_names = []

      output_procedures.each do |procedure|

        if procedure.include?("$equal") and procedure.include?("$file")

          opening_quotes = procedure.index("\"")

          file_name = procedure[opening_quotes...procedure.index("\"",opening_quotes+1)]

          matching_file_names << file_name

        else

          opening_quotes = procedure.index("\"")

          file_name = procedure[opening_quotes...procedure.index("\"",opening_quotes+1)]

          output_file_names << file_name

        end

      end

      output_file_names = output_file_names.collect {|element| test_files_directory + element[1..-1]}

      matching_file_names = matching_file_names.collect {|element| test_files_directory+element[1..-1]}

      output_file_contents = output_file_names.collect{ |element| read_file_line_by_line(element)}

      matching_file_contents = matching_file_names.collect{ |element| read_file_line_by_line(element)}

      test_results = []

      false_results = []

      matching_file_contents.each_with_index do |matching_file,matching_index|

        false_results << [matching_file_names[matching_index]]

        output_file_contents.each_with_index do |output_file,index|

          if matching_file.eql?(output_file)

             test_results << true

          else

            test_results << false

            false_results[-1] << [output_file_names[index]]

          end

        end

      end

      if test_results.include?(false)

        output_string = "\nThe test failed!\n\nA detailed breakdown of the failing files have been given below."

        output_string = output_string + "\n\n"

        detailed_fail_list = ""

        false_results.each do |result|

          detailed_fail_list = detailed_fail_list + "The following files failed in comparison with #{result[0]}"

          failed_files = result[1]

          failed_files.each do |file|

            detailed_fail_list = detailed_fail_list + "\n\n" + "* #{file}\n"

          end

        end

        return output_string = output_string + detailed_fail_list

      else

        return "\nYour test file(s) passed the feature test.\n\n"

      end

    end

    def extract_configurations(feature_contents)

      config_start_index = 0

      feature_contents.each_with_index do |line,index|

        if line.include?("Configurations:")

          config_start_index = index

        end

      end

      modified_feature_contents = feature_contents[0...config_start_index]

      configurations = feature_contents[config_start_index..-1]

      configuration_variables = configurations.join.match(/~\w{1,}/).to_a

      configuration_variable_index = [[]]*configuration_variables.length

      configurations.each_with_index do |line,index|

        configuration_variables.each_with_index do |variable,var_index|

          if line.include?(variable)

            configuration_variable_index[var_index] << index

          end

        end

      end

      configuration_variable_index = configuration_variable_index.collect{ |element| element[0]}

      configuration_variable_index << configurations.length-1

      modified_configurations = configurations.dup

      for x in 0...configuration_variable_index.length-1

        current_index = configuration_variable_index[x]

        current_variable = configuration_variables[x]

        for y in current_index..configuration_variable_index[x+1]

          modified_configurations[y] = configurations[y].gsub(":v",current_variable)

        end

      end

      configuration_var_values = []

      configuration_variable_index.delete_at(1)

      configuration_variable_index.each do |index|

        var_split = modified_configurations[index].split("=>")

        var_value = var_split[1].lstrip.rstrip

        configuration_var_values << var_value

      end

      configuration_values = Hash[configuration_variables.zip(configuration_var_values)]

      return modified_feature_contents,modified_configurations,configuration_values

    end

    list_of_features = []

    Dir.foreach(@features_directory) { |x| list_of_features << @features_directory+"#{x}" }

    list_of_features.delete_at(0); list_of_features.delete_at(0)

    list_of_features.each do |feature_path|

      feature_contents = read_file_line_by_line(feature_path)

      feature_contents,configurations,config_values = extract_configurations(feature_contents)

      feature_name,scenarios = parse_feature(feature_contents)

      puts feature_name

      scenarios.each do |scenario|

        scenario[1] = scenario[1].collect{|element| element.sub("input","$input")}

        scenario[1] = scenario[1].collect{|element| element.sub("file","$file")}

        scenario[1] = scenario[1].collect{|element| element.sub("run","$run")}

        scenario[1] = scenario[1].collect{|element| element.sub("output","$output")}

        scenario[1] = scenario[1].collect{|element| element.sub("equal","$equal")}

        output = parse_and_test_steps(scenario[1],@files_directory,configurations,config_values,@base_path)

        puts output + "\n\n"

      end

    end

  end

end

def create_mac_executable(input_file)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  mac_file_contents = ["#!/usr/bin/env ruby\n\n"] + read_file_line_by_line(input_file)

  mac_file_path = input_file.sub(".rb","")

  file_id = open(mac_file_path,"w")

  file_id.write(mac_file_contents.join)

  file_id.close

end

OptionParser.new do |opts|

  opts.banner = "Usage: shark [options]"

  opts.on("-t", "--test", "Start Test") do

    current_directory = Dir.pwd + "/shark/"

    base_path = Dir.pwd

    features_directory = current_directory + "features/"

    test_files_directory = current_directory + "test_files/"

    tester = Shark.new(features_directory, test_files_directory, base_path)

    tester.start_test()

  end

  opts.on("-i","--init","Initialize Shark in this project") do

    FileUtils.mkdir_p "Shark\\features"

    FileUtils.mkdir_p "Shark\\test_files"

    puts "Shark has been successfully initialized!"

  end

  opts.on("-m", "--buildmac", "Builds Mac Executables") do

    file_path = Dir.pwd + "/shark.rb"

    create_mac_executable(file_path)

    puts "Build Successful!"

  end

end.parse!