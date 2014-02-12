#!/usr/bin/ruby
require 'rubygems'
#require 'fastercsv'
require 'csv'
load 'pre_check_utils.rb'

@import_directory_path = ARGV[0].to_s
@google_domain = ARGV[1].to_s
@google_domain1 = ARGV[2].to_s
PreCheckUtils.check_directory_contents_and_encoding(@import_directory_path)

@health_check = 0
# was unable to finish making the code below into a method
# @partial_import_switch = ""
# PreCheckUtils.partial_import_switch_check(@import_directory_path, @partial_import_switch)
partial_file_name_match = 0
Dir.foreach("#{@import_directory_path}") do |x|
  partial_file_name_match += 1 if x.include?("update_") || x.include?("delete_")
end
if partial_file_name_match > 0
  @partial_import_switch = "update_"
  puts "#{partial_file_name_match} partial import files were found. It will be assumed that this is a partial import.".red
  puts ""
else 
  @partial_import_switch = ""
end

# took the below from import code in hopes that this will be one less thing to integrate
ORGANIZATIONS_COLUMNS = [:external_id, :name, :organization_id]
USERS_COLUMNS = [:external_id, :first_name, :middle_init, :last_name, :suffix, :nickname, :login, :password, :email, :user_type, :organization_id, :enabled, :display_id, :google_email_address]
USERS_LEVELS_COLUMNS = [:user_id, :level_id]
CLASSES_COLUMNS = [:external_id, :name, :shortname, :description, :code, :year, :teacher_id, :organization_id]
PARENT_CHILD_COLUMNS = [:parent_id, :child_id]
ROSTER_COLUMNS = [:eclass_id, :user_id, :role]
# used in compare_expected_column_titles_with_actual_from_csv method
import_column_collection = {"users.csv" =>USERS_COLUMNS, "classes.csv" => CLASSES_COLUMNS, "roster.csv" => ROSTER_COLUMNS, "organizations.csv" => ORGANIZATIONS_COLUMNS, "users_levels.csv" => USERS_LEVELS_COLUMNS, "parent_child.csv" => PARENT_CHILD_COLUMNS,"update_users.csv" =>USERS_COLUMNS, "update_classes.csv" => CLASSES_COLUMNS, "update_roster.csv" => ROSTER_COLUMNS, "update_organizations.csv" => ORGANIZATIONS_COLUMNS, "update_users_levels.csv" => USERS_LEVELS_COLUMNS, "update_parent_child.csv" => PARENT_CHILD_COLUMNS }

csv_file_name_and_expected_column_count = {"users.csv" => 14, "classes.csv" => 8, "roster.csv" => 3, "organizations.csv" => 3, "users_levels.csv" => 2, "parent_child.csv" => 2}
csv_file_name_and_expected_column_count.each do |file, col|
  
  file = "update_#{file}" if @partial_import_switch == "update_"  

  puts "======================== #{file} ========================"
  if File.zero?("#{@import_directory_path}/#{file}")
    puts "#{file} is zero bytes...skipping!".red
    puts "================================================"
    puts ""
  elsif File.exists?("#{@import_directory_path}/#{file}")
    puts "#{file} file is here!".green
    
    PreCheckUtils.count_number_of_columns_in_csv_file(file, col, @import_directory_path)
    PreCheckUtils.compare_expected_column_titles_with_actual_from_csv(file,import_column_collection[file],@import_directory_path)
    PreCheckUtils.count_number_of_rows_in_the_csv_file(file,@import_directory_path)
  
    case file
      when "#{@partial_import_switch}users.csv"
        PreCheckUtils.google_id_domain_split_list(@import_directory_path,@partial_import_switch)
        PreCheckUtils.google_domain_check(@import_directory_path, file, @google_domain)
        PreCheckUtils.google_second_domain_check(@import_directory_path, file, @google_domain1)
        PreCheckUtils.user_type_count_by_category_for_users_csv(@import_directory_path,@partial_import_switch)
        @return_users_duplicate_import_id_report =  PreCheckUtils.duplicate_import_id_in_users_and_classes_csv(file,@import_directory_path)
        PreCheckUtils.users_csv_login_and_password_issue_check(file,@import_directory_path)
        PreCheckUtils.report_users_csv_organization_id_with_import_id_in_organizations_csv(@import_directory_path,@partial_import_switch)
        puts " "  
      when "#{@partial_import_switch}classes.csv"
        PreCheckUtils.report_classes_csv_rows_with_no_teacher_in_users_csv(@import_directory_path, @partial_import_switch)
        @return_classes_duplicate_import_id_report = PreCheckUtils.duplicate_import_id_in_users_and_classes_csv(file,@import_directory_path)
        PreCheckUtils.report_classes_csv_organization_id_with_import_id_in_organizations_csv(@import_directory_path,@partial_import_switch)
        puts " "
      when "#{@partial_import_switch}roster.csv"
        PreCheckUtils.report_roster_csv_rows_with_no_users_in_users_csv(@import_directory_path,@partial_import_switch)
        PreCheckUtils.report_roster_csv_rows_with_no_class_in_classes_csv(@import_directory_path,@partial_import_switch)
        puts " "
    end
    puts " "
  else
    if file == "users.csv" || file == "classes.csv" || file == "roster.csv"
      puts "WARNING: The #{file} file (a required file) is not included in the folder or is not spelled exactly #{file}".red
    else
      #I am including the code below, just in case the file was supposed to be include, i.e. not spelled correctly
      puts "Note: The #{file} file (an optional file) is not included in the folder or is not spelled exactly #{file}".cyan
    end
    puts "================================================"
    puts ""
   end
end


 
