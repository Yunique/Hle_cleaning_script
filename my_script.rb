require 'mysql2'

def delete_period(candidate_name)
  if candidate_name.count('.') > 0 && candidate_name != 'School Board Member/District 143.5'
    candidate_name = candidate_name.delete('.')
  end
  candidate_name
end

def capitalize_this(str)
  str.gsub(/(^| )(\w)/) { $1 + $2.capitalize }
end

def replace_comma_in(candidate_name)
  if candidate_name.count(',') == 1
    candidate_name = candidate_name.split(', ')
    if candidate_name[1]
      candidate_name = candidate_name[0] + ' (' + capitalize_this(candidate_name[1]) + ')'
    else
      candidate_name = candidate_name[0].delete(',')
    end
  end
  candidate_name
end

def explain_abbreviation(candidate_name)
  candidate_name.gsub(/Twp|twp|Hwy|hwy/, 'Twp' => 'Township',
                                         'twp' => 'township',
                                         'Hwy' => 'Highway',
                                         'hwy' => 'highway')
end

def remove_duplicates_of(candidate_name)
  candidate_name.gsub(/\b(\w+) \1/i, '\1')
end

def format_this(candidate_name)
  arr = explain_abbreviation(delete_period(candidate_name)).split('/')
  result = case arr.length
           when 1
             arr[0].downcase
           when 2
             "#{capitalize_this(arr[1])} #{arr[0].downcase}"
           when 3
             "#{capitalize_this(arr[2])} #{arr[0].downcase} and #{arr[1].downcase}"
           else
             ''
           end
  replace_comma_in(remove_duplicates_of(result))
end

client = Mysql2::Client.new(host: '',
                            username: '',
                            password: '',
                            database: '')

uncleaned_candidates_names = client.query('SELECT * FROM hle_dev_test_yunus_ganiyev')
uncleaned_candidates_names.each do |name|
  candidate_name = name['candidate_office_name']

  clean_name = format_this(candidate_name)
  sentence = if clean_name.empty?
               clean_name
             else
               "The candidate is running for the #{clean_name} office."
             end
  client.query("UPDATE hle_dev_test_yunus_ganiyev
                    SET clean_name = \"#{clean_name}\", sentence = \"#{sentence}\"
                    WHERE id = \"#{name['id']}\";")
end
