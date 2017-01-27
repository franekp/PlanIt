# development configuration:
# - dispatches requests between django and nginx for dynamic and static content
#   respectively;
# - does not cache anything so that code autoreload can work
vcl 4.0;

import std;
import directors;

backend web1 {
  .host = "web1";
  .port = "80";
}
backend web2 {
  .host = "web2";
  .port = "80";
}
backend web3 {
  .host = "web3";
  .port = "80";
}
backend nginx {
  .host = "nginx";
  .port = "80";
}

acl purge_ip {
    "web1"; "web2"; "web3";
}

sub vcl_init{
    new web_director = directors.random();
    web_director.add_backend(web1, 1.0);
    web_director.add_backend(web2, 1.0);
    web_director.add_backend(web3, 1.0);
    new nginx_director = directors.random();
    nginx_director.add_backend(nginx, 1.0);
}

sub vcl_recv {
  if (req.method == "PURGE") {
   if (!client.ip ~ purge_ip) {
     return(synth(403, "Not allowed"));
   }
   return (purge);
  }
  if (req.url ~ "^/app") {
    set req.backend_hint = nginx_director.backend();
    return(hash);
  } else {
    set req.backend_hint = web_director.backend();
    if (req.method != "GET" && req.method != "HEAD") {
      return (pass);
    } else {
      return(hash);
    }
  }
}

sub vcl_hash {
  # hash url and cookie so that per-user data is also cached
  hash_data(req.url);
  if (req.http.Cookie) {
    hash_data(req.http.Cookie);
  }
}

sub vcl_backend_response {
  # Happens after we have read the response headers from the backend.
  #
  # Here you clean the response headers, removing silly Set-Cookie headers
  # and other mistakes your backend does.
  return (deliver);
}

sub vcl_deliver {
  # Happens when we have all the pieces we need, and are about to send the
  # response to the client.
  #
  # You can do accounting or modifying the final object here.
}

sub vcl_synth {
  set resp.http.Content-Type = "text/html; charset=utf-8";
  set resp.http.Retry-After = "5";
  synthetic ("Error");
  return (deliver);
}
