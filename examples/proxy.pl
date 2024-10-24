#
# A simple HTTP proxy server for debugging
#
#   $ HTTP_PROXY=http://127.0.0.1:3000 mojo get http://mojolicious.org
#
use Mojolicious::Lite -signatures;

any '/*whatever' => {whatever => ''} => sub ($c) {
  my $req     = $c->req;
  my $method  = $req->method;
  my $url     = $req->url->to_abs;
  my $headers = $req->headers->clone->dehop->to_hash;
  $c->app->log->debug(qq{Forwarding "$method $url"});

  $c->proxy->start_p($c->ua->build_tx($method, $url, $headers))->catch(sub ($err) {
    $c->render(data => $err, status => 400);
  });
};

app->start;
