// -----------------------------------------------------------------------------------
//
//	Indicator
//	2008/04/03
//
    YAHOO.namespace("example.container");

    function init(p_uri) {

        var content = document.getElementById("content");
        
        content.innerHTML = "";

        if (!YAHOO.example.container.wait) {

            // Initialize the temporary Panel to display while waiting for external content to load

            YAHOO.example.container.wait = 
                    new YAHOO.widget.Panel("wait",  
                                                    { width: "180px", 
                                                      fixedcenter: true, 
                                                      close: false, 
                                                      draggable: false, 
                                                      modal: true,
						      zindex:4,
                                                      visible: false
                                                    } 
                                                );
    
            YAHOO.example.container.wait.setHeader("Loading, ÉfÅ[É^éÊìæíÜ...");
            YAHOO.example.container.wait.setBody("<img src=\"http://ompadmin.jokerz.org/images/indicator.gif\" />");
            YAHOO.example.container.wait.render(document.body);

        }

        // Define the callback object for Connection Manager that will set the body of our content area when the content has loaded



        var callback = {
            success : function(o) {
                content.innerHTML = o.responseText;
                content.style.visibility = "visible";
                YAHOO.example.container.wait.hide();
            },
            failure : function(o) {
                content.innerHTML = o.responseText;
                content.style.visibility = "visible";
                content.innerHTML = "CONNECTION FAILED!";
                YAHOO.example.container.wait.hide();
            }
        }
    
        // Show the Panel
        YAHOO.example.container.wait.show();
        
        // Connect to our data source and load the data
		var conn = YAHOO.util.Connect.asyncRequest("GET", p_uri, callback);
    }
    
    YAHOO.util.Event.on("panelbutton", "click", init);
    //YAHOO.util.Event.on("panelbutton", "click", init);
