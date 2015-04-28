Templatizing Existing HTML Pages:

- First make a zip/copy of the directory, for easy revert and debugging

- Open one document to be templatized and start to identify the common code that can be isolated (global css files, event specific css files, navigation, footer, etc)

- Cut and paste each section into a new file (as long as it doesn’t exist already) into the “includes” directory wrapping the first and last lines of the new files with:

     &lt;!-- BLACKHATINCLUDE | sourceStart_file-name-without-extension --&gt;

     &lt;!-- BLACKHATINCLUDE | sourceEnd_file-name-without-extension --&gt;

- In the place of each section (that was cut out) add:

     &lt;!-- BLACKHATINCLUDE | inc_file-name-without-extension --&gt;

- Run the inject command on that one file and verify that the include files have been added back in properly by reloading the page. (open dev console and check for unlinked files)

- If everything is added properly, run the strip command on that same file and open it back up in an editor

- Copy html from line 1 through just before the html &lt;title&gt; tag, as the title tag will be preserved in the conversion; save copied html into a new includes file:

     /includes/event-YY-template-header-1.html

- Copy the rest of the html from after the html title tag to the first occurrence of the css class “container” and save:

     /includes/event-YY-template-header-2.html
- Finally copy the html from css class “footer” to the end of the document and save:

     /includes/event-YY-template-footer.html

- Run the retro-fit.sh program on that target directory while referencing the three template files for that event.

- Now you can run html-injector.sh recursively on the entire directory to complete the conversion. (If the content doesn’t show up or is deleted, revert and make sure the first occurrence of the css class “container” comes before the line number saved in this variable: container_location_before in retro-fit.sh)

