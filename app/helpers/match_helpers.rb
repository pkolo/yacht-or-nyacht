def is_match?(str1, str2, strength=0.85)
  fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )
  match = fuzzy.getDistance(str1, str2)
  match >= strength
end

def remove_parens(string)
  string.gsub(/\([^)]*\)/, '')
end

def sluggify(string, id)
  remove_parens("#{string} #{id}").downcase.gsub(/[^0-9a-z ]/i, '').split(' ').join('-')
end
