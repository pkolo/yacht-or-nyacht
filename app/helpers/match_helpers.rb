def is_match?(str1, str2)
  fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )
  match = fuzzy.getDistance(str1, str2)
  match >= 0.85
end

def includes_track?(track_list, track_no)
  track_list.split(", ").include?(track_no)
end

def remove_parens(string)
  string.gsub(/\([^)]*\)/, '')
end
