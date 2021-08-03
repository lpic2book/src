##  Implementing Nginx as a web server and a reverse proxy (208.4)

Candidates should be able to install and configure a reverse proxy
server, Nginx. Basic configuration of Nginx as a HTTP server is
included.

###   Key Knowledge Areas

- Nginx

- Reverse Proxy

- Basic Web Server

##  Terms and Utilities

-   `/etc/nginx/`

-   `nginx`

##  NGINX

nginx Nginx can be used as a webserver, an HTTP reverse proxy or as an
IMAP/POP3 proxy. It is pronounced as `engine-x`. Nginx is performing so
well that large sites as Netflix, Wordpress and GitHub rely on Nginx. It
doesn't work using threads as most of the other webserver software does
but it's using an event driven (asynchronous) architecture. It has a
small footprint and performs very well under load with predictable usage
of resources. This predictable performance and small memory footprint
makes Nginx interesting in both small and large environments. Nginx is
distributed as Open Source software. There is also 'Nginx Plus', which
is the commercial edition. This book will focus on the Open Source
edition.

###   Reverse Proxy

A proxy server is a go-between or intermediary server that forwards
requests for content from multiple clients to different servers across
the Internet. A reverse proxy server is a type of proxy server that
typically sits behind the firewall in a private network and directs
client requests to the appropriate back-end server. A reverse proxy
provides an additional level of abstraction and control to ensure the
smooth flow of network traffic between clients and servers.

Common uses for a reverse proxy server include:

-   Load balancing -- A reverse proxy server can act as a "traffic cop,"
    sitting in front of your back-end servers and distributing client
    requests across a group of servers in a manner that maximizes speed
    and capacity utilization while ensuring no server is overloaded,
    which can degrade performance. If a server goes down, the load
    balancer redirects traffic to the remaining online servers.

-   Web acceleration -- Reverse proxies can compress inbound and
    outbound data, as well as cache commonly requested content, both of
    which speed up the flow of traffic between clients and servers. They
    can also perform additional tasks such as SSL encryption to take
    load off of your web servers, thereby boosting their performance.

-   Security and anonymity -- By intercepting requests headed for your
    back-end servers, a reverse proxy server protects their identities
    and acts as an additional defense against security attacks. It also
    ensures that multiple servers can be accessed from a single record
    locater or URL regardless of the structure of your local area
    network.

Using Nginx as reverse HTTP proxy is not hard to configure. A very basic
reverse proxy setup might look like this:

    location / {
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Host      $host;
          proxy_pass       http://localhost:8000;
    }
                    

In this example all requests received by Nginx, depending on the
configuration of the server parameters in `/etc/nginx/nginx.conf`, are
forwarded to an HTTP server running on localhost and listening on port
8000. The Nginx configuration file looks like this:

    server {
        listen   80; 

        root /var/www/; 
        index index.php index.html index.htm;

        server_name example.com www.example.com; 

        location / {
            try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {    
            proxy_set_header X-Real-IP  $remote_addr;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header Host $host;
            proxy_pass http://localhost:8080;
        }

        location ~ /\.ht {
            deny all;
        }
    }
                    

The line starting with `location  ~ /\.ht` is added to prevent Nginx of
displaying the content of Apache's .htaccess files. The *try\_files*
line is used to attempt to serve whatever page the visitor requests. If
nginx is unable, then the file is passed to the proxy.

###   Basic Web Server

The default location for the configuration file in Nginx is
`/etc/nginx/nginx.conf`.

A basic Nginx configuration, able to serve html files, looks like this:

    server {
        # This will listen on all interfaces, you can instead choose a specific IP
        # such as listen x.x.x.x:80;  
        listen 80;

        # Here you can set a server name, you can use wildcards such as *.example.com
        # however remember if you use server_name *.example.com; You'll only match subdomains
        # to match both subdomains and the main domain use both example.com and *.example.com
        server_name example.com www.example.com;

        # It is best to place the root of the server block at the server level, and not the location level
        # any location block path will be relative to this root. 
        root /usr/local/www/example.com;

        # Access and error logging. NB: Error logging cannot be turned off. 
        access_log /var/log/nginx/example.access.log;
        error_log /var/log/nginx/example.error.log;

        location / { 
            # Rewrite rules and other criterias can go here
            # Remember to avoid using if() where possible (http://wiki.nginx.org/IfIsEvil)
        }
    }
                    

For PHP support Nginx relies on a PHP fast-cgi spawner. Preferable is
`php-fpm` which can be found at
[http://php-fpm.org](http://php-fpm.org/). It has some unique features
like adaptive process spawning and statistics and has the ability to
start workers with different uid/gid/chroot/environment and different
php.ini. The safe\_mode can be replaced using this feature.

You can add the content below to `nginx.conf`. A better practice is to
put the contents in a file and include this file into the main
configuration file of Nginx. Create a file, for example `php.conf` and
include the next line at the end of the Nginx main configuration file:

    include php.conf;
                    

The content of `php.conf` :

    location ~ \.php {
        # for security reasons the next line is highly encouraged
        try_files $uri =404;

        fastcgi_param  QUERY_STRING       $query_string;
        fastcgi_param  REQUEST_METHOD     $request_method;
        fastcgi_param  CONTENT_TYPE       $content_type;
        fastcgi_param  CONTENT_LENGTH     $content_length;

        fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;

        # if the next line in yours still contains $document_root
        # consider switching to $request_filename provides
        # better support for directives such as alias
        fastcgi_param  SCRIPT_FILENAME    $request_filename;

        fastcgi_param  REQUEST_URI        $request_uri;
        fastcgi_param  DOCUMENT_URI       $document_uri;
        fastcgi_param  DOCUMENT_ROOT      $document_root;
        fastcgi_param  SERVER_PROTOCOL    $server_protocol;

        fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
        fastcgi_param  SERVER_SOFTWARE    nginx;

        fastcgi_param  REMOTE_ADDR        $remote_addr;
        fastcgi_param  REMOTE_PORT        $remote_port;
        fastcgi_param  SERVER_ADDR        $server_addr;
        fastcgi_param  SERVER_PORT        $server_port;
        fastcgi_param  SERVER_NAME        $server_name;

        # If using a unix socket...
        # fastcgi_pass unix:/tmp/php5-fpm.sock;

        # If using a TCP connection...
        fastcgi_pass 127.0.0.1:9000;
    }       
                    
