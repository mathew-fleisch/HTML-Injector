# Black Hat Includes System
This system is designed to simulate php-style includes with html comments and a shell script to strip old and inject new content. The script is run manually or only when content is updated so that the front-end can remain html only. 

## Installation:

- First replace "/path-to-webroot" with your local clone of the black hat site in this document.


- Set up permissions for local html files:
```
     sudo chgrp -R _www /path-to-webroot/www.blackhat.com; sudo chmod -R g+w /path-to-webroot/www.blackhat.com
```

- Set up container for scripts to run:
     - If your html files are here: "/path-to-webroot/www.blackhat.com"
     - Then you should make a "scripts" folder here: "/path-to-webroot/scripts"

- Clone the html-injector tool:
```
     cd /path-to-webroot/scripts;
     git clone https://github.com/mathew-fleisch/HTML-Injector.git .;
```

- Create Excludes List (important, or will strip template source files):
```
     touch /path-to-webroot/scripts/HTML-Injector/excludes_list.txt
```
          - Add path to includes folder:  /path-to-webroot/www.blackhat.com/includes
     - Link exclude_path up in config.sh:
          - s/Library\/WebServer\/Documents\/blackhat\.com\/scripts\/HTML-Injector/path-to-webroot/g

- Set up /etc/hosts file:
```
     # Custom domains:
     127.0.0.1  localhost
     127.0.0.1  blackhat.local
     127.0.0.1  htmlinjector.local
```

- Set up Vhosts and enable CGI for front-end script:
     - /etc/apache2/extra/httpd-vhosts.conf
```
          <VirtualHost *:80>
                  DocumentRoot "/path-to-webroot/www.blackhat.com"
                  ServerName blackhat.local
          </VirtualHost>
          <VirtualHost *:80>
                  DocumentRoot "/path-to-webroot/scripts/HTML-Injector"
                  ServerName htmlinjector.local
                  Options Indexes FollowSymLinks ExecCGI
                  AddHandler cgi-script .cgi .pl
          </VirtualHost>
```
     - /etc/apache2/httpd.conf
```
          LoadModule cgi_module libexec/apache2/mod_cgi.so
````

- Restart Apache:
```
     sudo httpd -k restart
```

## Templatizing Existing HTML Pages:

- First make a zip/copy of the directory, for easy revert and debugging

- Open one document to be templatized and start to identify the common code that can be isolated (global css files, event specific css files, navigation, footer, etc)

- Cut and paste each section into a new file (as long as it doesn't exist already) into the "includes" directory wrapping the first and last lines of the new files with:

```
     <!-- BLACKHATINCLUDE | sourceStart_file-name-without-extension -->
```

```
     <!-- BLACKHATINCLUDE | sourceEnd_file-name-without-extension -->
```

- In the place of each section (that was cut out) add:

```
     <!-- BLACKHATINCLUDE | inc_file-name-without-extension -->
```

- Run the inject command on that one file and verify that the include files have been added back in properly by reloading the page. (open dev console and check for unlinked files) 


```
     ./html-injector.sh -v true -f ../www.blackhat.com/us-15/index.html -i true
```

- If everything is added properly, run the strip command on that same file and open it back up in an editor 

```
     ./html-injector.sh -v true -f ../www.blackhat.com/us-15/index.html -r true -s true
```


- Copy html from line 1 through just before the html &lt;title&gt; tag, as the title tag will be preserved in the conversion; save copied html into a new includes file:

```
     /includes/event-YY-template-header-1.html
```

- Copy the rest of the html from after the html title tag to the first occurrence of the css class "container" and save:

```
     /includes/event-YY-template-header-2.html
```

- Finally copy the html from css class "footer" to the end of the document and save:

```
     /includes/event-YY-template-footer.html
```

- Run the retro-fit.sh program on that target directory while referencing the three template files for that event. 

```
     ./retro-fit.sh -v true -r true -d ../../www.blackhat.com/us-15 -e ../../www.blackhat.com/includes/us-15-template-header-1.html -o ../../www.blackhat.com/includes/us-15-template-header-2.html -t ../../www.blackhat.com/includes/us-15-template-footer.html
```
     
- Now you can run html-injector.sh recursively on the entire directory to complete the conversion. (If the content doesn't show up or is deleted, revert and make sure the first occurrence of the css class "container" comes before the line number saved in this variable: container_location_before in retro-fit.sh) 

```
     ./html-injector.sh -v true -r true -d ../www.blackhat.com/us-15/index.html -i true
```



## Making changes to template files:
- Open template file and save change. Make sure to leave (or add if missing) the start/end flags

- Run the strip command to pull out old template 

```
     ./html-injector.sh -v true -r true -d ../www.blackhat.com/us-15/index.html -s true
```

- Run the inject command to add new change 

```
     ./html-injector.sh -v true -r true -d ../www.blackhat.com/us-15/index.html -i true
```
