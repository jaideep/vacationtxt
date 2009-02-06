var searchResultCallback = function(){return false;};
var modalBoxOpen =false;
jQuery(document).bind('close.facebox', function(){
    _hideModal();
    modalBoxOpen =false;
    
});
jQuery(document).bind('reveal.facebox',function(){
    modalBoxOpen =true;
});
function _hideModal(){
     if(jQuery("#facebox .content") != null)
        jQuery("#facebox .content").html("");
     
}
function hideModal()
{
    _hideModal();
    jQuery(document).trigger('close.facebox');
    return false;
}

function revealModal(url,params,services_callback,styles,title){
    
    
    styles = (typeof(styles) != 'undefined' ? styles : {top:'250px',left:'300px',width:'400px'});
    title = (typeof(title) != 'undefined' ? title : "");
    
    if(modalBoxOpen){
       jQuery.get(url, params, function(html){
           jQuery('.content').html(html);
           if(services_callback){
              services_callback.call();
           } 
       });	
    }else{
       jQuery.facebox(function(){
          jQuery.get(url, params, function(html){
             jQuery.facebox(html);
             if(services_callback){
                services_callback.call();
             } 
          });
       });
    }
}

function fadeRentalLinksIfPresent(){
    if(jQuery('#trip_remover') != null){
        jQuery('#trip_remover,#trip_action_button').fadeOut('slow').fadeIn('slow');
    }
}

//BUSINESS SEARCH*****************************************************
function revealBusinessSearchModal(resultClickCallback){
    searchResultCallback = resultClickCallback;
    revealModal("/modal/business_search",null,businessSearchModalServices);
    return false;
}

function businessSearchResults(){
    var term = jQuery("#business_search").attr("value");
    if(term.length > 2){
        jQuery.get("/data/business_search",{term: term},populateSearchResults,"JSON");
    }
}

function businessSearchModalServices(){
    jQuery("#modalContent").css("width","400px").css("left","200px");
    jQuery("#business_search").unbind("keyup").bind("keyup",businessSearchResults);
}

function populateSearchResults(data,textStatus){
    var arr = eval(data);
    var html = "";
    for (var i = 0; i < arr.length; i++) {
      var cur = arr[i];
      html = html + "<br/><hr/><a href='#' id='result_"+cur.id+"' class='business_result_link'>" + cur.name + "</a>";
    }
    jQuery("#search_results").html(html);
    jQuery(".business_result_link").click(searchResultCallback);
}	

function getClickedBusinessId(e){
    return jQuery(e.target).attr("id").split("_")[1];
}
    
//**********************************************************************

//*VACATION RENTAL SEARCH***********************************************

function revealRentalSearch(){
    revealModal("/modal/rental_search",null,null);
    return false;
}

//***********************************************************************

//*TRIP OVERLAY (PICK LIST)**********************************************

var trip_callback = function(){};

function getTripParams(clicked_id){
    return {start_date: jQuery("#start_date").attr("value"),
			start_time_hour: jQuery("#start_time_hour").attr("value"),
			start_time_minute: jQuery("#start_time_minute").attr("value"),
            stop_date: jQuery("#stop_date").attr("value"),
			stop_time_hour: jQuery("#stop_time_hour").attr("value"),
			stop_time_minute: jQuery("#stop_time_minute").attr("value"),
            id: clicked_id,
            bid: jQuery("#bid").attr("value")};
}

function tripAction(e){
    var element = jQuery(e.target);
	while(!element.hasClass("trip_action_button")){
		element = element.parent();
	}
    var action = element.attr("action");
    if(action === "none"){
        alert("No action to be taken right now.");
    }else if(action === "SEE_ITEM"){
        window.location = ("/main/welcome?see_trip_item=" + element.attr("tag"))
    }else{
        jQuery.post("/"+element.attr("controller")+"/"+action, getTripParams(element.attr("tag")),function(){
            revealTripModal(element.attr("tag"),trip_callback);
        });	
    }
}

function smsSent(){
    jQuery("#trip_sms_button").css("display","none");
    alert("Trip has been SMS'd to your phone.");
}

function smsTrip(){
    jQuery.post("/trip/sms_trip", {},smsSent);	
}

function refreshTripModal(){
    var queries = jQuery(".QUERIED");
    if(queries.length > 0){
        revealTripModal(jQuery("#trip_id").attr("value"),trip_callback);
    }
}

function revealTripModal(trip_id,services_callback){
    trip_callback = services_callback;
    revealModal("/modal/trip_item/"+trip_id,null,trip_callback,{top:'150px',left:'100px',width: '565px', height: '600px'},"My Trip");
    return false;
}

//***********************************************************************