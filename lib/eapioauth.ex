defmodule EAPIOAUTH do
	@moduledoc """
	Documentation for EAPIOAUTH.
	"""

	@doc """
	Hello world.

	## Examples

			iex> EAPIOAUTH.hello
			:world

	"""
	def hello do
		:world
	end

	def string_blank(o) do
		o == ""
	end

	def legit_string(o) do
		String.valid?(o) and string_blank(o) == false
	end

	def legit_number(o) do
		is_number(o)
	end

	def legit_datetime(o) do
		try do
			day = o.day
			hour = o.hour
			microsecond = o.microsecond
			legit_number(day) and legit_number(hour) and is_tuple(microsecond)
		rescue
			_ -> false
		end
	end

	def has(map, key) do
		try do
			map[key] != nil
		rescue
			e in RuntimeError -> false
		end
	end

	def get(map, key, default \\ nil) do
		try do
			case map[key] do
				nil -> default
				_ -> map[key]
			end
		rescue
			_ -> default
		end
	end

	def legit_access_token(o) do
		has(o, "access_token") and legit_string(get(o, "access_token"))
	end

	def legit_issued_at(o) do
		has(o, "issued_at") and legit_number(get(o, "issued_at"))
	end

	def legit_expires_in(o) do
		has(o, "expires_in") and legit_number(get(o, "expires_in"))
	end

	def legit_client_id(o) do
		legit_string(o)
	end

	def legit_client_secret(o) do
		legit_string(o)
	end

	def contains_http(o) do
		legit_string(o) and String.contains?(o, "http://")
	end

	def contains_https(o) do
		legit_string(o) and String.contains?(o, "https://")
	end

	def contains_http_or_https(o) do
		contains_http(o) or contains_https(o)
	end

	def legit_url(o) do
		legit_string(o) and String.length(o) > 0 and contains_http_or_https(o)
	end

	def predicate_with_error(error_string, predicate, o) do
		result = predicate.(o)
		case result do
			true -> {:ok, o}
			_ -> {:error, error_string}
		end
	end

	def validator(error_string, predicate) do
		maker = &predicate_with_error/3
		fn o -> maker.(error_string, predicate, o) end
	end

# 	const checker = (...validators) => o =>
#   _.reduce(validators, (acc, validator) => 
#   {
#     return acc.concat(validator(o));
#   }, Success(o));

	# Enum.reduce([1, 2, 3], 0, fn(x, acc) -> x + acc end)

	def reducer_for_validator(accumlator, validator, value) do
		result = validator.(value)
		if result == {:ok, value} do
			accumlator
		else
			updated_result = accumlator ++ [elem(result, 1)]
			updated_result
		end
	end

	def reduce_validators(validators, o) do
		reducer = fn(val, acc) -> reducer_for_validator(acc, val, o) end
		Enum.reduce(validators, [], reducer)
	end

	def checker(validators) do
		maker = &reduce_validators/2
		fn o -> maker.(validators, o) end
	end

	def string_validator(o) do
		validator("Not a string or blank.", &legit_string/1).(o)
	end

	def url_validator(o) do
		validator("Invalid URL; must be a string, not empty, and contain http or https.", &legit_url/1).(o)
	end

	def post(http, url, body) do
		http.post url, [
			body: body,
  			headers: [
				  "Content-Type": "application/json"
				]
			]
	end

	# def url_validator(o) do
	# 	if legit_string
	# end

end
