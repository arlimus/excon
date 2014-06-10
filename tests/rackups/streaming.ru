use Rack::ContentType, "text/plain"

app = lambda do |env|
  # streamed pieces to be sent
  pieces = %w{Hello streamy world}

  stream_response = lambda do |io|
    # Write directly to IO of the response
    begin
      # return the response in pieces
      pieces.each do |x|
        sleep 1
        io.write(x)
        io.flush
      end
    ensure
      io.close
    end
  end

  chunk_response = lambda do |io|
    # Write directly to IO of the response
    begin
      # return the response in pieces, via chunked encoding
      pieces.each do |x|
        sleep 1
        io.write( x.length + "\r\n" + x + "\r\n" )
        io.flush
      end
    ensure
      io.close
    end
  end

  response_headers = {}

  # set a fixed content length in the header if requested
  if env['REQUEST_PATH'] == '/streamed/fixed_length'
    response_headers['Content-Length'] = pieces.join.length.to_s
  end

  # do chunked encoding, with delays, piece by piece
  if env['REQUEST_PATH'] == '/streamed/chunked'
    response_headers['Transfer-Encoding'] = 'chunked'
    chunk_response
  else
    stream_response
  end

  [200, response_headers, nil]
end

run app
