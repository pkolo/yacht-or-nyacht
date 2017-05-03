def is_match?(str1, str2)
  fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )
  match = fuzzy.getDistance(str1, str2)
  match >= 0.85
end
