Spree::Address.class_eval do
  def as_shapco
    {
      name: "#{firstname} #{lastname}",
      company: company.presence || 'None',
      street_address1: address1,
      street_address2: address2,
      city: city,
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
