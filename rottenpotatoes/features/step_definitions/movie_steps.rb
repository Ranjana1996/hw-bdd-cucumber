# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    @movie = Movie.create(title: movie[:title],
                 rating: movie[:rating],
                 release_date: movie[:release_date],
                )
  end
   
end

Then /(.*) seed movies should exist/ do | n_seeds |
  expect(Movie.count).to eq n_seeds.to_i
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  #expect(page.body).to have_content(/#{e1}.*#{e2}/)
  if page.respond_to? :should
    #debugger
    expect(page.body =~/#{e1}.*#{e2}/m).to be >= 0
  else
    # I can find one piece of text matchingh following pattern with characteristrcs that e1 is before e2
    assert page.body =~ /#{e1}.*#{e2}/m
  end

end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

# When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
#   # HINT: use String#split to split up the rating_list, then
#   #   iterate over the ratings and reuse the "When I check..." or
#   #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
#   trigger = uncheck
#   rating_list.split(',').each do |rating|
#     trigger ? uncheck("ratings_#{rating}") : check("ratings_#{rating}")
#   end
  
# end

When /I (un)?check the following ratings: "(.*)"/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  
  ratings_arr = rating_list.split
  ratings_arr.each do |rating|
    if uncheck
      uncheck("ratings_#{rating}")
    else
      check("ratings_#{rating}")
    end
  # fail "Unimplemented"
  end
end

Then /I should see all the movies/ do
  # Make sure that all the movies in the app are visible in the table
  movies = Movie.all
  movies.each do |movie|  # one hash
    if page.respond_to? :should
      page.should have_content(movie[:title])
    else
      assert page.has_content?(movie[:title])
    end
  end
  true
end

Then /I should (not )?see movies of following ratings: "(.*)"/ do |no,rating_list|
  ratings_arr = rating_list.split
  map = ratings_arr.map{ |rating| [rating, 1] }.to_h
  custom_path = "//table[@id='movies']/tbody//td[2]"
  page.all(:xpath, custom_path).each do |element|
    if !no && !map.key?(element.text)
      fail "Not filtered properly"
    elsif no && map.key?(element.text)
      fail "Not filtered properly"
    end
  end
end