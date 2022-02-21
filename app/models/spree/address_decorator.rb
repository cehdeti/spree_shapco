Spree::Address.class_eval do
  def as_shapco
    {
      name: "#{firstname} #{lastname}",
      company: company.presence || 'None',
      street_address: "#{address1}, #{address2}",
      city: city,
      suburb: city,
      postcode: zipcode,
      state: state.abbr,
      country: country.iso,
      telephone: phone.presence || 'None',
      first_name: firstname,
      last_name: lastname,
      corporate_name: company.presence || 'None',
    }
  end
end
