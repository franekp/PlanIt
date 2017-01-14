# development configuration:
# - dispatches requests between django and nginx for dynamic and static content
#   respectively;
# - does not cache anything so that code autoreload can work
vcl 4.0;

import std;
import directors;

backend web {
  .host = "web";
  .port = "80";
}
backend nginx {
  .host = "nginx";
  .port = "80";
}

acl purge_ip {
    "web"; "worker";
}

sub vcl_init{
    new web_director = directors.random();
    web_director.add_backend(web, 1.0);
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
  if (req.url ~ "^/static") {
    set req.backend_hint = nginx_director.backend();
    return(pipe);
  } else {
    set req.backend_hint = web_director.backend();
    return(pipe);
  }
}

sub vcl_hash {
  # not used in dev setup - nothing is cached
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
