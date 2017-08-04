module CreditableHelpers

  def serialize_credits(credits_list)
    # Combine players by name, combine their roles
    personnel = credits_list.each_with_object([]) do |credit, memo|
      person_data = credit.personnel.serialize({basic: true})
      person_data[:roles] = credits_list.where(personnel_id: credit.personnel.id).pluck(:role)
      memo << person_data
    end
    personnel.uniq {|p| p[:id]}
  end

end
