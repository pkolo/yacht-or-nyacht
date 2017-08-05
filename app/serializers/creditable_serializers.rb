module CreditableSerializers

  def serialize_credits(credits_list)
    # Combine players by name, combine their roles
    personnel = credits_list.each_with_object([]) do |credit, memo|
      person_data = credit.personnel.serialize({basic: true})
      person_data[:roles] = credits_list.where(personnel_id: credit.personnel.id).pluck(:role)
      memo << person_data
    end
    personnel.uniq {|p| p[:id]}
  end

  def serialize_credits_from_sql(credits_list)
    credits_list.each_with_object([]) do |credit, memo|
      memo << {
        id: credit["id"].to_i,
        name: credit["name"],
        resource_url: "/personnel/#{credit["slug"]}",
        yachtski: credit["yachtski"].to_f,
        roles: credit["roles"].split(", ")
      }
    end
  end

end
