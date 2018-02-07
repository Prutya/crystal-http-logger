require "http/client"
require "http/server"

PORT_LISTEN      = ENV["PORT"].to_i
TELEGRAM_KEY     = ENV["TELEGRAM_KEY"]
TELEGRAM_CHANNEL = ENV["TELEGRAM_CHANNEL"]

def send_tg_message(text)
  headers = HTTP::Headers.new()
  headers["Content-Type"] = "application/json; charset=utf-8"

  body = <<-JSON
  {
    "chat_id":    "#{TELEGRAM_CHANNEL}",
    "text":       "```\n#{text}\n```",
    "parse_mode": "markdown"
  }
  JSON

  HTTP::Client.post(
    "https://api.telegram.org/bot#{TELEGRAM_KEY}/sendMessage",
    headers,
    body
  )
end

server = HTTP::Server.new(PORT_LISTEN) do |context|
  context.response.content_type = "text/plain"
  context.response.print("Hello world, got #{context.request.path}!")

  time     = "Time: #{Time.utc_now}"
  method   = "Method: #{context.request.method}"
  resource = "Resource: #{context.request.resource}"
  headers  = context.request.headers.map { |k, v| "  #{k}: #{v[0]}" }.join("\n")
  headers  = "Headers:\n#{headers}"
  body     = "Body: "

  unless context.request.body.nil?
    context.request.body.as(IO).each_line do |line|
      body += line
    end

    body = body.gsub("\"", "\\\"")
  end

  send_tg_message([time, method, resource, headers, body].join("\n"))
end

puts "Listening on port #{PORT_LISTEN}"
server.listen
