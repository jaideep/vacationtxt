var map = false;
var block_context = false;

var pin_map = { 'LODGING': "blue",
			  	'FOOD': "yellow",
			  	'NIGHTLIFE': "green",
			  	'CHILDREN': "aqua",
				'SHOPPING': "silver",
				'OUTDOOR': "pink",
				'TRANSPORTATION': "purple",
				'TOURS': "orange",
				'ENTERTAINMENT': "gold"}

function hideElement(elementId){
	jQuery('#' + elementId).slideUp("slow");
}
				
function BuildOzarksMap(mapElement){
	map = new GMap2(mapElement);
	var lakeOzarks = new GLatLng(38.194286, -92.670000);
	map.setCenter(lakeOzarks,11);
	map.setZoom(11);
	map.addControl(new GSmallMapControl());
	map.addControl(new GMapTypeControl());
	map.setMapType(G_NORMAL_MAP);
	if(block_context === false){
	  establishMapContext();
	}
}

function unloadMap(){
	var mapElement = document.getElementById("map_canvas");
	if (mapElement !== null) {
		GUnload();
	}
}

function initializeMap() {
  if (GBrowserIsCompatible()) {
  	var mapElement = document.getElementById("map_canvas");
	if (mapElement !== null) {
		BuildOzarksMap(mapElement);		
	}
  }
}

function clearPoints(mapParm){
	mapParm.clearOverlays();
}

function BuildPinIcon(image){
	var pinIcon = new GIcon();
	pinIcon.image = image;
	pinIcon.iconSize = new GSize(11,31);
	pinIcon.iconAnchor = new GPoint(6,16);
	pinIcon.infoWindowAnchor = new GPoint(21,0);
	return pinIcon;
}

function BuildCategoryPin(category) {
	return new BuildPinIcon("/images/" + pin_map[category] + "_pin.gif");	
}

function hostMerchant(id){
	revealModal("/hosted/view_merchant/" + id,{},function(){},{},"Business Listing");
}

function BuildMerchantHtml(name,web_url,id,has_discounts){
	var html = "<table class='merchantPopup'>" +
	   "<tr><td>" +
	   name +
	   ": </td><td>";
	if(web_url != null){
		html += "<a target=\"_blank\" href='" +
		   web_url +
		   "' onclick='recordMapItemClick(" + id + ",\"link\");'>Website</a><br/>";
	}
	
	html += "<a href='#' onclick=\"hostMerchant(" + 
	   id+
	    ")\">See Business Listing</a><br/>" + "";
	if (has_discounts) {
	    html += "<a href='/main/discounts?map_item=" +  id + 
		"'>View Discounts</a>";
	}
	html +=	"</td></tr>" +
		"<tr><td><a href='/trip/add_map_item?id=" +  id + 
		"'>Add To Trip</a></td></tr>"+
		"</table>";
	return html;
}

function matchCalBoxesToListingCal(){
	jQuery(".cal_box").attr("value",(jQuery("#calendar_month").attr("value") + "/1/" + jQuery("#calendar_year").attr("value")));
}

function listingPreviousMonth(){
	var id = jQuery("#listing_id").attr("value");
	var year = jQuery("#calendar_year").attr("value");
	var month = jQuery("#calendar_month").attr("value");
	jQuery('#calendar_holder').load("/customer/listing_calendar_previous_month/" + id,{year: year,month: month},matchCalBoxesToListingCal);
	
}

function listingNextMonth(){
	var id = jQuery("#listing_id").attr("value");
	var year = jQuery("#calendar_year").attr("value");
	var month = jQuery("#calendar_month").attr("value");
	jQuery('#calendar_holder').load("/customer/listing_calendar_next_month/" + id,{year: year,month: month},matchCalBoxesToListingCal);	
}

function switch_listing_unit(e){
	var element = jQuery(e.target); 
	while(!element.hasClass("unit_row")){
		element = element.parent();
	}
	var listing = element.attr("listing");
	var id = element.attr("tag");
 	revealModal("/customer/view_listing/" + listing,{selected_unit: id},listingServices,{},"Unit Listing");
}

function listingServices(){
	jQuery('#prev_month_mini_button').bind("click",listingPreviousMonth);
	jQuery('#next_month_mini_button').bind("click",listingNextMonth);
	jQuery('.unit_row').bind("click",switch_listing_unit);
}

function hostListing(id){
	revealModal("/customer/view_listing/" + id,{},listingServices,{},"Full Listing")
}

function BuildListingHtml(strongName,thumbnailUrl,listingId){
	return "<table class='merchantPopup'>" +
	   "<tr><td><img style='display: inline;' src='" +
	   thumbnailUrl +
	   "'/></td><td>" +
	   strongName +
	   "<br/><a href='#' onclick=\"hostListing("+ 
	   listingId+
	   ")\">See Full Listing</a></td></tr>"	 +
	    "</table>";
}

function StandardPinClick(){
	this.openExtInfoWindow(map,"extInfoWindow_coolBlues",this.stored_html,{beakOffset: 1});
	recordMapItemClick(this.associated_id, "pin");
}

function recordMapItemClick(item_id, click_type) {
	jQuery.get("/main/map_item_click", {id:item_id, type:click_type});
} 

function renterCounteroffer(e){	
	jQuery(e.target).css("color","black");
	jQuery("#renter_counter_text").hide();
	jQuery("#renter_counter_link").show();
	jQuery("#confirm_reservation_link").hide();
	jQuery("#confirm_reservation_text").show();
}


var refresh_loop = false;

function TripItemServices(){
	jQuery('#prev_month_mini_button').bind("click",listingPreviousMonth);
	jQuery('#next_month_mini_button').bind("click",listingNextMonth);
	jQuery(".trip_action_button").click(tripAction);
	jQuery(".bid_holder").bind("keyup",renterCounteroffer);
	if(refresh_loop === false){
		refresh_loop = setInterval(refreshTripModal,10000);
	}
}

function TripPinClick(){
	revealTripModal(this.associated_id,TripItemServices);
}

function AddPoint(icon, point,betterHtml,title,click_callback,item_id){  
	var marker = new GMarker(point,{icon: icon,clickable:true,draggable:false,title:title});    
	marker.stored_html = betterHtml;
	marker.associated_id = item_id;
	GEvent.addListener(marker, "click", click_callback);			
	map.addOverlay(marker);	
	return marker;
}

function showListingsPins(results){
	var icon = new BuildPinIcon("/images/red_pin.gif");
	for (var i = 0; i < results.length; i++) {
	  var res = results[i];
	  var point = new GLatLng(res.lat,res.long,false);
	  var html = BuildListingHtml(res.strong_name,res.thumbnail_url,res.id);
	  AddPoint(icon, point, html,res.strong_name,StandardPinClick,res.id);
	}
}

function showBusinessPins(results){
	for(var i = 0; i <results.length; i++){
		var pin = results[i];
		var marker = AddPoint(BuildCategoryPin(pin.category), new GLatLng(pin.lat,pin.long,false), 
				      BuildMerchantHtml(pin.name,pin.website_url,pin.id,pin.has_discounts),
				      pin.name,StandardPinClick,pin.id);
	}
}

function showTripListingPins(results){
	var icon = new BuildPinIcon("/images/red_pin.gif");
	var blinking_icon = new BuildPinIcon("/images/blinking_red_pin.gif");
	for (var i = 0; i < results.length; i++) {
	  var res = results[i];
	  var point = new GLatLng(res.lat,res.long,false);
	  var using_icon = (res.status === "BOOKED") ? icon : blinking_icon;
	  AddPoint(using_icon, point, "",res.name,TripPinClick,res.id);
	}
}

function showTripBusinessPins(results){
	for(var i = 0; i <results.length; i++){
		var pin = results[i];
		var marker = AddPoint(BuildCategoryPin(pin.item_category), new GLatLng(pin.lat,pin.long,false),"",pin.name,TripPinClick,pin.id);
	}
}

function displayOverlay(data,textStatus){
  var results = eval('('+data+')');
  showListingsPins(results[0]);
  showBusinessPins(results[1]);
}

function displayTripOverlay(data,textStatus){
  var results = eval('('+data+')');
  showTripListingPins(results[0]);
  showTripBusinessPins(results[1]);
}

function activateOverlay(category){
	clearPoints(map);
	jQuery.get("/data/get_map_items",{category: category},displayOverlay,"JSON");
}

function activateTripOverlay(){
	clearPoints(map);
	jQuery.get("/data/get_trip_items",{},displayTripOverlay,"JSON");
}

function mapTabSelectUI(e){
	jQuery(".map_tab").attr("id","");
	var element = jQuery(e.target);
	return element;
}

function mapTabClick(e){
	var element = mapTabSelectUI(e);
	activateOverlay(element.attr("tag"));
}

function tripTabClick(e){
	mapTabSelectUI(e);
	activateTripOverlay();
}

function rentalTabClick(e){
	mapTabSelectUI(e);
	revealRentalSearch();
}

function stallOverlay(){
	if(map === false){
		setTimeout(stallOverlay,250);
	}else{
		activateTripOverlay();
	}
}

function initializeMapTabs(){
	if(jQuery("#trip_trigger").attr("value") === "true"){
		block_context = true;
		stallOverlay();
	}
	if(jQuery("#trip_item_trigger").attr("value") !== "false"){
		var id = jQuery("#trip_item_trigger").attr("value");
		revealTripModal(id,TripItemServices);
	}
	jQuery(".map_tab").bind("click",mapTabClick);
	jQuery("#trip_tab").unbind("click").bind("click",tripTabClick);
	jQuery("#vacation_rental_tab").unbind("click").bind("click",rentalTabClick);
}

function bizSearchCallback(e){
	var id = getClickedBusinessId(e);
	clearPoints(map);
	jQuery.get("/data/get_map_items",{id: id},displayOverlay,"JSON");
	hideModal();
}

function businessSearch(){
	revealBusinessSearchModal(bizSearchCallback);
}

function establishMapContext(){
	var contextDiv = jQuery("#map_context");
	if(contextDiv.length > 0){
		if(jQuery("#context_bed_count").length > 0){
			jQuery.get("/main/remote_map_search",{bed_count: jQuery("#context_bed_count").attr("value"),
												  max_people: jQuery("#context_max_people").attr("value"),
												  max_price: jQuery("#context_max_price").attr("value"),
												  region: jQuery("#context_region").attr("value")},alternateSearchResults,"JSON");
		}else if(jQuery("#context_category").length > 0){
			activateOverlay(jQuery("#context_category").attr("value"));
		}else if(jQuery("#context_item_id").length > 0){
			jQuery.get("/data/get_map_items",{id: jQuery("#context_item_id").attr("value")},displayOverlay,"JSON");
		}else if(jQuery("#context_trip").length > 0){
			activateTripOverlay();
		}
	}
}

function homepageLinkClick(e){
	var element = jQuery(e.target);
	while(!element.hasClass("graphic_link")){
		element = element.parent();
	}
	window.location = (element.attr("dest"));
}

function showTutorial(){
	window.open('/faq/tutorial','tutorial','width=300,height=500,resizable=no,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	return false;
}

jQuery(document).ready(function(){
	initializeMapTabs();
	jQuery(".hide_me").hide();
	jQuery(".graphic_link").bind("click",homepageLinkClick);
	jQuery("#biz_search_link").unbind("click").bind("click",businessSearch);
	jQuery("#tutorial_link").facebox();
	jQuery("#trip_sms_button").bind("click",smsTrip);
});

function showSearchResults(request){
	var results = eval("("+request.responseText+")");	
	if(results.length === 0){
		revealModal("/modal/no_search_results",{},function(){},{});
	}else{
		hideModal();
		clearPoints(map);
		showListingsPins(results);
	}
}

function alternateSearchResults(data,textStatus){
	var results = eval(data);
	clearPoints(map);
	showListingsPins(results);
}

