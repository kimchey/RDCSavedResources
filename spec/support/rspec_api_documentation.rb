module RspecApiDocumentation
  class ClientBase

    alias_method :old_headers, :headers

    def headers(method, path, params)
      old_headers(method, path, params).merge("HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => 'application/json')
    end

  end
end

module RspecApiDocumentation
  class RackTestClient

    alias_method :old_request_headers, :request_headers

    def request_headers
      old_request_headers.except("Cookie", "Host")
    end
  end
end