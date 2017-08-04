module CreditableHelpers

  def serialize_credits(credits_list)
    # Combine players by name, combine their roles
    personnel = credits_list.uniq { |p| p[:personnel].id }.each_with_object([]) do |credit, memo|
      person_data = credit.personnel.serializer({basic: true})
      person_data[:roles] = credits_list.where(personnel_id: credit.personnel.id).pluck(:role)
      memo << person_data
    end
  end

end
