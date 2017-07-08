defmodule EAPIOAUTHTest do
  use ExUnit.Case
  doctest EAPIOAUTH

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "string is blank" do
    assert EAPIOAUTH.string_blank("") == true
  end

  test "cow is not blank" do
    assert EAPIOAUTH.string_blank('cow') == false
  end

  test "'cow' is a legit string" do
    assert EAPIOAUTH.legit_string("cow") == true
  end

  test "blank is not a legit string" do
    assert EAPIOAUTH.legit_string("") == false
  end

  test "1 is a number" do
    assert EAPIOAUTH.legit_number(1) == true
  end

  test "27.18 is a number" do
    assert EAPIOAUTH.legit_number(27.18) == true
  end

  # test "cow is not a number" do
  #   assert EAPIOAUTH.legit_number("cow") == false
  # end

  # test "cow is not a datetime" do
  #   assert EAPIOAUTH.legit_datetime("cow") == false
  # end


  # has
  test "has works with maps" do
    assert EAPIOAUTH.has(%{"name"=>"cow", "age"=>38}, "name") == true
  end

  test "has works with maps with missing property and doesn't blow up" do
    assert EAPIOAUTH.has(%{"name"=>"cow", "age"=>38}, "chicken") == false
  end

  test "has works with maps with bad property types" do
    assert EAPIOAUTH.has(%{"name"=>"cow", "age"=>38}, 1) == false
  end

  test "has works with maps with missing maps" do
    assert EAPIOAUTH.has(nil, 1) == false
  end

  def fixture_datetime do
    %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "AMT",hour: 23, minute: 0, second: 7, microsecond: {0, 0},utc_offset: -14400, std_offset: 0, time_zone: "America/Manaus"}
  end

  # legit_datetime
  test "works with datetime" do
    assert EAPIOAUTH.legit_datetime(fixture_datetime()) == true
  end

  test "fails with cow" do
    assert EAPIOAUTH.legit_datetime("cow") == false
  end

  test "fails with map" do
    assert EAPIOAUTH.legit_datetime(%{"chicken"=>"good"}) == false
  end


  # get
  test "get is good" do
    assert EAPIOAUTH.get(%{"name"=>"cow", "age"=>38}, "name") == "cow"
  end

  test "get gives nil for nonexistent keys" do
    assert EAPIOAUTH.get(%{"name"=>"cow", "age"=>38}, "chicken") == nil
  end

  test "get gives default for nonexistent keys" do
    assert EAPIOAUTH.get(%{"name"=>"cow", "age"=>38}, "chicken", 1) == 1
  end

  def fixture_token() do
    %{"access_token"=>"123jlkj1", 
      "issued_at"=>1499306612, 
      "expires_in"=>1296000}
  end

  def fixture_bad_token() do
    %{"access_token"=>1, 
      "issued_at"=>"wat"}
  end

  # legit_access_token
  test "legit access token works" do
    assert EAPIOAUTH.legit_access_token(fixture_token()) == true
  end

  test "bad access token fails" do
    assert EAPIOAUTH.legit_access_token(fixture_bad_token()) == false
  end

  
  # legit_issued_at
  test "legit issued at works" do
    assert EAPIOAUTH.legit_issued_at(fixture_token()) == true
  end

  test "bad issued at fails" do
    assert EAPIOAUTH.legit_issued_at(fixture_bad_token()) == false
  end

  # legit_expires_in
  test "legit expires in works" do
    assert EAPIOAUTH.legit_expires_in(fixture_token()) == true
  end

  test "bad expires in fails" do
    assert EAPIOAUTH.legit_expires_in(fixture_bad_token()) == false
  end


  test "legit http url works" do
    assert EAPIOAUTH.legit_url("http://jessewarden.com") == true
  end

  test "legit https url works" do
    assert EAPIOAUTH.legit_url("https://jessewarden.com") == true
  end

  test "legit url fails with cow" do
    assert EAPIOAUTH.legit_url("cow") == false
  end

  test "legit url fails with 1" do
    assert EAPIOAUTH.legit_url(1) == false
  end

  # validator
  test "validator works" do
    yes = fn o -> true end
    fun = EAPIOAUTH.validator("boom", yes)
    assert fun.("blah") == {:ok, "blah"}
  end


  test "string_validator works with cow" do
    assert EAPIOAUTH.string_validator("cow") == {:ok, "cow"}
  end

  test "string_validator fails with 1" do
    assert EAPIOAUTH.string_validator(1) == {:error, "Not a string or blank."}
  end


  test "url_validator works with url" do
    url = "http://jessewarden.com"
    assert EAPIOAUTH.url_validator(url) == {:ok, url}
  end

  test "url_validator works with https url" do
    url = "https://jessewarden.com"
    assert EAPIOAUTH.url_validator(url) == {:ok, url}
  end

  test "url_validator fails with cow" do
    assert EAPIOAUTH.url_validator("cow") == {:error, "Invalid URL; must be a string, not empty, and contain http or https."}
  end 

  test "url_validator fails with 1" do
    assert EAPIOAUTH.url_validator(1) == {:error, "Invalid URL; must be a string, not empty, and contain http or https."}
  end 


  test "basic enum" do
    assert Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end) == 6
  end

  test "reducer_for_validator works with good string" do
    acc = []
    val = &EAPIOAUTH.string_validator/1
    assert EAPIOAUTH.reducer_for_validator(acc, val, "cow") == []
  end


  test "reducer_for_validator fails with bad string" do
    acc = []
    val = &EAPIOAUTH.string_validator/1
    result = EAPIOAUTH.reducer_for_validator(acc, val, 1)
    assert Enum.member?(result, "Not a string or blank.")
  end

  test "reduce_validators works with good url" do
    validators = [&EAPIOAUTH.string_validator/1, &EAPIOAUTH.url_validator/1]
    url = "https://jessewarden.com"
    assert EAPIOAUTH.reduce_validators(validators, url) == []
  end

  test "reduce_validators fails with bad url" do
    validators = [&EAPIOAUTH.string_validator/1, &EAPIOAUTH.url_validator/1]
    result = EAPIOAUTH.reduce_validators(validators, "cow")
    assert Enum.member?(result, "Invalid URL; must be a string, not empty, and contain http or https.")
  end

  test "reduce_validators fails with number" do
    validators = [&EAPIOAUTH.string_validator/1, &EAPIOAUTH.url_validator/1]
    result = EAPIOAUTH.reduce_validators(validators, 1)
    contains1 = Enum.member?(result, "Invalid URL; must be a string, not empty, and contain http or https.")
    contains2 = Enum.member?(result, "Not a string or blank.")
    assert contains1 == true and contains2 == true
  end

  
  test "checker works with good url" do
    str = &EAPIOAUTH.string_validator/1
    url = &EAPIOAUTH.url_validator/1
    fun = EAPIOAUTH.checker([str, url])
    good_url = "http://jessewarden.com"
    result = fun.(good_url)
    assert result == []
  end

  test "checker fails with bad url" do
    str = &EAPIOAUTH.string_validator/1
    url = &EAPIOAUTH.url_validator/1
    fun = EAPIOAUTH.checker([str, url])
    good_url = "cow"
    result = fun.(good_url)
    assert Enum.member?(result, "Invalid URL; must be a string, not empty, and contain http or https.")
  end

  test "checker fails with number" do
    str = &EAPIOAUTH.string_validator/1
    url = &EAPIOAUTH.url_validator/1
    fun = EAPIOAUTH.checker([str, url])
    good_url = 1
    result = fun.(good_url)
    contains1 = Enum.member?(result, "Invalid URL; must be a string, not empty, and contain http or https.")
    contains2 = Enum.member?(result, "Not a string or blank.")
    assert contains1 == true and contains2 == true  
  end

  # def http_response do
  #   %HTTPotion.Response{body: "...", headers: [Connection: "keep-alive", ...], status_code: 200}
  # end

  # def http_mock do
  #   post = fn stuff -> {}
  #   %{}
  # end

  # test "post works" do
  #   response = EAPIOAUTH.post()
  # end

  test "post integration works" do
    response = HTTPotion.get "https://5vgcr03zw4.execute-api.us-east-1.amazonaws.com/prod/pets"
    IO.puts response
    assert HTTPotion.Response.success?(response) == true
  end

end
