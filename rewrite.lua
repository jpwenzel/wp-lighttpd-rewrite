--[[
rewrite.lua
-------------------------------------------------------------------------------
Rewrite rules for a Wordpress 3.x installation on top of a lighttpd web server.

This LUA script comes in very handy if your using the following plugins in
your Wordpress installation:
  * wp-super-cache (http://ocaoimh.ie/wp-super-cache/)
  * WP-touch (http://bravenewcode.com/wptouch)

This LUA script is based on the great work of Giovanni Intini:
http://tempe.st/2008/05/lightning-speed-wordpress-with-lighttpd-and-supercache-part-ii/

-------------------------------------------------------------------------------
Copyright 2008,2009 by Giovanni Intini, Jean Pierre Wenzel <jpwenzel@gmx.net>
Copyright 2011 by Eric Chamberlain

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

-- Taken from the WPSuperCache mod_rewrite rules
-- RewriteCond %{HTTP_USER_AGENT} !^.*(2.0\ MMP|240x320|400X240|AvantGo|BlackBerry|Blazer|Cellphone|Danger|DoCoMo|Elaine/3.0|EudoraWeb|Googlebot-Mobile|hiptop|IEMobile|KYOCERA/WX310K|LG/U990|MIDP-2.|MMEF20|MOT-V|NetFront|Newt|Nintendo\ Wii|Nitro|Nokia|Opera\ Mini|Palm|PlayStation\ Portable|portalmmm|Proxinet|ProxiNet|SHARP-TQ-GX10|SHG-i900|Small|SonyEricsson|Symbian\ OS|SymbianOS|TS21i-10|UP.Browser|UP.Link|webOS|Windows\ CE|WinWAP|YahooSeeker/M1A1-R2D2|iPhone|iPod|Android|BlackBerry9530|LG-TU915\ Obigo|LGE\ VX|webOS|Nokia5800).* [NC]
local userAgentsNoCaching = { 
                              "2.0 MMP",
                              "240x320",
                              "400X240",
                              "AvantGo",
                              "BlackBerry",
                              "Blazer",
                              "Cellphone",
                              "Danger",
                              "DoCoMo",
                              "Elaine/3.0",
                              "EudoraWeb",
                              "Googlebot-Mobile",
                              "hiptop",
                              "IEMobile",
                              "KYOCERA/WX310K",
                              "LG/U990",
                              "MIDP-2.",
                              "MMEF20",
                              "MOT-V",
                              "NetFront",
                              "Newt",
                              "Nintendo Wii",
                              "Nitro",
                              "Nokia",
                              "Opera Mini",
                              "Palm",
                              "PlayStation Portable",
                              "portalmmm",
                              "Proxinet",
                              "ProxiNet",
                              "SHARP-TQ-GX10",
                              "SHG-i900",
                              "Small",
                              "SonyEricsson",
                              "Symbian OS",
                              "SymbianOS",
                              "TS21i-10",
                              "UP.Browser",
                              "UP.Link",
                              "webOS",
                              "Windows CE",
                              "WinWAP",
                              "YahooSeeker/M1A1-R2D2",
                              "iPhone",
                              "iPod",
                              "Android",
                              "BlackBerry9530",
                              "LG-TU915 Obigo",
                              "LGE VX",
                              "Nokia5800"
                            }

-- RewriteCond %{HTTP_user_agent} !^(w3c\ |w3c-|acs-|alav|alca|amoi|audi|avan|benq|bird|blac|blaz|brew|cell|cldc|cmd-|dang|doco|eric|hipt|htc_|inno|ipaq|ipod|jigs|kddi|keji|leno|lg-c|lg-d|lg-g|lge-|lg/u|maui|maxo|midp|mits|mmef|mobi|mot-|moto|mwbp|nec-|newt|noki|palm|pana|pant|phil|play|port|prox|qwap|sage|sams|sany|sch-|sec-|send|seri|sgh-|shar|sie-|siem|smal|smar|sony|sph-|symb|t-mo|teli|tim-|tosh|tsm-|upg1|upsi|vk-v|voda|wap-|wapa|wapi|wapp|wapr|webc|winw|winw|xda\ |xda-).* [NC]
local userAgentsStartWithNoCaching =  {
                                        "w3c ",
                                        "w3c-",
                                        "acs-",
                                        "alav",
                                        "alca",
                                        "amoi",
                                        "audi",
                                        "avan",
                                        "benq",
                                        "bird",
                                        "blac",
                                        "blaz",
                                        "brew",
                                        "cell",
                                        "cldc",
                                        "cmd-",
                                        "dang",
                                        "doco",
                                        "eric",
                                        "hipt",
                                        "htc_",
                                        "inno",
                                        "ipaq",
                                        "ipod",
                                        "jigs",
                                        "kddi",
                                        "keji",
                                        "leno",
                                        "lg-c",
                                        "lg-d",
                                        "lg-g",
                                        "lge-",
                                        "lg/u",
                                        "maui",
                                        "maxo",
                                        "midp",
                                        "mits",
                                        "mmef",
                                        "mobi",
                                        "mot-",
                                        "moto",
                                        "mwbp",
                                        "nec-",
                                        "newt",
                                        "noki",
                                        "palm",
                                        "pana",
                                        "pant",
                                        "phil",
                                        "play",
                                        "port",
                                        "prox",
                                        "qwap",
                                        "sage",
                                        "sams",
                                        "sany",
                                        "sch-",
                                        "sec-",
                                        "send",
                                        "seri",
                                        "sgh-",
                                        "shar",
                                        "sie-",
                                        "siem",
                                        "smal",
                                        "smar",
                                        "sony",
                                        "sph-",
                                        "symb",
                                        "t-mo",
                                        "teli",
                                        "tim-",
                                        "tosh",
                                        "tsm-",
                                        "upg1",
                                        "upsi",
                                        "vk-v",
                                        "voda",
                                        "wap-",
                                        "wapa",
                                        "wapi",
                                        "wapp",
                                        "wapr",
                                        "webc",
                                        "winw",
                                        "winw",
                                        "xda ",
                                        "xda-"
                                      }
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

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start)) == Start
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
  cookie_condition =  not (string.find(user_cookie, ".*comment_author.*") or 
                      string.find(user_cookie, ".*wordpress.*") or 
                      string.find(user_cookie, ".*wp-postpass_.*"))
  
  sendCachedFile = true
  
  if (enableUserAgentCheck) then
    -- Check if request comes from a mobile device or bot => no caching then, either.

    userAgent = lighty.request["User-Agent"]
    if (no nil == userAgent) then
      userAgent = string.lower(userAgent)
        
      for i, v in ipairs(userAgentsNoCaching) do
        if (string.find(v, userAgent)) then
          sendCachedFile = false
  	      break
        end  
      end
      
      if (sendCachedFile) then
        for i, v in ipairs(userAgentsStartWithNoCaching) do
          if (string.starts(v, userAgent)) then
            sendCachedFile = false
            break
          end  
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
