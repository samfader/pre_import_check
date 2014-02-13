class PreCheckUtils
  # directory path, check if empty and contents
  def self.check_directory_contents_and_encoding(import_directory_path)
    # the code below will allow folder to be entered within terminal as arg[0]
    if import_directory_path.empty?
      puts "Oops, you didn't give the script a directory path.".red
      puts "Drag and drop the folder into terminal after typing `ruby pre_check.rb ` or type out the path and hit the Return key.".yellow
      exit 1
    else
      puts ""
      puts "The directory you entered is: #{import_directory_path}".green
      puts ""
      # display names of folders within directory
      puts "Below are the contents of the provided directory:"
      Dir.foreach("#{import_directory_path}") do |x| 
        if x.to_s == "."
        elsif x.to_s == ".."
        else
          if x.encoding.to_s == 'UTF-8'
            puts "#{x} (#{x.encoding} encoding)".green
          else
            puts "#{x} (#{x.encoding} encoding)".red
          end
        end
      end
      puts ""
    end
  end
  
  # unable to finish making the code below into a method
  # method to check if files partial files, if so run as a partial import and not as a full import 
  def self.partial_import_switch_check(import_dir,partial_import_switch)
    Dir.foreach("#{import_dir}") do |x|
      partial_file_name_match += 1 if x.include?("update_") || x.include?("delete_")
    end
    if partial_file_name_match > 0
      partial_import_switch = "update_"
      puts "#{partial_file_name_match} partial import files were found. It will be assumed that this is a partial import.".red
      puts ""
    else 
      partial_import_switch = ""
    end
  end
  
  #created this method to compute health check value since a paramater is just a reference and cannot update the original instance variable
  def self.intialize_health_check
    @health_check = 0
  end
  def self.health_check
    @health_check
  end
  
  # counts the number of columns included in the file so that it can be used to compare against expected number of columns
  def self.count_number_of_columns_in_csv_file(file, col, import_dir)
    column_header = File.open("#{import_dir}/#{file}").first
    column_count = 0
    column_count = column_header.split(',').length
    
    printf("%-20s | %21s\n", "Actual # of Columns", "Expected # of Columns")
    printf("%-20s | %21s\n".bold.reverse_color, column_count, col)
    
    if column_count == col  
      puts "You have the exact number of expected columns in your #{file} file, great job!".green
    elsif column_count > col
      puts "You have more columns than expected, compare titles below.".cyan
    else
      @health_check += 1
      puts "You have less columns than expected, compare titles below.".yellow
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method count_number_of_columns_in_csv_file: #{er.message}".red 
  end
  
  # method to compare column titles between what is expected and what is actually in the csv file
  def self.compare_expected_column_titles_with_actual_from_csv(file, column, import_dir)
  # compare columns from spec to columns found in import file 
    if File.exists?("#{import_dir}/#{file}")
      puts ""
      puts "Here are the column title comparisons for #{file}".green
      column_header = File.open("#{import_dir}/#{file}").first
      column_header = column_header.split(',')
      hash_head2 = Hash[column.zip column_header]
      hash_head2.each do |spec, import| 
        printf("%-20s | %15s\n", spec, import)
      end
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method compare_expected_column_titles_with_actual_from_csv: #{er.message}".red
  end

  # counts rows starting with -1 due to the header row
  def self.count_number_of_rows_in_the_csv_file(file, import_dir)
    row_count = -1
    File.foreach("#{import_dir}/#{file}") {|row| row_count += 1}
    puts "There are #{row_count} rows (minus the header) in the #{file} file. ".green
    # the code below counts ROWS much easier than above, but don't want to make any changes before codes goes out tomorrow
    #file1_lines = CSV.read("#{@import_dir}/classes.csv")
    #puts file1_lines.size
  end

  # uses arg[1] to check if the google id column in the users.csv file contains any email addresses with the inputed value (this arg is optional and will not break if left blank)
  def self.google_domain_check(import_dir, file, google_domain)
    if google_domain.empty?
    else
      user_row_count = CSV.read("#{import_dir}/#{file}")
      user_row_num = 1
      google_id_match = 0
      google_id_nil = 0
      google_id_no_match = 0
      google_domain_report = "The following are the import_ids and rows that match domain #{google_domain}: \n"
      while user_row_num <= user_row_count.size-1
        if user_row_count[user_row_num][13].nil? || user_row_count[user_row_num][13].empty?
          google_id_nil +=1
        elsif user_row_count[user_row_num][13].include?(google_domain)
          google_id_match += 1
          #google_domain_report += " id:#{user_row_num} @ row:#{user_row_count[user_row_num][0]}, ".pink
          #elsif user_row_count[user_row_num][13] == ''
          #google_id_nil +=1
        else
          google_id_no_match +=1
        end 
          user_row_num += 1
      end
      puts ""
       if google_id_match >0
        # puts google_domain_report.green
       end
      puts "Information regarding Google Domain #{google_domain}".green
      printf("%-10s | %10s | %10s | %14s\n", "total #", "# matched", "# no match", "# nil or empty")
      printf("%-10s | %10s | %10s | %14s\n".bold.reverse_color, user_row_num-1, google_id_match, google_id_no_match, google_id_nil )
      puts ""
    end
  end 
  
  # uses arg[2] to check if the second google id column in the users.csv file contains any email addresses with the inputed value (this arg is optional and will not break if left blank)
  def self.google_second_domain_check(import_dir, file, google_domain1)
    if google_domain1.empty?
    else
      # can leave the arg as file because it will only be called with either users.csv or update_users.csv according to case
      user_row_count = CSV.read("#{import_dir}/#{file}")
      user_row_num = 1
      google_id_match = 0
      google_id_nil = 0
      google_id_no_match = 0
      google_domain_report = "The following are the import_ids and rows that match your second domain #{google_domain1}: \n"
      while user_row_num <= user_row_count.size-1
        if user_row_count[user_row_num][13].nil? || user_row_count[user_row_num][13].empty?
          google_id_nil +=1
        elsif user_row_count[user_row_num][13].include?(google_domain1)
          google_id_match += 1
        else
          google_id_no_match +=1
        end 
          user_row_num += 1
      end
      puts ""
       if google_id_match >0
       end
      puts "Information regarding Google Domain #{google_domain1}".green
      printf("%-10s | %10s | %10s | %14s\n", "total #", "# matched", "# no match", "# nil or empty")
      printf("%-10s | %10s | %10s | %14s\n".bold.reverse_color, user_row_num-1, google_id_match, google_id_no_match, google_id_nil )
      puts ""
    end
  end 
  
  # compares teacher id values from the classes.csv file with the import ids in the users.csv file to see if the class and roster will fail
  def self.report_classes_csv_rows_with_no_teacher_in_users_csv(import_dir, partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}users.csv") && File.exists?("#{import_dir}/#{partial_import_switch}classes.csv")   
      teacher_import_id_match = 0
      teacher_import_id_no_match = 0
      teacher_nil_or_empty = 0
      row_count = 0
      class_teacher_id_not_found_report = "The following are teacher_id values from #{partial_import_switch}classes.csv with no matching row in #{partial_import_switch}users.csv: \n".green

      user_import_ids = {}
      unique_class_teacher_id_not_found = {}
      File.foreach("#{import_dir}/#{partial_import_switch}users.csv") do |x|
        x = CSV.parse(x)
        user_import_ids[x[0][0]] = true
      end

      File.foreach("#{import_dir}/#{partial_import_switch}classes.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        teacher_import_id = x[0][6]
        if teacher_import_id.nil? || teacher_import_id.empty?
          teacher_nil_or_empty += 1
        elsif user_import_ids[teacher_import_id] == true
          teacher_import_id_match += 1
        else
          teacher_import_id_no_match += 1
          unique_class_teacher_id_not_found[teacher_import_id] = true
        end
      end
      if teacher_import_id_no_match > 1
        unique_class_teacher_id_not_found.each do | x, y|
          class_teacher_id_not_found_report += "#{x.pink}, "
        end
        puts class_teacher_id_not_found_report
      end
      puts ""
      puts "Information regarding teacher_id values from #{partial_import_switch}classes.csv compared with row in #{partial_import_switch}users.csv".green
      printf("%-21s | %12s | %13s | %14s\n", "expected # of matches", "# of matches", "without match", "# nil or empty")
      printf("%-21s | %12s | %13s | %14s\n".bold.reverse_color,  row_count-1, teacher_import_id_match, teacher_import_id_no_match, teacher_nil_or_empty)
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method report_classes_csv_rows_with_no_teacher_in_users_csv: #{er.message}".red 
  end
  
  # compares class id from the roster.csv file with the import id of the classes.csv file to see if any rosters will fail
  def self.report_roster_csv_rows_with_no_class_in_classes_csv(import_dir, partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}roster.csv") && File.exists?("#{import_dir}/#{partial_import_switch}classes.csv")
      roster_class_id_match = 0
      roster_class_id_no_match = 0
      roster_class_id_nil_or_empty = 0
      row_count = 0
      roster_class_id_not_found_report = "The following are class_id values from roster.csv with no matching row in classes.csv: \n".green

      class_import_ids = {}
      unique_roster_class_id_not_found = {}

      File.foreach("#{import_dir}/#{partial_import_switch}classes.csv") do |x|
        x = CSV.parse(x)
        class_import_ids[x[0][0]] = true
      end
      
      File.foreach("#{import_dir}/#{partial_import_switch}roster.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        roster_user_id = x[0][0]
        if roster_user_id.nil? || roster_user_id.empty?
          roster_class_id_nil_or_empty += 1
        elsif class_import_ids[roster_user_id] == true
          roster_class_id_match += 1
        else
          roster_class_id_no_match += 1
          unique_roster_class_id_not_found[roster_user_id] = true
        end
      end
      if roster_class_id_no_match > 1
        unique_roster_class_id_not_found.each do | x, y|
          roster_class_id_not_found_report += "#{x.pink}, "
        end
        puts roster_class_id_not_found_report
      end
      puts ""
      puts "Information regarding class_id values from #{partial_import_switch}roster.csv compared with row in #{partial_import_switch}classes.csv".green
      printf("%-21s | %12s | %13s | %14s\n", "expected # of matches", "# of matches", "without match", "# nil or empty")
      printf("%-21s | %12s | %13s | %14s\n".bold.reverse_color,  row_count-1, roster_class_id_match, roster_class_id_no_match-1, roster_class_id_nil_or_empty)  
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method report_roster_csv_rows_with_no_class_in_classes_csv: #{er.message}".red
  end
  
  # compares user id from the roster.csv file with the import id of the users.csv file to see if any rosters will fail
  def self.report_roster_csv_rows_with_no_users_in_users_csv(import_dir, partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}roster.csv") && File.exists?("#{import_dir}/#{partial_import_switch}users.csv")
      roster_user_id_match = 0
      roster_user_id_no_match = 0
      roster_user_id_nil_or_empty = 0
      row_count = 0
      roster_class_id_not_found_report = "The following are user_id values from #{partial_import_switch}roster.csv with no matching row in #{partial_import_switch}users.csv: \n".green

      user_import_ids = {}
      unique_roster_class_id_not_found = {}

      File.foreach("#{import_dir}/#{partial_import_switch}users.csv") do |x|
        x = CSV.parse(x)
        user_import_ids[x[0][0]] = true
      end

      File.foreach("#{import_dir}/#{partial_import_switch}roster.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        roster_user_id = x[0][1]
        if roster_user_id.nil? || roster_user_id.empty?
          roster_user_id_nil_or_empty += 1
        elsif user_import_ids[roster_user_id] == true
          roster_user_id_match += 1
        else
          roster_user_id_no_match += 1
          ## I got this to be unique by inputing value into hash and then iterating through hash
          #roster_class_id_not_found_report += " #{roster_user_id},".pink
          unique_roster_class_id_not_found[roster_user_id] = true
        end
      end
      if roster_user_id_no_match > 1 #value of 1 until I can figure out how to stop showing the column title
        unique_roster_class_id_not_found.each do | x, y|
          roster_class_id_not_found_report += "#{x.pink}, "
        end
        puts roster_class_id_not_found_report
      end
      puts ""
      puts "Information regarding user_id values from #{partial_import_switch}roster.csv compared with row in #{partial_import_switch}users.csv".green
      printf("%-21s | %12s | %13s | %14s\n", "expected # of matches", "# of matches", "without match", "# nil or empty")
      printf("%-21s | %12s | %13s | %14s\n".bold.reverse_color,  row_count-1, roster_user_id_match, roster_user_id_no_match-1, roster_user_id_nil_or_empty) 
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method report_roster_csv_rows_with_no_users_in_users_csv: #{er.message}".red
  end
  
  # checks to see if any duplicate import ids exist in the classes.csv file or users.csv file as the last import id in the list wins.
  def self.duplicate_import_id_in_users_and_classes_csv(file,import_dir)
    if File.exists?("#{import_dir}/#{file}")
      duplicate_import_id_nil_or_empty = 0
      duplicate_import_id_report_count = 0
      row_count = 0
      return_duplicate_import_id_report = ""
      duplicate_import_id_report = "duplicate import_id values found in the #{file}: \n".green

      duplicate_import_ids = {}
      File.foreach("#{import_dir}/#{file}") do |x|
        x = CSV.parse(x)
        duplicate_import_ids[x[0][0]] = 0
      end

      File.foreach("#{import_dir}/#{file}") do |x|
        x = CSV.parse(x)
        row_count += 1
        user_import_id = x[0][0]
        if user_import_id.nil? || user_import_id.empty?
          duplicate_import_id_nil_or_empty += 1
        else
          duplicate_import_ids[user_import_id] += 1
        end
      end
      duplicate_import_ids.each do | x, y|
        if y > 1
          duplicate_import_id_report += "#{x}(x#{y}), ".pink
          duplicate_import_id_report_count += 1
        end
      end 
      if duplicate_import_id_report_count > 1
        return_duplicate_import_id_report += "#{duplicate_import_id_report_count} #{duplicate_import_id_report}"
        puts return_duplicate_import_id_report
      else
        puts ""
        puts "No duplicate import_ids found".bold
      end
      puts "#{duplicate_import_id_nil_or_empty} import_ids are nil or empty".pink.bold if duplicate_import_id_nil_or_empty > 0
    end
    return return_duplicate_import_id_report
    # previously, I was writing a rescue clause like this `rescue  CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => er` but didn't want to have to keep adding to an exception list. In my opinion better to just catch all and not have the ability to `CTRL + C` than have the PreCheck for every exception not accounted for.
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method duplicate_import_id_in_users_and_classes_csv: #{er.message}".red
  end
  
  # checks login and password for issues such as spaces, apostrophes, non accepted characters, and length min/max
  def self.users_csv_login_and_password_issue_check(file,import_id)
    user_row_count = CSV.read("#{import_id}/#{file}")
    user_row_num = 1
    space_and_apostrophe_check_nil_empty = 0
    login_contains_space_and_or_apostrophe = 0
    
    login_length_does_not_fall_within_min_max = 0
    password_length_does_not_fall_within_min_max = 0
    password_does_not_start_with_and_or_contain = 0
    login_does_not_start_with_and_or_contain = 0
    
    users_csv_login_column_space_and_apostrophe_check_report = "The following are logins that contain a space or apostrophe: \n"
    
    while user_row_num <= user_row_count.size-1
      if user_row_count[user_row_num][6].nil? || user_row_count[user_row_num][6].empty?
        space_and_apostrophe_check_nil_empty +=1
      elsif user_row_count[user_row_num][6].include?(" ") || user_row_count[user_row_num][6].include?("'")
        login_contains_space_and_or_apostrophe += 1
        users_csv_login_column_space_and_apostrophe_check_report += "\"#{user_row_count[user_row_num][6]}\" at row #{user_row_num}, ".blue
      end 
      
      #login check
      login_user_row_count = user_row_count[user_row_num][6]
      if login_user_row_count.nil? || login_user_row_count.empty?
      elsif (login_user_row_count =~ /^[a-zA-Z0-9_\-.+]*$/) && (login_user_row_count =~ /\A[a-zA-Z0-9]/)
      else
        login_does_not_start_with_and_or_contain +=1
      end
      if login_user_row_count.nil? || login_user_row_count.empty?
      elsif (login_user_row_count.length >=3) && (login_user_row_count.length<=68)
      else
        login_length_does_not_fall_within_min_max +=1
      end
      
      #password check
      password_user_row_count = user_row_count[user_row_num][7]
      if password_user_row_count.nil? || password_user_row_count.empty?
      elsif (password_user_row_count =~ /^[a-zA-Z0-9_\-.+]*$/) && (password_user_row_count =~ /\A[a-zA-Z0-9]/) 
      else
        password_does_not_start_with_and_or_contain +=1
      end
      if password_user_row_count.nil? || password_user_row_count.empty?
      elsif (password_user_row_count.length >=6) && (password_user_row_count.length<=40)
      else
        password_length_does_not_fall_within_min_max +=1
      end
        user_row_num += 1
    end
    puts ""    
    puts "#{login_does_not_start_with_and_or_contain} username(s) do not start with and/or contain letters, numbers, underscores, dots or dashes." if login_does_not_start_with_and_or_contain > 0
    puts "#{password_does_not_start_with_and_or_contain} password(s) do not start with and/or contain letters, numbers, underscores, dots or dashes." if password_does_not_start_with_and_or_contain > 0
    puts "#{login_length_does_not_fall_within_min_max} username(s) are either less than 3 characters or greater than 68 characters in length." if login_length_does_not_fall_within_min_max > 0
    puts "#{password_length_does_not_fall_within_min_max} password(s) are either less than 6 characters or greater than 40 characters in length." if password_length_does_not_fall_within_min_max > 0
    if login_contains_space_and_or_apostrophe > 0
       puts ""
       puts "#{login_contains_space_and_or_apostrophe} logins that contain a space or apostrophe."
       puts users_csv_login_column_space_and_apostrophe_check_report
    else
      puts ""
      puts "No spaces or apostrophes found in login column."
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method users_csv_login_and_password_issue_check: #{er.message}".red    
  end
  
  # compare organization id within users.csv to import_id in the organiations.csv file to see if they all match
  def self.report_users_csv_organization_id_with_import_id_in_organizations_csv(import_dir,partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}users.csv") && File.exists?("#{import_dir}/#{partial_import_switch}organizations.csv")
      users_organization_id_match = 0
      users_organization_id_no_match = 0
      users_organization_id_nil_or_empty = 0
      row_count = 0
      users_organization_id_not_found_report = "The following are organization_id values from #{partial_import_switch}users.csv with no matching row in #{partial_import_switch}organizations.csv: \n".green
      
      unique_import_ids_from_organizations_csv = " import_ids from the #{partial_import_switch}organizations.csv file: ".green
      number_of_import_ids_from_organizations_csv = 0
      
      org_import_ids = {}
      unique_users_organization_id_not_found = {}

      File.foreach("#{import_dir}/#{partial_import_switch}organizations.csv") do |x|
        x = CSV.parse(x)
        
        org_import_ids[x[0][0]] = true
        #changed from += to <<, which is better, does it matter?
        unique_import_ids_from_organizations_csv << "#{x[0][0]}, ".pink
        number_of_import_ids_from_organizations_csv += 1
      end

      File.foreach("#{import_dir}/#{partial_import_switch}users.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        users_org_ids = x[0][10]
        if users_org_ids.nil? || users_org_ids.empty?
          users_organization_id_nil_or_empty += 1
        elsif org_import_ids[users_org_ids] == true
          users_organization_id_match += 1
        else
          users_organization_id_no_match += 1
          unique_users_organization_id_not_found[users_org_ids] = true
        end
      end
      if users_organization_id_no_match > 1
        unique_users_organization_id_not_found.each do | x, y|
          users_organization_id_not_found_report += "#{x.pink}, "
        end
        puts users_organization_id_not_found_report
      end
      puts ""
      puts "#{number_of_import_ids_from_organizations_csv-1}#{unique_import_ids_from_organizations_csv}"
      puts "Information regarding organization_id values from #{partial_import_switch}users.csv compared with row in #{partial_import_switch}organizations.csv".green
      printf("%-21s | %12s | %13s | %14s\n", "expected # of matches", "# of matches", "without match", "# nil or empty")
      printf("%-21s | %12s | %13s | %14s\n".bold.reverse_color,  row_count-1, users_organization_id_match, users_organization_id_no_match-1, users_organization_id_nil_or_empty) 
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method report_users_csv_organization_id_with_import_id_in_organizations_csv: #{er.message}".red
  end
  
  # compare organization id within classes.csv to import_id in the organiations.csv file to see if they all match
  # I realize the code below is very similar to the method report_users_csv_organization_id_with_import_id_in_organizations_csv and maybe while using #{file} I could DRY this method up
  def self.report_classes_csv_organization_id_with_import_id_in_organizations_csv(import_dir,partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}classes.csv") && File.exists?("#{import_dir}/#{partial_import_switch}organizations.csv")
      classes_organization_id_match = 0
      classes_organization_id_no_match = 0
      classes_organization_id_nil_or_empty = 0
      row_count = 0
      classes_organization_id_not_found_report = "The following are organization_id values from #{partial_import_switch}classes.csv with no matching row in #{partial_import_switch}organizations.csv: \n".green
      
      unique_import_ids_from_organizations_csv = " import_ids from the #{partial_import_switch}organizations.csv file: ".green
      number_of_import_ids_from_organizations_csv = 0
      
      org_import_ids = {}
      unique_classes_organization_id_not_found = {}

      File.foreach("#{import_dir}/#{partial_import_switch}organizations.csv") do |x|
        x = CSV.parse(x)
        
        org_import_ids[x[0][0]] = true
        unique_import_ids_from_organizations_csv << "#{x[0][0]}, ".blue
        number_of_import_ids_from_organizations_csv += 1
      end

      File.foreach("#{import_dir}/#{partial_import_switch}classes.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        classes_org_ids = x[0][7]
        if classes_org_ids.nil? || classes_org_ids.empty?
          classes_organization_id_nil_or_empty += 1
        elsif org_import_ids[classes_org_ids] == true
          classes_organization_id_match += 1
        else
          classes_organization_id_no_match += 1
          unique_classes_organization_id_not_found[classes_org_ids] = true
        end
      end
      if classes_organization_id_no_match > 1
        unique_classes_organization_id_not_found.each do | x, y|
          classes_organization_id_not_found_report += "#{x.pink}, "
        end
        puts classes_organization_id_not_found_report
      end
      puts ""
      puts "#{number_of_import_ids_from_organizations_csv-1}#{unique_import_ids_from_organizations_csv}"
      puts "Information regarding organization_id values from #{partial_import_switch}classes.csv compared with row in #{partial_import_switch}organizations.csv".green
      printf("%-21s | %12s | %13s | %14s\n", "expected # of matches", "# of matches", "without match", "# nil or empty")
      printf("%-21s | %12s | %13s | %14s\n".bold.reverse_color,  row_count-1, classes_organization_id_match, classes_organization_id_no_match-1, classes_organization_id_nil_or_empty) 
    end
    rescue => er
      puts ""
      puts "Oops! Something went wrong for method report_classes_csv_organization_id_with_import_id_in_organizations_csv: #{er.message}".red
  end
  
  #Displays 
  def self.user_type_count_by_category_for_users_csv(import_dir, partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}users.csv")
      user_type_teacher = 0
      user_type_student = 0
      user_type_parent = 0
      not_valid_user_type = 0
      row_count = 0
  
      File.foreach("#{import_dir}/#{partial_import_switch}users.csv") do |x|
        x = CSV.parse(x)
        row_count += 1
        user_type_value = x[0][9]
        if user_type_value.nil? || user_type_value.empty?
          user_type_student += 1
        elsif user_type_value.downcase == "t"
          user_type_teacher += 1
        elsif user_type_value.downcase == "s"
          user_type_student += 1
        elsif user_type_value.downcase == "p"
          user_type_parent += 1
        else
          not_valid_user_type += 1
        end
      end
      puts ""
      puts "User type summary from users.csv".green
      printf("%-10s | %13s | %13s | %13s | %11s\n", "# of rows", "# of teachers", "# of students", "# of parents", "# not valid ")
      printf("%-10s | %13s | %13s | %13s | %11s\n".bold.reverse_color, row_count-1, user_type_teacher, user_type_student, user_type_parent, not_valid_user_type-1) 
    end
  end
  
  #Display unique values after @ symbol to catch misspelled email address
  def self.google_id_domain_split_list(import_dir, partial_import_switch)
    if File.exists?("#{import_dir}/#{partial_import_switch}users.csv")
      unique_domain_split = {}
      domain_split_results = "The following are different domains being passed in the google_id column: \n"
      domain_split = CSV.read("#{import_dir}/#{partial_import_switch}users.csv")
      user_row_num = 1
      while user_row_num <= domain_split.size-1
        if domain_split[user_row_num][13].nil? || domain_split[user_row_num][13].empty?
        else
          unique_domain_split[domain_split[user_row_num][13].split('@').last] = true
        end 
          user_row_num += 1
      end
      unique_domain_split.each do |x, y|
        domain_split_results += "#{x.pink}, "
      end
      puts ""
      puts domain_split_results
    end
  end

end



class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

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

  def pink
    colorize(35)
  end
  
  def cyan
    colorize(36)
  end
  
  def white
    colorize(37)
  end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end

