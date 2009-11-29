--[[
rewrite.lua
-------------------------------------------------------------------------------
Rewrite rules for a Wordpress 2.x installation on top of a lighttpd web server.

This LUA script comes in very handy if your using the following plugins in
your Wordpress installation:
  * wp-super-cache (http://ocaoimh.ie/wp-super-cache/)
  * WP-touch (http://bravenewcode.com/wptouch)

This LUA script is based on the great work of Giovanni Intini:
http://tempe.st/2008/05/lightning-speed-wordpress-with-lighttpd-and-supercache-part-ii/

-------------------------------------------------------------------------------
Copyright 2008,2009 by Giovanni Intini, Jean Pierre Wenzel <jpwenzel@gmx.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
--]]

-- ----------------------------------------------------------------------------
-- CONFIGURATION
enableUserAgentCheck = true
-- ----------------------------------------------------------------------------

function serve_html(cached_page)
  if (lighty.stat(cached_page)) then
    lighty.env["physical.path"] = cached_page
    return true
  else
    return false
  end
end
 
function serve_gzip(cached_page)
  if (lighty.stat(cached_page .. ".gz")) then
    lighty.header["Content-Encoding"] = "gzip"
    lighty.header["Content-Type"] = ""
    lighty.env["physical.path"] = cached_page .. ".gz"
    return true
  else
    return false
  end
end

attr = lighty.stat(lighty.env["physical.path"])
 
if (not attr) then
  lighty.env["uri.path"] = "/index.php"
  lighty.env["physical.rel-path"] = lighty.env["uri.path"]
  lighty.env["physical.path"] = lighty.env["physical.doc-root"] .. lighty.env["physical.rel-path"]
  
  -- Sending a HTTP query? => no caching
  query_condition = not (lighty.env["uri.query"] and string.find(lighty.env["uri.query"], ".*s=.*"))
  
  -- Have a cookie? => no caching
  user_cookie = lighty.request["Cookie"] or ""
  cookie_condition = not (string.find(user_cookie, ".*comment_author.*") or string.find(user_cookie, ".*wordpress.*") or string.find(user_cookie, ".*wp-postpass_.*"))
  
  if (not enableUserAgentCheck) then
    sendCachedFile = true
  else
    -- Check if request comes from a mobile device or bot => no caching than, either.
    local userAgentsNoCaching = { "bot", "ia_archive", "slurp", "crawl", "spider", "linkbot", "iphone", "ipod", "android", "cupcake", "webos", "incognito", "webmate", "opera mini", "blackberry", "symbian", "series60", "nokia", "samsung" }
    userAgent = lighty.request["User-Agent"]
    if (nil == userAgent) then
      sendCachedFile = true
    else
      userAgent = string.lower(userAgent)
      for i, v in ipairs(userAgentsNoCaching) do
        if string.find(v, userAgent) then
          sendCachedFile = false
  	      break
        end  
      end
    end
  end
  
  if (query_condition and cookie_condition and sendCachedFile) then
    accept_encoding = lighty.request["Accept-Encoding"] or "no_acceptance"
    cached_page = lighty.env["physical.doc-root"] .. "/wp-content/cache/supercache/" .. lighty.request["Host"] .. lighty.env["request.uri"] .. "/index.html"
    cached_page = string.gsub(cached_page, "//", "/")
    if (string.find(accept_encoding, "gzip")) then
      if not serve_gzip(cached_page) then serve_html(cached_page) end
    else
      serve_html(cached_page)
    end
  end
end
